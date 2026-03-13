/**
 * Cloud Functions for High-Scale Backend
 * Refugee Queue Management System
 * 
 * Deploy with: firebase deploy --only functions
 * Test locally: npm run serve
 */

const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

const db = admin.firestore();
const rtdb = admin.database();

// =============================================================================
// HELPER FUNCTIONS
// =============================================================================

/**
 * Verify the caller has the required role
 */
async function verifyRole(uid, requiredRoles) {
    const userDoc = await db.collection('users').doc(uid).get();
    if (!userDoc.exists) {
        throw new HttpsError('permission-denied', 'User profile not found.');
    }
    const userRole = userDoc.data().role;
    if (!requiredRoles.includes(userRole)) {
        throw new HttpsError('permission-denied', `Role '${userRole}' is not authorized for this action.`);
    }
    return userDoc.data();
}

/**
 * Generate a queue number for a hospital
 */
async function generateQueueNumber(hospitalId) {
    const counterRef = rtdb.ref(`queue_counters/${hospitalId}`);
    const result = await counterRef.transaction((current) => {
        return (current || 0) + 1;
    });
    return result.snapshot.val();
}

// =============================================================================
// ADMIN API: Account Management
// =============================================================================

/**
 * Create a Hospital Admin Account
 * Only super_admin can call this function
 */
exports.createHospitalAdmin = onCall(async (request) => {
    const callerUid = request.auth?.uid;
    if (!callerUid) {
        throw new HttpsError('unauthenticated', 'User must be logged in.');
    }

    // Verify caller is super_admin
    await verifyRole(callerUid, ['super_admin']);

    const { email, password, hospitalId, name } = request.data;

    if (!email || !password || !hospitalId || !name) {
        throw new HttpsError('invalid-argument', 'Missing required fields: email, password, hospitalId, name');
    }

    try {
        // Create Firebase Auth user
        const userRecord = await admin.auth().createUser({
            email: email,
            password: password,
            displayName: name,
        });

        // Set custom claims for RBAC
        await admin.auth().setCustomUserClaims(userRecord.uid, {
            role: 'hospital_admin',
            hospitalId: hospitalId
        });

        // Create user profile in Firestore
        await db.collection('users').doc(userRecord.uid).set({
            name: name,
            email: email,
            role: 'hospital_admin',
            hospitalId: hospitalId,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            createdBy: callerUid
        });

        logger.info(`Hospital admin created: ${email} for hospital ${hospitalId}`);
        return { success: true, uid: userRecord.uid };
    } catch (error) {
        logger.error("Error creating hospital admin", error);
        throw new HttpsError('internal', error.message);
    }
});

/**
 * Create a Staff Account (Doctor, Pharmacy, Lab, Maternity, Ambulance)
 * Hospital admins and super_admins can call this
 */
exports.createStaffAccount = onCall(async (request) => {
    const callerUid = request.auth?.uid;
    if (!callerUid) {
        throw new HttpsError('unauthenticated', 'User must be logged in.');
    }

    // Verify caller has admin privileges
    const callerData = await verifyRole(callerUid, ['super_admin', 'hospital_admin']);

    const { email, password, name, role, hospitalId, department } = request.data;

    // Validate role
    const validRoles = ['doctor', 'pharmacy', 'lab', 'maternity', 'ambulance'];
    if (!validRoles.includes(role)) {
        throw new HttpsError('invalid-argument', `Invalid role. Must be one of: ${validRoles.join(', ')}`);
    }

    // Hospital admins can only create staff for their own hospital
    const targetHospitalId = callerData.role === 'super_admin' ? hospitalId : callerData.hospitalId;

    if (!email || !password || !name) {
        throw new HttpsError('invalid-argument', 'Missing required fields: email, password, name');
    }

    try {
        // Create Firebase Auth user
        const userRecord = await admin.auth().createUser({
            email: email,
            password: password,
            displayName: name,
        });

        // Set custom claims
        await admin.auth().setCustomUserClaims(userRecord.uid, {
            role: role,
            hospitalId: targetHospitalId
        });

        // Create user profile in Firestore
        await db.collection('users').doc(userRecord.uid).set({
            name: name,
            email: email,
            role: role,
            hospitalId: targetHospitalId,
            department: department || null,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            createdBy: callerUid
        });

        logger.info(`Staff account created: ${email} as ${role}`);
        return { success: true, uid: userRecord.uid, role: role };
    } catch (error) {
        logger.error("Error creating staff account", error);
        throw new HttpsError('internal', error.message);
    }
});

// =============================================================================
// QUEUE MANAGEMENT
// =============================================================================

/**
 * Process a queue ticket transition (e.g., Doctor -> Pharmacy/Lab)
 * Ensures atomic moves and logs analytics
 */
