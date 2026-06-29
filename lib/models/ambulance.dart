/// Status of an ambulance in the dispatch system.
enum AmbulanceStatus {
  available,
  enRoute,
  arrivedAtPatient,
  transporting,
  delivered,
  offline;

  String get label {
    switch (this) {
      case AmbulanceStatus.available:
        return 'Available';
      case AmbulanceStatus.enRoute:
        return 'En Route';
      case AmbulanceStatus.arrivedAtPatient:
        return 'Arrived at Patient';
      case AmbulanceStatus.transporting:
        return 'Transporting to Clinic';
      case AmbulanceStatus.delivered:
        return 'Patient Delivered';
      case AmbulanceStatus.offline:
        return 'Offline';
    }
  }

  static AmbulanceStatus fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'available':
        return AmbulanceStatus.available;
      case 'enroute':
      case 'en_route':
        return AmbulanceStatus.enRoute;
      case 'arrived':
      case 'arrived_at_patient':
        return AmbulanceStatus.arrivedAtPatient;
      case 'transporting':
        return AmbulanceStatus.transporting;
      case 'delivered':
        return AmbulanceStatus.delivered;
      case 'offline':
      default:
        return AmbulanceStatus.offline;
    }
  }
}

class Ambulance {
  final String id;
  final String driverId;
  final String driverName;
  final String plateNumber;
  final AmbulanceStatus status;
  final double? lat;
  final double? lng;
  final DateTime? lastSeen;
  final String? campRegionId;

  const Ambulance({
    required this.id,
    required this.driverId,
    required this.driverName,
    required this.plateNumber,
    required this.status,
    this.lat,
    this.lng,
    this.lastSeen,
    this.campRegionId,
  });

  Ambulance copyWith({
    AmbulanceStatus? status,
    double? lat,
    double? lng,
    DateTime? lastSeen,
  }) {
    return Ambulance(
      id: id,
      driverId: driverId,
      driverName: driverName,
      plateNumber: plateNumber,
      status: status ?? this.status,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      lastSeen: lastSeen ?? this.lastSeen,
      campRegionId: campRegionId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'driverId': driverId,
    'driverName': driverName,
    'plateNumber': plateNumber,
    'status': status.name,
    'lat': lat,
    'lng': lng,
    'lastSeen': lastSeen?.toIso8601String(),
    'campRegionId': campRegionId,
  };

  factory Ambulance.fromJson(Map<String, dynamic> json) => Ambulance(
    id: json['id'] as String,
    driverId: json['driverId'] as String? ?? '',
    driverName: json['driverName'] as String? ?? '',
    plateNumber: json['plateNumber'] as String? ?? '',
    status: AmbulanceStatus.fromString(json['status'] as String?),
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
    lastSeen: json['lastSeen'] != null
        ? DateTime.tryParse(json['lastSeen'] as String)
        : null,
    campRegionId: json['campRegionId'] as String?,
  );
}
