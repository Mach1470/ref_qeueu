import 'package:cloud_firestore/cloud_firestore.dart';

/// Community Health Worker (CHW) model with triage capabilities
class CommunityHealthWorker {
  final String id;
  final String name;
  final String phone;
  final String assignedFacilityId;
  final String facilityName;
  final String status; // active, on_break, off_duty
  final DateTime dateJoined;
  final List<String> triageRoles; // ['initial_assessment', 'vital_signs', 'patient_routing']
  final int patientsAssigned;
  final int patientsProcessed;
  final bool isActive;

  CommunityHealthWorker({
    required this.id,
    required this.name,
    required this.phone,
    required this.assignedFacilityId,
    required this.facilityName,
    this.status = 'active',
    required this.dateJoined,
    this.triageRoles = const ['initial_assessment', 'vital_signs', 'patient_routing'],
    this.patientsAssigned = 0,
    this.patientsProcessed = 0,
    this.isActive = true,
  });

  /// Convert to Firestore map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'assignedFacilityId': assignedFacilityId,
      'facilityName': facilityName,
      'status': status,
      'dateJoined': dateJoined.toIso8601String(),
      'triageRoles': triageRoles,
      'patientsAssigned': patientsAssigned,
      'patientsProcessed': patientsProcessed,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create CHW from Firestore document
  factory CommunityHealthWorker.fromMap(Map<String, dynamic> map) {
    return CommunityHealthWorker(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown',
      phone: map['phone'] as String? ?? '',
      assignedFacilityId: map['assignedFacilityId'] as String? ?? '',
      facilityName: map['facilityName'] as String? ?? '',
      status: map['status'] as String? ?? 'active',
      dateJoined: map['dateJoined'] is String
          ? DateTime.parse(map['dateJoined'] as String)
          : (map['dateJoined'] as Timestamp?)?.toDate() ?? DateTime.now(),
      triageRoles: List<String>.from(map['triageRoles'] as List? ?? []),
      patientsAssigned: map['patientsAssigned'] as int? ?? 0,
      patientsProcessed: map['patientsProcessed'] as int? ?? 0,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  /// Create a copy with modified fields
  CommunityHealthWorker copyWith({
    String? id,
    String? name,
    String? phone,
    String? assignedFacilityId,
    String? facilityName,
    String? status,
    DateTime? dateJoined,
    List<String>? triageRoles,
    int? patientsAssigned,
    int? patientsProcessed,
    bool? isActive,
  }) {
    return CommunityHealthWorker(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      assignedFacilityId: assignedFacilityId ?? this.assignedFacilityId,
      facilityName: facilityName ?? this.facilityName,
      status: status ?? this.status,
      dateJoined: dateJoined ?? this.dateJoined,
      triageRoles: triageRoles ?? this.triageRoles,
      patientsAssigned: patientsAssigned ?? this.patientsAssigned,
      patientsProcessed: patientsProcessed ?? this.patientsProcessed,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// Triage Assessment model for patient evaluation
class TriageAssessment {
  final String id;
  final String patientId;
  final String chwId;
  final String facilityId;
  final DateTime assessmentTime;
  final String priority; // low, medium, high, critical
  final String symptoms;
  final Map<String, dynamic> vitalSigns; // temperature, bp, heart_rate, respiration_rate
  final String recommendation; // direct_to_doctor, pharmacy, lab, ambulance
  final String notes;
  final bool completed;

  TriageAssessment({
    required this.id,
    required this.patientId,
    required this.chwId,
    required this.facilityId,
    required this.assessmentTime,
    required this.priority,
    required this.symptoms,
    required this.vitalSigns,
    required this.recommendation,
    this.notes = '',
    this.completed = true,
  });

  /// Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'chwId': chwId,
      'facilityId': facilityId,
      'assessmentTime': assessmentTime.toIso8601String(),
      'priority': priority,
      'symptoms': symptoms,
      'vitalSigns': vitalSigns,
      'recommendation': recommendation,
      'notes': notes,
      'completed': completed,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create from Firestore document
  factory TriageAssessment.fromMap(Map<String, dynamic> map) {
    return TriageAssessment(
      id: map['id'] as String? ?? '',
      patientId: map['patientId'] as String? ?? '',
      chwId: map['chwId'] as String? ?? '',
      facilityId: map['facilityId'] as String? ?? '',
      assessmentTime: map['assessmentTime'] is String
          ? DateTime.parse(map['assessmentTime'] as String)
          : (map['assessmentTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      priority: map['priority'] as String? ?? 'medium',
      symptoms: map['symptoms'] as String? ?? '',
      vitalSigns: (map['vitalSigns'] as Map?)?.cast<String, dynamic>() ?? {},
      recommendation: map['recommendation'] as String? ?? 'direct_to_doctor',
      notes: map['notes'] as String? ?? '',
      completed: map['completed'] as bool? ?? false,
    );
  }
}

/// Helper class for priority determination based on vital signs
class TriagePriorityHelper {
  /// Calculate priority level based on vital signs
  static String calculatePriority(Map<String, dynamic> vitalSigns) {
    double? temperature = double.tryParse(vitalSigns['temperature']?.toString() ?? '37');
    int? heartRate = int.tryParse(vitalSigns['heart_rate']?.toString() ?? '70');
    int? respirationRate = int.tryParse(vitalSigns['respiration_rate']?.toString() ?? '16');

    // Critical conditions
    if (temperature != null && (temperature > 40 || temperature < 35)) return 'critical';
    if (heartRate != null && (heartRate > 120 || heartRate < 40)) return 'critical';
    if (respirationRate != null && (respirationRate > 30 || respirationRate < 10)) return 'critical';

    // High priority
    if (temperature != null && (temperature > 38.5 || temperature < 36)) return 'high';
    if (heartRate != null && (heartRate > 100 || heartRate < 50)) return 'high';

    // Medium priority
    if (temperature != null && (temperature > 37.5 || temperature < 37)) return 'medium';

    return 'low';
  }

  /// Get color for priority level
  static String getPriorityColor(String priority) {
    switch (priority) {
      case 'critical':
        return '#FF0000'; // Red
      case 'high':
        return '#FF9800'; // Orange
      case 'medium':
        return '#FFC107'; // Amber
      case 'low':
        return '#4CAF50'; // Green
      default:
        return '#2196F3'; // Blue
    }
  }
}