exports.processQueueTicket = onCall(async (request) => {
    const callerUid = request.auth?.uid;
    if (!callerUid) {
        throw new HttpsError('unauthenticated', 'User must be logged in.');
    }

    // Verify caller is staff
    await verifyRole(callerUid, ['doctor', 'pharmacy', 'lab', 'maternity', 'hospital_admin', 'super_admin']);

    const { ticketId, fromQueue, toQueue, hospitalId, notes, diagnosis } = request.data;

    if (!ticketId || !fromQueue || !hospitalId) {
        throw new HttpsError('invalid-argument', 'Missing required fields: ticketId, fromQueue, hospitalId');
    }

    try {
        const batch = db.batch();

        // Get the source ticket
        const sourceRef = db.collection(`refugee_queue_system/queues/${fromQueue}`).doc(ticketId);
        const sourceDoc = await sourceRef.get();

        if (!sourceDoc.exists) {
            throw new HttpsError('not-found', 'Ticket not found in source queue.');
        }

        const ticketData = sourceDoc.data();

        // If moving to another queue
        if (toQueue) {
            const destRef = db.collection(`refugee_queue_system/queues/${toQueue}`).doc(ticketId);

            batch.set(destRef, {
                ...ticketData,
                previousQueue: fromQueue,
                notes: notes || null,
                diagnosis: diagnosis || null,
                movedAt: admin.firestore.FieldValue.serverTimestamp(),
                movedBy: callerUid,
                queueOrder: admin.firestore.FieldValue.serverTimestamp()
            });
        }

        // Remove from source queue
        batch.delete(sourceRef);

        // Update patient status
        if (ticketData.patientId) {
            const patientRef = db.collection('refugee_queue_system/patients/profiles').doc(ticketData.patientId);
            const statusMap = {
                'pharmacy': 'Sent to Pharmacy',
                'lab': 'Sent to Lab',
                null: 'Completed'
            };
            batch.update(patientRef, {
                currentStatus: statusMap[toQueue] || 'In Progress',
                lastUpdated: admin.firestore.FieldValue.serverTimestamp()
            });
        }

        // Log analytics
        const analyticsRef = db.collection('analytics/system/treatments').doc();
        batch.set(analyticsRef, {
            patientId: ticketData.patientId,
            facilityId: hospitalId,
            department: fromQueue,
            timestamp: new Date().toISOString(),
            diagnosis: diagnosis || null,
            age: ticketData.age || null,
            gender: ticketData.gender || null,
            processedBy: callerUid
        });

        await batch.commit();

        logger.info(`Ticket ${ticketId} processed: ${fromQueue} -> ${toQueue || 'completed'}`);
        return { success: true, ticketId: ticketId };
    } catch (error) {
        logger.error("Error processing queue ticket", error);
        throw new HttpsError('internal', error.message);
    }
});

/**
 * Get real-time queue analytics
 */
exports.getQueueAnalytics = onCall(async (request) => {
    const callerUid = request.auth?.uid;
    if (!callerUid) {
        throw new HttpsError('unauthenticated', 'User must be logged in.');
    }

    // Verify caller is staff or admin
    await verifyRole(callerUid, ['doctor', 'pharmacy', 'lab', 'maternity', 'hospital_admin', 'super_admin']);

    const { hospitalId, period } = request.data;

    try {
        const now = new Date();
        let startDate;

        switch (period) {
            case 'today':
                startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                break;
            case 'week':
                startDate = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);
                break;
            case 'month':
                startDate = new Date(now.getFullYear(), now.getMonth(), 1);
                break;
            default:
                startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
        }

        // Query analytics
        let query = db.collection('analytics/system/treatments')
            .where('timestamp', '>=', startDate.toISOString());

        if (hospitalId) {
            query = query.where('facilityId', '==', hospitalId);
        }

        const snapshot = await query.get();

        // Aggregate data
        const stats = {
            totalPatients: snapshot.size,
            byDepartment: {},
            byDiagnosis: {},
            byGender: { male: 0, female: 0, unknown: 0 }
        };

        snapshot.forEach(doc => {
            const data = doc.data();

            // By department
            const dept = data.department || 'unknown';
            stats.byDepartment[dept] = (stats.byDepartment[dept] || 0) + 1;

            // By diagnosis
            if (data.diagnosis) {
                stats.byDiagnosis[data.diagnosis] = (stats.byDiagnosis[data.diagnosis] || 0) + 1;
            }

            // By gender
            const gender = (data.gender || 'unknown').toLowerCase();
            if (gender === 'male' || gender === 'm') {
                stats.byGender.male++;
            } else if (gender === 'female' || gender === 'f') {
                stats.byGender.female++;
            } else {
                stats.byGender.unknown++;
            }
        });

        return { success: true, stats: stats, period: period };
    } catch (error) {
        logger.error("Error getting queue analytics", error);
        throw new HttpsError('internal', error.message);
    }
});

// =============================================================================
// NOTIFICATIONS
// =============================================================================

/**
 * Send push notification to a user
 */
