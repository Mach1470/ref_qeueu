/// An emergency ambulance request submitted by a refugee or a CHW.
///
/// The status flow follows the brief:
///   received → accepted → en_route → arrived → onboard → delivered → completed
///
/// Any state can transition to `cancelled`.
class EmergencyRequest {
  final String id;
  final String requesterId; // refugee uid or chw uid
  final String requesterRole; // 'refugee' or 'chw'
  final String requesterName;
  final String requesterPhone;

  final String campRegionId;
  final String settlementId;
  final String? subdivision;

  final double? lat;
  final double? lng;

  /// 'critical' | 'high' | 'medium' | 'low'
  final String priority;

  final String? symptoms;
  final Map<String, dynamic> vitals; // optional, from CHW
  final String? notes;

  final String status;
  final String? assignedAmbulanceId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const EmergencyRequest({
    required this.id,
    required this.requesterId,
    required this.requesterRole,
    required this.requesterName,
    required this.requesterPhone,
    required this.campRegionId,
    required this.settlementId,
    this.subdivision,
    this.lat,
    this.lng,
    this.priority = 'high',
    this.symptoms,
    this.vitals = const {},
    this.notes,
    this.status = 'received',
    this.assignedAmbulanceId,
    required this.createdAt,
    this.updatedAt,
  });

  factory EmergencyRequest.fromMap(Map<String, dynamic> m) => EmergencyRequest(
        id: m['id'] as String? ?? '',
        requesterId: m['requesterId'] as String? ?? '',
        requesterRole: m['requesterRole'] as String? ?? 'refugee',
        requesterName: m['requesterName'] as String? ?? '',
        requesterPhone: m['requesterPhone'] as String? ?? '',
        campRegionId: m['campRegionId'] as String? ?? 'kakuma_kalobeyei',
        settlementId: m['settlementId'] as String? ?? '',
        subdivision: m['subdivision'] as String?,
        lat: (m['lat'] as num?)?.toDouble(),
        lng: (m['lng'] as num?)?.toDouble(),
        priority: m['priority'] as String? ?? 'high',
        symptoms: m['symptoms'] as String?,
        vitals: (m['vitals'] as Map?)?.cast<String, dynamic>() ?? const {},
        notes: m['notes'] as String?,
        status: m['status'] as String? ?? 'received',
        assignedAmbulanceId: m['assignedAmbulanceId'] as String?,
        createdAt: DateTime.tryParse(m['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        updatedAt: m['updatedAt'] != null
            ? DateTime.tryParse(m['updatedAt'].toString())
            : null,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'requesterId': requesterId,
        'requesterRole': requesterRole,
        'requesterName': requesterName,
        'requesterPhone': requesterPhone,
        'campRegionId': campRegionId,
        'settlementId': settlementId,
        'subdivision': subdivision,
        'lat': lat,
        'lng': lng,
        'priority': priority,
        'symptoms': symptoms,
        'vitals': vitals,
        'notes': notes,
        'status': status,
        'assignedAmbulanceId': assignedAmbulanceId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
