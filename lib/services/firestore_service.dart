import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:ref_qeueu/services/analytics_service.dart';
import 'package:ref_qeueu/models/analytics_models.dart';

class FirestoreService {
  FirestoreService._privateConstructor();
  static final FirestoreService instance =
      FirestoreService._privateConstructor();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Collection Paths ---
  // Using a consistent path structure.
  // 'ref_queue' is the root for our app's data to avoid clashing with other apps if any.
  static const String _rootCollection = 'refugee_queue_system';

  CollectionReference get _incomingQueueRef =>
      _db.collection('$_rootCollection/queues/incoming');
  CollectionReference get _pharmacyQueueRef =>
      _db.collection('$_rootCollection/queues/pharmacy');
  CollectionReference get _labQueueRef =>
      _db.collection('$_rootCollection/queues/lab');
  CollectionReference get _maternityQueueRef =>
      _db.collection('$_rootCollection/queues/maternity');
  CollectionReference get _patientsRef =>
      _db.collection('$_rootCollection/patients/profiles');

  // --- Profile Methods ---

  Future<void> createProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    await _patientsRef.doc(uid).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // --- Patient/Refugee Methods ---

  /// Adds a patient to the main Doctor's incoming queue
  Future<String> joinQueue({
    required String patientId,
    required String name,
    required String issueSummary,
    required String facilityId, // NEW: Required facility assignment
    String? age,
    String? gender,
    String? refugeeId,
  }) async {
    final docRef = _incomingQueueRef.doc(); // Auto-ID for the queue entry

    await docRef.set({
      'id': docRef.id,
      'patientId': patientId, // ID of the user/patient document
      'name': name,
      'issueSummary': issueSummary,
      'refugeeId': refugeeId ?? 'Unknown',
      'facilityId': facilityId, // CRITICAL: Facility assignment
      'age': age,
      'gender': gender,
      'arrivalTime': DateTime.now().toIso8601String(),
      'status': 'waiting', // waiting, consulting, discharged
      'queueOrder': FieldValue.serverTimestamp(),
    });

    // Update patient's own status
    await updatePatientStatus(patientId, 'Waiting for Doctor');

    return docRef.id;
  }

