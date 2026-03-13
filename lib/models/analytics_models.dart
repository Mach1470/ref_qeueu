class AnalyticsMetric {
  final String id;
  final String facilityId;
  final DateTime date;
  final String type; // 'treatment', 'birth', 'readmission'
  final Map<String, dynamic> data;

  const AnalyticsMetric({
    required this.id,
    required this.facilityId,
    required this.date,
    required this.type,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'facilityId': facilityId,
      'date': date.toIso8601String(),
      'type': type,
      'data': data,
    };
  }

  factory AnalyticsMetric.fromMap(Map<String, dynamic> map) {
    return AnalyticsMetric(
      id: map['id'] ?? '',
      facilityId: map['facilityId'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      type: map['type'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
    );
  }
}

class TreatmentEvent {
  final String patientId;
  final String facilityId;
  final String department; // 'doctor', 'pharmacy', 'lab', 'maternity'
  final DateTime timestamp;
  final String? diagnosis;
  final String? age;
  final String? gender;
  final bool isReadmission;

  const TreatmentEvent({
    required this.patientId,
    required this.facilityId,
    required this.department,
    required this.timestamp,
    this.diagnosis,
    this.age,
    this.gender,
    this.isReadmission = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'facilityId': facilityId,
      'department': department,
      'timestamp': timestamp.toIso8601String(),
      'diagnosis': diagnosis,
      'age': age,
      'gender': gender,
      'isReadmission': isReadmission,
    };
  }

  factory TreatmentEvent.fromMap(Map<String, dynamic> map) {
    return TreatmentEvent(
      patientId: map['patientId'] ?? '',
      facilityId: map['facilityId'] ?? '',
      department: map['department'] ?? '',
      timestamp:
          DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      diagnosis: map['diagnosis'],
      age: map['age'],
      gender: map['gender'],
      isReadmission: map['isReadmission'] ?? false,
    );
  }
}

class BirthRecord {
  final String motherId;
  final String facilityId;
  final DateTime birthDate;
  final String babyGender;
  final String? babyName;
  final String deliveryType; // 'normal', 'cesarean', 'assisted'
  final bool complications;

  const BirthRecord({
    required this.motherId,
    required this.facilityId,
    required this.birthDate,
    required this.babyGender,
    this.babyName,
    required this.deliveryType,
    this.complications = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'motherId': motherId,
      'facilityId': facilityId,
      'birthDate': birthDate.toIso8601String(),
      'babyGender': babyGender,
      'babyName': babyName,
      'deliveryType': deliveryType,
      'complications': complications,
    };
  }

  factory BirthRecord.fromMap(Map<String, dynamic> map) {
    return BirthRecord(
      motherId: map['motherId'] ?? '',
      facilityId: map['facilityId'] ?? '',
      birthDate:
          DateTime.parse(map['birthDate'] ?? DateTime.now().toIso8601String()),
      babyGender: map['babyGender'] ?? 'unknown',
      babyName: map['babyName'],
      deliveryType: map['deliveryType'] ?? 'normal',
      complications: map['complications'] ?? false,
    );
  }
}

class DailyAggregate {
  final String facilityId;
  final DateTime date;
  final int treatmentCount;
  final int birthCount;
  final int readmissionCount;
  final Map<String, int> departmentCounts;
  final Map<String, int> ageCounts;
  final Map<String, int> genderCounts;

  const DailyAggregate({
    required this.facilityId,
    required this.date,
    required this.treatmentCount,
    required this.birthCount,
    required this.readmissionCount,
    required this.departmentCounts,
    required this.ageCounts,
    required this.genderCounts,
  });

  Map<String, dynamic> toMap() {
    return {
      'facilityId': facilityId,
      'date': date.toIso8601String(),
      'treatmentCount': treatmentCount,
      'birthCount': birthCount,
      'readmissionCount': readmissionCount,
      'departmentCounts': departmentCounts,
      'ageCounts': ageCounts,
      'genderCounts': genderCounts,
    };
  }

  factory DailyAggregate.fromMap(Map<String, dynamic> map) {
    return DailyAggregate(
      facilityId: map['facilityId'] ?? '',
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      treatmentCount: map['treatmentCount'] ?? 0,
      birthCount: map['birthCount'] ?? 0,
      readmissionCount: map['readmissionCount'] ?? 0,
      departmentCounts: Map<String, int>.from(map['departmentCounts'] ?? {}),
      ageCounts: Map<String, int>.from(map['ageCounts'] ?? {}),
      genderCounts: Map<String, int>.from(map['genderCounts'] ?? {}),
    );
  }
}
