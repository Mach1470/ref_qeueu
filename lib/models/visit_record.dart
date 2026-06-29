/// A CHW (Community Health Worker) visit to a patient/household.
///
/// Captures vitals, the location of the visit, and the outcome — including
/// whether the case was escalated to ambulance/doctor review.
class VisitRecord {
  final String id;
  final String chwId;
  final String chwName;
  final String patientId;
  final String patientName;
  final String? settlementId;

  /// GPS coordinates of the visit location.
  final double? lat;
  final double? lng;

  /// Vital signs captured during the visit.
  final double? temperatureC;
  final int? pulseBpm;
  final int? systolicBp;
  final int? diastolicBp;
  final int? spo2;
  final double? weightKg;
  final double? heightCm;

  final String? symptoms;
  final String? assessment;
  final String? notes;

  /// 'routine' | 'urgent' | 'emergency' — see priority_colors.dart.
  final String priority;

  /// Whether the visit was escalated (ambulance / doctor / clinic).
  final bool escalated;
  final String? escalationTarget;

  final DateTime visitedAt;
  final DateTime? syncedAt;

  const VisitRecord({
    required this.id,
    required this.chwId,
    required this.chwName,
    required this.patientId,
    required this.patientName,
    this.settlementId,
    this.lat,
    this.lng,
    this.temperatureC,
    this.pulseBpm,
    this.systolicBp,
    this.diastolicBp,
    this.spo2,
    this.weightKg,
    this.heightCm,
    this.symptoms,
    this.assessment,
    this.notes,
    this.priority = 'routine',
    this.escalated = false,
    this.escalationTarget,
    required this.visitedAt,
    this.syncedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'chwId': chwId,
    'chwName': chwName,
    'patientId': patientId,
    'patientName': patientName,
    'settlementId': settlementId,
    'lat': lat,
    'lng': lng,
    'temperatureC': temperatureC,
    'pulseBpm': pulseBpm,
    'systolicBp': systolicBp,
    'diastolicBp': diastolicBp,
    'spo2': spo2,
    'weightKg': weightKg,
    'heightCm': heightCm,
    'symptoms': symptoms,
    'assessment': assessment,
    'notes': notes,
    'priority': priority,
    'escalated': escalated,
    'escalationTarget': escalationTarget,
    'visitedAt': visitedAt.toIso8601String(),
    'syncedAt': syncedAt?.toIso8601String(),
  };

  factory VisitRecord.fromJson(Map<String, dynamic> json) => VisitRecord(
    id: json['id'] as String,
    chwId: json['chwId'] as String? ?? '',
    chwName: json['chwName'] as String? ?? '',
    patientId: json['patientId'] as String? ?? '',
    patientName: json['patientName'] as String? ?? '',
    settlementId: json['settlementId'] as String?,
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
    temperatureC: (json['temperatureC'] as num?)?.toDouble(),
    pulseBpm: json['pulseBpm'] as int?,
    systolicBp: json['systolicBp'] as int?,
    diastolicBp: json['diastolicBp'] as int?,
    spo2: json['spo2'] as int?,
    weightKg: (json['weightKg'] as num?)?.toDouble(),
    heightCm: (json['heightCm'] as num?)?.toDouble(),
    symptoms: json['symptoms'] as String?,
    assessment: json['assessment'] as String?,
    notes: json['notes'] as String?,
    priority: json['priority'] as String? ?? 'routine',
    escalated: json['escalated'] as bool? ?? false,
    escalationTarget: json['escalationTarget'] as String?,
    visitedAt:
        DateTime.tryParse(json['visitedAt'] as String? ?? '') ??
        DateTime.now(),
    syncedAt: json['syncedAt'] != null
        ? DateTime.tryParse(json['syncedAt'] as String)
        : null,
  );
}