exports.sendNotification = onCall(async (request) => {
    const { userId, title, body, data } = request.data;

    if (!userId || !title || !body) {
        throw new HttpsError('invalid-argument', 'Missing required fields: userId, title, body');
    }

    try {
        // Get user's FCM token from Realtime DB
        const tokenSnapshot = await rtdb.ref(`notifications/${userId}/fcmToken`).get();

        if (!tokenSnapshot.exists()) {
            logger.warn(`No FCM token found for user ${userId}`);
            return { success: false, reason: 'No FCM token found' };
        }

        const fcmToken = tokenSnapshot.val();

        // Send the notification
        const message = {
            token: fcmToken,
            notification: {
                title: title,
                body: body
            },
            data: data || {}
        };

        await admin.messaging().send(message);

        logger.info(`Notification sent to user ${userId}`);
        return { success: true };
    } catch (error) {
        logger.error("Error sending notification", error);
        throw new HttpsError('internal', error.message);
    }
});

// =============================================================================
// SCHEDULED TASKS
// =============================================================================

/**
 * Archive completed visits to Firestore (runs weekly)
 * Keeps the Realtime DB lightweight for sub-10ms latency
 */
exports.archiveCompletedVisits = onSchedule("every sunday 02:00", async (event) => {
    logger.info("Starting weekly archive of completed visits...");

    try {
        // Get all hospitals
        const hospitalsSnapshot = await db.collection('hospitals').get();
        let totalArchived = 0;

        for (const hospitalDoc of hospitalsSnapshot.docs) {
            const hospitalId = hospitalDoc.id;

            // Get completed tickets older than 7 days from Realtime DB
            const cutoffTime = Date.now() - (7 * 24 * 60 * 60 * 1000);
            const ticketsRef = rtdb.ref(`active_queues/${hospitalId}/archived`);
            const oldTickets = await ticketsRef.orderByChild('completedAt').endAt(cutoffTime).once('value');

            if (oldTickets.exists()) {
                const batch = db.batch();
                const archiveCollection = db.collection(`archives/${hospitalId}/visits`);

                oldTickets.forEach((childSnapshot) => {
                    const ticketData = childSnapshot.val();
                    const archiveRef = archiveCollection.doc(childSnapshot.key);
                    batch.set(archiveRef, {
                        ...ticketData,
                        archivedAt: admin.firestore.FieldValue.serverTimestamp()
                    });
                    totalArchived++;
                });

                await batch.commit();

                // Remove archived tickets from Realtime DB
                await ticketsRef.remove();
            }
        }

        logger.info(`Archive complete. Total visits archived: ${totalArchived}`);
        return null;
    } catch (error) {
        logger.error("Error in archive job", error);
        return null;
    }
});

/**
 * Reset daily queue counters (runs at midnight)
 */
exports.resetDailyCounters = onSchedule("every day 00:00", async (event) => {
    logger.info("Resetting daily queue counters...");

    try {
        const countersRef = rtdb.ref('queue_counters');
        await countersRef.set({});

        logger.info("Daily queue counters reset complete");
        return null;
    } catch (error) {
        logger.error("Error resetting counters", error);
        return null;
    }
});

// =============================================================================
// TRIGGERS
// =============================================================================

/**
 * When a patient joins the queue, send them a confirmation
 */
exports.onPatientJoinQueue = onDocumentCreated("refugee_queue_system/queues/incoming/{ticketId}", async (event) => {
    const ticketData = event.data.data();

    if (ticketData.patientId) {
        try {
            // Get patient profile
            const patientDoc = await db.collection('refugee_queue_system/patients/profiles').doc(ticketData.patientId).get();

            if (patientDoc.exists) {
                const patientData = patientDoc.data();

                // Update patient status
                await patientDoc.ref.update({
                    currentStatus: 'Waiting for Doctor',
                    queueTicketId: event.params.ticketId,
                    lastUpdated: admin.firestore.FieldValue.serverTimestamp()
                });

                // Send notification (if FCM token exists)
                const tokenSnapshot = await rtdb.ref(`notifications/${ticketData.patientId}/fcmToken`).get();
                if (tokenSnapshot.exists()) {
                    await admin.messaging().send({
                        token: tokenSnapshot.val(),
                        notification: {
                            title: 'Queue Joined',
                            body: `You are now in the queue at ${ticketData.facilityId || 'the facility'}. Please wait for your turn.`
                        }
                    });
                }
            }
        } catch (error) {
            logger.error("Error in onPatientJoinQueue trigger", error);
        }
    }
});

/**
 * When a prescription is marked fulfilled, notify the patient
 */
exports.onPrescriptionFulfilled = onDocumentUpdated("prescriptions/{prescriptionId}", async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();

    // Check if status changed to fulfilled
    if (before.status !== 'fulfilled' && after.status === 'fulfilled') {
        try {
            const tokenSnapshot = await rtdb.ref(`notifications/${after.patientId}/fcmToken`).get();
            if (tokenSnapshot.exists()) {
                await admin.messaging().send({
                    token: tokenSnapshot.val(),
                    notification: {
                        title: 'Medicines Ready',
                        body: 'Your prescription has been prepared. Please collect your medicines from the pharmacy.'
                    }
                });
            }
        } catch (error) {
            logger.error("Error in onPrescriptionFulfilled trigger", error);
        }
    }
});
