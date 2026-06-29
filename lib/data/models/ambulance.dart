/// Ambulance unit: vehicle, driver, and current dispatch state.
///
/// Driven by real-time location updates from the ambulance mobile app.
class Ambulance {
  final String id;
  final String plateNumber;
  final String driverId;
  final String driverName;
  final String driverPhone;

  /// 'available' | 'dispatched' | 'en_route' | 'arrived' | 'transporting'
  /// | 'delivered' | 'offline' | 'maintenance'
  final String status;

  final double? lat;
  final double? lng;
  final DateTime? lastSeen;

  /// The camp region this ambulance is assigned to.
  final String campRegionId;

  const Ambulance({
    required this.id,
    required this.plateNumber,
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    this.status = 'offline',
    this.lat,
    this.lng,
    this.lastSeen,
    this.campRegionId = 'kakuma_kalobeyei',
  });

  factory Ambulance.fromMap(Map<String, dynamic> m) => Ambulance(
        id: m['id'] as String? ?? '',
        plateNumber: m['plateNumber'] as String? ?? '',
        driverId: m['driverId'] as String? ?? '',
        driverName: m['driverName'] as String? ?? '',
        driverPhone: m['driverPhone'] as String? ?? '',
        status: m['status'] as String? ?? 'offline',
        lat: (m['lat'] as num?)?.toDouble(),
        lng: (m['lng'] as num?)?.toDouble(),
        lastSeen: m['lastSeen'] != null
            ? DateTime.tryParse(m['lastSeen'].toString())
            : null,
        campRegionId: m['campRegionId'] as String? ?? 'kakuma_kalobeyei',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'plateNumber': plateNumber,
        'driverId': driverId,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'status': status,
        'lat': lat,
        'lng': lng,
        'lastSeen': lastSeen?.toIso8601String(),
        'campRegionId': campRegionId,
      };
}
