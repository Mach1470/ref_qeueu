import 'package:intl/intl.dart';

// Enum for the service status of a prescription
enum PharmacyServiceStatus {
  pending, // Prescription is new, but not yet processed by pharmacy staff
  inQueue, // Prescription is ready for filling
  inService, // Prescription is actively being filled at a counter
  completed, // Prescription has been filled and given to the patient
  cancelled
}

// Enum for the patient call status
enum CallStatus {
  pending, // Not called yet
  called, // Patient has been called to the counter
  missed // Patient missed the call
}

class PrescriptionItem {
  final String drugName;
  final String dosage;
  final int quantity;
  final int refills;

  PrescriptionItem({
    required this.drugName,
    required this.dosage,
    required this.quantity,
    this.refills = 0,
  });

  factory PrescriptionItem.fromMap(Map<String, dynamic> m) {
    return PrescriptionItem(
      drugName: m['drugName'] ?? 'Unknown',
      dosage: m['dosage'] ?? '',
      quantity: (m['quantity'] as int?) ?? 1,
      refills: (m['refills'] as int?) ?? 0,
    );
  }
}

// The main model for a patient's prescription in the queue
class PatientPrescription {
  final String id;
  final String patientName;
  final int age;
  final String gender;
  final String doctorName;
  String? prescriptionDetails;
  final DateTime timeSent;
  String serviceCounter;
  final List<PrescriptionItem> items;

  // Mutable fields that will be updated by staff actions
  PharmacyServiceStatus serviceStatus;
  CallStatus callStatus;
  DateTime? timeStarted;
  DateTime? timeCompleted;

  PatientPrescription({
    required this.id,
    required this.patientName,
    this.age = 0,
    this.gender = 'N/A',
    this.doctorName = 'Unknown',
    this.prescriptionDetails,
    required this.timeSent,
    this.serviceCounter = 'TBD',
    this.items = const [],
    this.serviceStatus = PharmacyServiceStatus.pending,
    this.callStatus = CallStatus.pending,
    this.timeStarted,
    this.timeCompleted,
  });

  // Helper getter for display
  String get formattedTimeSent => DateFormat('hh:mm a').format(timeSent);

  // Factory method to create an instance from a Firestore map (for future use)
  factory PatientPrescription.fromMap(Map<String, dynamic> data, String id) {
    final itemsData = (data['items'] as List<dynamic>?) ?? [];
    return PatientPrescription(
      id: id,
      patientName: data['patientName'] ?? 'Unknown Patient',
      age: (data['age'] as int?) ?? 0,
      gender: data['gender'] ?? 'N/A',
      doctorName: data['doctorName'] ?? 'Unknown',
      timeSent: (data['timeSent'] as DateTime?) ?? DateTime.now(),
      prescriptionDetails: data['prescriptionDetails'] as String?,
      serviceCounter: data['serviceCounter'] ?? 'TBD',
      items: itemsData
          .map((e) =>
              PrescriptionItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      serviceStatus: PharmacyServiceStatus.values.firstWhere(
        (e) => e.name == (data['serviceStatus'] as String?),
        orElse: () => PharmacyServiceStatus.pending,
      ),
      callStatus: CallStatus.values.firstWhere(
        (e) => e.name == (data['callStatus'] as String?),
        orElse: () => CallStatus.pending,
      ),
      timeStarted: data['timeStarted'] as DateTime?,
      timeCompleted: data['timeCompleted'] as DateTime?,
    );
  }
}

// --- Mock Data for Initial State ---
final List<PatientPrescription> initialPharmacyQueue = [
  PatientPrescription(
    id: 'P001',
    patientName: 'Aisha Omar',
    prescriptionDetails:
        'Amoxicillin 500mg (10 tablets), Paracetamol 500mg (20 tablets)',
    timeSent: DateTime.now().subtract(const Duration(minutes: 15)),
    serviceCounter: 'C1',
    serviceStatus: PharmacyServiceStatus.inQueue,
  ),
  PatientPrescription(
    id: 'P002',
    patientName: 'David Lee',
    prescriptionDetails: 'Insulin Pen (2 units), Glucometer Strips (1 box)',
    timeSent: DateTime.now().subtract(const Duration(minutes: 5)),
    serviceCounter: 'C2',
    serviceStatus: PharmacyServiceStatus.inService,
    callStatus: CallStatus.called,
    timeStarted: DateTime.now().subtract(const Duration(minutes: 2)),
  ),
  PatientPrescription(
    id: 'P003',
    patientName: 'Fatima Juma',
    prescriptionDetails: 'Cough Syrup (1 bottle), Vitamin D tablets (30)',
    timeSent: DateTime.now().subtract(const Duration(minutes: 30)),
    serviceStatus: PharmacyServiceStatus.pending,
  ),
  PatientPrescription(
    id: 'P004',
    patientName: 'Mohamed Ahmed',
    prescriptionDetails: 'Blood Pressure Medication (30 tablets)',
    timeSent: DateTime.now().subtract(const Duration(hours: 1)),
    serviceStatus: PharmacyServiceStatus.completed,
    timeCompleted: DateTime.now().subtract(const Duration(minutes: 10)),
  ),
  PatientPrescription(
    id: 'P005',
    patientName: 'Sarah Khan',
    prescriptionDetails: 'Antibiotic drops (1 bottle)',
    timeSent: DateTime.now().subtract(const Duration(minutes: 10)),
    serviceCounter: 'C1',
    serviceStatus: PharmacyServiceStatus.inQueue,
    callStatus: CallStatus.missed,
  ),
];