  /// Updates the status field in the patient's profile
  Future<void> updatePatientStatus(String patientId, String status) async {
    // We try to update both the profile and potentially any active queue entry
    // But primarily the profile serves as the source of truth for the patient App
    try {
      await _patientsRef.doc(patientId).set({
        'currentStatus': status,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating patient status: $e');
    }
  }

  /// Stream of a specific patient's profile (for the Patient Dashboard)
  Stream<DocumentSnapshot> getPatientStream(String patientId) {
    return _patientsRef.doc(patientId).snapshots();
  }

  // --- Doctor Methods ---

  /// Stream of patients waiting for Doctor (Incoming) filtered by facility
  Stream<QuerySnapshot> getIncomingQueue({String? facilityId}) {
    if (facilityId == null) {
      // Fallback: return all if no facility specified (shouldn't happen in production)
      return _incomingQueueRef
          .orderBy('queueOrder', descending: false)
          .snapshots();
    }
    return _incomingQueueRef
        .where('facilityId', isEqualTo: facilityId)
        .orderBy('queueOrder', descending: false)
        .snapshots();
  }

  /// Stream of patients returned from Lab (Directed/Priority)
  // For simplicity we might keep them in the same collection but with a 'priority' flag or 'fromLab' status
  // OR use a separate collection. The previous DoctorScreen used a separate path.
  // Let's stick to a status query on the incoming queue or a separate collection if strictly needed.
  // For now, let's assume "Incoming" covers new arrivals.
  // We will create a defined method for "Returned" patients if we separate them.

  /// Delete from incoming queue (e.g. when picking up a patient or discharging)
  Future<void> removeFromIncomingQueue(String queueDocId) async {
    await _incomingQueueRef.doc(queueDocId).delete();
  }

  /// Complete consultation -> Send to Pharmacy
  Future<void> sendToPharmacy(
      {required String queueDocId,
      required Map<String, dynamic> patientData,
      required String prescriptionNotes}) async {
    // 1. Remove from Incoming
    await removeFromIncomingQueue(queueDocId);

    // 2. Add to Pharmacy Queue (preserve facilityId!)
    await _pharmacyQueueRef.doc(queueDocId).set({
      ...patientData,
      'prescriptionNotes': prescriptionNotes,
      'status': 'waiting',
      'queueOrder': FieldValue.serverTimestamp(),
      'sentAt': DateTime.now().toIso8601String(),
      // facilityId is already in patientData, no need to add again
    });

    // 3. Update Patient Status
    if (patientData['patientId'] != null) {
      await updatePatientStatus(patientData['patientId'], 'Sent to Pharmacy');
    }
  }

  /// Complete consultation -> Send to Lab
  Future<void> sendToLab(
      {required String queueDocId,
      required Map<String, dynamic> patientData,
      required String labNotes}) async {
    // 1. Remove from Incoming
    await removeFromIncomingQueue(queueDocId);

    // 2. Add to Lab Queue (preserve facilityId!)
    await _labQueueRef.doc(queueDocId).set({
      ...patientData,
      'doctorNotes': labNotes,
      'status': 'waiting_sample',
      'queueOrder': FieldValue.serverTimestamp(),
      'sentAt': DateTime.now().toIso8601String(),
      // facilityId is already in patientData
    });

    // 3. Update Patient Status
    if (patientData['patientId'] != null) {
      await updatePatientStatus(patientData['patientId'], 'Sent to Lab');
    }
  }

  /// Discharge patient (End visit)
  Future<void> dischargePatient(String queueDocId, String patientId) async {
    await removeFromIncomingQueue(queueDocId);
    await updatePatientStatus(patientId, 'Discharged');
  }

  // --- Pharmacy Methods ---

  Stream<QuerySnapshot> getPharmacyQueue({String? facilityId}) {
    if (facilityId == null) {
      return _pharmacyQueueRef.orderBy('queueOrder').snapshots();
    }
    return _pharmacyQueueRef
        .where('facilityId', isEqualTo: facilityId)
        .orderBy('queueOrder')
        .snapshots();
  }

  Future<void> completePharmacyService(String docId, String patientId) async {
    // Get patient data before removing
    final doc = await _pharmacyQueueRef.doc(docId).get();
    final data = doc.data() as Map<String, dynamic>?;

    await _pharmacyQueueRef.doc(docId).delete();

    // Log treatment event to analytics
    if (data != null) {
      try {
        await AnalyticsService.instance.logTreatment(
          TreatmentEvent(
            patientId: patientId,
            facilityId: data['facilityId'] ?? '',
            department: 'pharmacy',
            timestamp: DateTime.now(),
            diagnosis: data['prescriptionNotes'],
            age: data['age'],
            gender: data['gender'],
            isReadmission: false, // TODO: Implement readmission detection
          ),
        );
      } catch (e) {
        debugPrint('Error logging pharmacy analytics: $e');
      }
    }
    await updatePatientStatus(patientId, 'Medicines Collected');
  }

  // --- Lab Methods ---

  Stream<QuerySnapshot> getLabQueue({String? facilityId}) {
    if (facilityId == null) {
      return _labQueueRef.orderBy('queueOrder').snapshots();
    }
    return _labQueueRef
        .where('facilityId', isEqualTo: facilityId)
        .orderBy('queueOrder')
        .snapshots();
  }

  // --- Maternity Methods ---

  Stream<QuerySnapshot> getMaternityQueue({String? facilityId}) {
    if (facilityId == null) {
      return _maternityQueueRef.orderBy('queueOrder').snapshots();
    }
    return _maternityQueueRef
        .where('facilityId', isEqualTo: facilityId)
        .orderBy('queueOrder')
        .snapshots();
  }

  Future<void> addToMaternityQueue({
    required String patientId,
    required String motherName,
    String? expectedDeliveryDate,
    String? facilityId,
  }) async {
    final docRef = _maternityQueueRef.doc();
    await docRef.set({
      'id': docRef.id,
      'patientId': patientId,
      'motherName': motherName,
      'expectedDeliveryDate': expectedDeliveryDate,
      'facilityId': facilityId ?? '',
      'status': 'waiting',
      'queueOrder': FieldValue.serverTimestamp(),
      'addedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Complete doctor consultation and log analytics
  Future<void> completeDoctorConsultation({
    required String queueDocId,
    required Map<String, dynamic> patientData,
    String? diagnosis,
  }) async {
    await removeFromIncomingQueue(queueDocId);

    // Log treatment event
    try {
      await AnalyticsService.instance.logTreatment(
        TreatmentEvent(
          patientId: patientData['patientId'] ?? '',
          facilityId: patientData['facilityId'] ?? '',
          department: 'doctor',
          timestamp: DateTime.now(),
          diagnosis: diagnosis,
          age: patientData['age'],
          gender: patientData['gender'],
          isReadmission: false, // TODO: Check patient visit history
        ),
      );
    } catch (e) {
      debugPrint('Error logging doctor analytics: $e');
    }
  }

  /// Record a birth in maternity
  Future<void> recordBirth({
    required String motherId,
    required String facilityId,
    required String babyGender,
    String? babyName,
    String deliveryType = 'normal',
    bool complications = false,
  }) async {
    try {
      await AnalyticsService.instance.logBirth(
        BirthRecord(
          motherId: motherId,
          facilityId: facilityId,
          birthDate: DateTime.now(),
          babyGender: babyGender,
          babyName: babyName,
          deliveryType: deliveryType,
          complications: complications,
        ),
      );
    } catch (e) {
      debugPrint('Error logging birth: $e');
    }
  }

  Future<void> dischargeMaternityPatient(String docId) async {
    await _maternityQueueRef.doc(docId).delete();
  }
}
