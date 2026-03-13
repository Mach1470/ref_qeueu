import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  final DatabaseReference _root = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ---------------------------------------------------------------------------
  // FIRESTORE: Structured Data (Profiles, Hospitals, Records)
  // ---------------------------------------------------------------------------

  // Create or Update a User Profile in Firestore (Scalable Storage)
  Future<void> createUserProfile(Map<String, dynamic> profile) async {
    final uid =
        profile['uid']; // Ensure your profile map has 'uid' if available
    if (uid != null) {
      // Use set with merge to be safe
      await _firestore.collection('users').doc(uid).set({
        ...profile,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      // Fallback for non-auth users (e.g. family members without own account)
      // We might generate a random ID or use phone.
      // For scale, we prefer Auth UIDs.
      await _firestore.collection('users').add({
        ...profile,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Get a user profile by UID
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // --- Family Members Management ---

  /// Add a family member to an account holder in Firestore
  Future<void> addFamilyMember(String uid, Map<String, dynamic> member) async {
    await _firestore.collection('users').doc(uid).collection('family_members').add({
      ...member,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get a list of family members for an account holder
  Future<List<Map<String, dynamic>>> getFamilyMembers(String uid) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('family_members')
        .orderBy('addedAt')
        .get();
    
    return snapshot.docs.map((doc) => {
      'id': doc.id,
      ...doc.data(),
    }).toList();
  }

  // Stream a user profile for real-time updates
  Stream<Map<String, dynamic>?> getUserProfileStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  // Admin: Create a Hospital Record
  Future<void> createHospital(
      String hospitalId, Map<String, dynamic> data) async {
    await _firestore.collection('hospitals').doc(hospitalId).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Get all hospitals
  Stream<List<Map<String, dynamic>>> getHospitalsStream() {
    return _firestore.collection('hospitals').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  // Get a single hospital by ID
  Future<Map<String, dynamic>?> getHospital(String hospitalId) async {
    final doc = await _firestore.collection('hospitals').doc(hospitalId).get();
    return doc.exists ? {'id': doc.id, ...doc.data()!} : null;
  }

  // ---------------------------------------------------------------------------
  // REALTIME DATABASE: High-Velocity Data (Queues, Live Sessions)
  // ---------------------------------------------------------------------------

  // Start a session for a user; returns session key
  Future<String?> startSession(
      String actorKey, Map<String, dynamic> meta) async {
    final ref =
        _root.child('userActivity').child(actorKey).child('sessions').push();
    final data = Map<String, dynamic>.from(meta);
    data['loginAt'] = ServerValue.timestamp;
    await ref.set(data);
    return ref.key;
  }

  // End the session
  Future<void> endSession(String actorKey, String sessionId) async {
    final ref = _root
        .child('userActivity')
        .child(actorKey)
        .child('sessions')
        .child(sessionId);
    await ref.update({'logoutAt': ServerValue.timestamp});
  }

  // Log a global event (kept in Realtime DB for stream usage, or move to Firestore for audit)
  // For 50M scale, true audit logs should go to Firestore or BigQuery.
  // We'll keep ephemeral events here for now.
  Future<void> logEvent(Map<String, dynamic> event) async {
    final ref = _root.child('events').push();
    final data = Map<String, dynamic>.from(event);
    data['timestamp'] = ServerValue.timestamp;
    await ref.set(data);
  }

  // Append a service log entry
  Future<void> pushServiceLog(String service, Map<String, dynamic> log) async {
    final ref = _root.child('serviceLogs').child(service).push();
    await ref.set({
      ...log,
      'timestamp': ServerValue.timestamp,
    });
  }

  // Add a refugee profile to the join queue.
  // SCALABILITY: Sharded by 'hospitalId'.
  // Returns the pushed queue key on success.
  Future<String?> addToJoinQueue(Map<String, dynamic> profile,
      {double? lat, double? lng, String hospitalId = 'general'}) async {
    // We use a specific path for the hospital's queue
    final ref =
        _root.child('active_queues').child(hospitalId).child('tickets').push();

    final data = Map<String, dynamic>.from(profile);
    data['queuedAt'] = ServerValue.timestamp;
    data['status'] = 'waiting'; // Default status

    if (lat != null && lng != null) {
      data['location'] = {'lat': lat, 'lng': lng};
    }

    await ref.set(data);

    // Update queue metrics
    await _updateQueueMetrics(hospitalId, increment: true);

    return ref.key;
  }

  // ---------------------------------------------------------------------------
  // QUEUE MANAGEMENT: Real-time Queue Operations
  // ---------------------------------------------------------------------------

  /// Get a real-time stream of queue tickets for a hospital
  Stream<List<Map<String, dynamic>>> getQueueStream(String hospitalId) {
    final ref = _root
        .child('active_queues')
        .child(hospitalId)
        .child('tickets')
        .orderByChild('queuedAt');

    return ref.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return <Map<String, dynamic>>[];

      final ticketsMap = Map<String, dynamic>.from(data as Map);
      final tickets = <Map<String, dynamic>>[];

      ticketsMap.forEach((key, value) {
        tickets.add({
          'id': key,
          ...Map<String, dynamic>.from(value as Map),
        });
      });

      // Sort by queuedAt
      tickets.sort((a, b) {
        final aTime = a['queuedAt'] ?? 0;
        final bTime = b['queuedAt'] ?? 0;
        return (aTime as int).compareTo(bTime as int);
      });

      return tickets;
    });
  }

  /// Update the status of a queue ticket
  Future<void> updateQueueStatus(
      String hospitalId, String ticketId, String status) async {
    final ref = _root
        .child('active_queues')
        .child(hospitalId)
        .child('tickets')
        .child(ticketId);

    await ref.update({
      'status': status,
      'statusUpdatedAt': ServerValue.timestamp,
    });
  }

  /// Remove a ticket from the queue (completed/cancelled)
  Future<void> removeFromQueue(String hospitalId, String ticketId) async {
    final ref = _root
        .child('active_queues')
        .child(hospitalId)
        .child('tickets')
        .child(ticketId);

    // Get ticket data before removing for archival
    final snapshot = await ref.get();
    if (snapshot.exists) {
      final ticketData = Map<String, dynamic>.from(snapshot.value as Map);

      // Archive the completed ticket
      await _root
          .child('active_queues')
          .child(hospitalId)
          .child('archived')
          .push()
          .set({
        ...ticketData,
        'completedAt': ServerValue.timestamp,
      });
    }

    // Remove from active queue
    await ref.remove();

    // Update metrics
    await _updateQueueMetrics(hospitalId, increment: false);
  }

  /// Get current queue metrics for a hospital
  Future<Map<String, dynamic>> getQueueMetrics(String hospitalId) async {
    final metricsRef =
        _root.child('active_queues').child(hospitalId).child('metrics');
    final snapshot = await metricsRef.get();

    if (!snapshot.exists) {
      return {
        'totalInQueue': 0,
        'averageWaitTime': 0,
        'lastUpdated': null,
      };
    }

    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  /// Stream queue metrics for real-time dashboard updates
  Stream<Map<String, dynamic>> getQueueMetricsStream(String hospitalId) {
    final metricsRef =
        _root.child('active_queues').child(hospitalId).child('metrics');

    return metricsRef.onValue.map((event) {
      if (!event.snapshot.exists) {
        return {
          'totalInQueue': 0,
          'averageWaitTime': 0,
          'lastUpdated': null,
        };
      }
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    });
  }

  /// Get the position of a specific ticket in the queue
  Future<int> getQueuePosition(String hospitalId, String ticketId) async {
    final ref = _root
        .child('active_queues')
        .child(hospitalId)
        .child('tickets')
        .orderByChild('queuedAt');

    final snapshot = await ref.get();
    if (!snapshot.exists) return -1;

    final ticketsMap = Map<String, dynamic>.from(snapshot.value as Map);
    final sortedKeys = ticketsMap.keys.toList()
      ..sort((a, b) {
        final aTime = (ticketsMap[a] as Map)['queuedAt'] ?? 0;
        final bTime = (ticketsMap[b] as Map)['queuedAt'] ?? 0;
        return (aTime as int).compareTo(bTime as int);
      });

    final index = sortedKeys.indexOf(ticketId);
    return index + 1; // 1-based position
  }

  /// Stream the position of a specific ticket (updates in real-time)
  Stream<int> getQueuePositionStream(String hospitalId, String ticketId) {
    return getQueueStream(hospitalId).map((tickets) {
      final index = tickets.indexWhere((t) => t['id'] == ticketId);
      return index + 1; // 1-based position, 0 if not found
    });
  }

  /// Update queue metrics (internal helper)
  Future<void> _updateQueueMetrics(String hospitalId,
      {required bool increment}) async {
    final metricsRef =
        _root.child('active_queues').child(hospitalId).child('metrics');

    await metricsRef.child('totalInQueue').set(
          ServerValue.increment(increment ? 1 : -1),
        );
    await metricsRef.child('lastUpdated').set(ServerValue.timestamp);
  }

  // ---------------------------------------------------------------------------
  // AMBULANCE TRACKING: Real-time Location Updates
  // ---------------------------------------------------------------------------

  /// Update ambulance location
  Future<void> updateAmbulanceLocation(
      String ambulanceId, double lat, double lng) async {
    final ref = _root.child('ambulance_locations').child(ambulanceId);
    await ref.set({
      'lat': lat,
      'lng': lng,
      'updatedAt': ServerValue.timestamp,
    });
  }

  /// Stream ambulance location for tracking
  Stream<Map<String, dynamic>?> getAmbulanceLocationStream(String ambulanceId) {
    final ref = _root.child('ambulance_locations').child(ambulanceId);
    return ref.onValue.map((event) {
      if (!event.snapshot.exists) return null;
      return Map<String, dynamic>.from(event.snapshot.value as Map);
    });
  }

  // ---------------------------------------------------------------------------
  // NOTIFICATIONS: FCM Token Management
  // ---------------------------------------------------------------------------

  /// Save FCM token for push notifications
  Future<void> saveFcmToken(String userId, String token) async {
    await _root.child('notifications').child(userId).set({
      'fcmToken': token,
      'updatedAt': ServerValue.timestamp,
    });
  }

  /// Remove FCM token (on logout)
  Future<void> removeFcmToken(String userId) async {
    await _root.child('notifications').child(userId).remove();
  }
}
