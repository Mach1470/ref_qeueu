import 'dart:math';

class HealthFacility {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String type; // 'hospital', 'clinic', 'health_post'
  final String address;
  final int capacity; // Max patients per day

  const HealthFacility({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.address,
    this.capacity = 100,
  });

  // Calculate distance from a given point (in kilometers)
  double distanceFrom(double lat, double lng) {
    const double earthRadius = 6371; // km

    final dLat = _toRadians(lat - latitude);
    final dLng = _toRadians(lng - longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(latitude)) *
            cos(_toRadians(lat)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'type': type,
      'address': address,
      'capacity': capacity,
    };
  }

  factory HealthFacility.fromMap(Map<String, dynamic> map) {
    return HealthFacility(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      type: map['type'] ?? 'clinic',
      address: map['address'] ?? '',
      capacity: map['capacity'] ?? 100,
    );
  }
}

// Mock UNHCR Health Facilities
// These are example locations around Nairobi/Kakuma area
final List<HealthFacility> mockHealthFacilities = [
  HealthFacility(
    id: 'fac_001',
    name: 'UNHCR Main Camp Hospital',
    latitude: 3.1212,
    longitude: 35.3725,
    type: 'hospital',
    address: 'Kakuma Refugee Camp Zone 1, Turkana County',
    capacity: 200,
  ),
  HealthFacility(
    id: 'fac_002',
    name: 'Kalobeyei Health Center',
    latitude: 3.2855,
    longitude: 35.3315,
    type: 'clinic',
    address: 'Kalobeyei Settlement, Turkana County',
    capacity: 150,
  ),
  HealthFacility(
    id: 'fac_003',
    name: 'Zone 3 Primary Health Post',
    latitude: 3.1150,
    longitude: 35.3850,
    type: 'health_post',
    address: 'Kakuma Camp Zone 3, Turkana County',
    capacity: 80,
  ),
  HealthFacility(
    id: 'fac_004',
    name: 'Dadaab Comprehensive Care Center',
    latitude: -0.0627,
    longitude: 40.3144,
    type: 'hospital',
    address: 'Dadaab Refugee Camp, Garissa County',
    capacity: 180,
  ),
  HealthFacility(
    id: 'fac_005',
    name: 'Nairobi Urban Refugee Clinic',
    latitude: -1.2921,
    longitude: 36.8219,
    type: 'clinic',
    address: 'Eastleigh, Nairobi',
    capacity: 100,
  ),
];

// Helper function to get nearest facility
HealthFacility getNearestFacility(double userLat, double userLng) {
  HealthFacility nearest = mockHealthFacilities.first;
  double minDistance = nearest.distanceFrom(userLat, userLng);

  for (final facility in mockHealthFacilities) {
    final distance = facility.distanceFrom(userLat, userLng);
    if (distance < minDistance) {
      minDistance = distance;
      nearest = facility;
    }
  }

  return nearest;
}
