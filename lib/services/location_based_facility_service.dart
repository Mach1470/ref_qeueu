import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ref_qeueu/models/health_facility.dart';

/// Service for location-based facility auto-assignment
/// Handles proximity-based facility assignment for refugees in Kakuma, Dadaab/IFO camps
class LocationBasedFacilityService {
  static final LocationBasedFacilityService _instance =
      LocationBasedFacilityService._internal();

  factory LocationBasedFacilityService() => _instance;
  LocationBasedFacilityService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kakuma, Kalobeyei, Dadaab, IFO facility coordinates
  static const List<HealthFacility> _refugeeFacilities = [
    // Kakuma Refugee Camp - Kenya
    HealthFacility(
      id: 'kakuma_main_health',
      name: 'Kakuma Main Health Center',
      latitude: 3.3939,
      longitude: 35.2969,
      type: 'hospital',
      address: 'Main Road, Kakuma Refugee Camp',
      capacity: 200,
    ),
    HealthFacility(
      id: 'kakuma_zone_1_clinic',
      name: 'Kakuma Zone 1 Health Clinic',
      latitude: 3.3876,
      longitude: 35.2945,
      type: 'clinic',
      address: 'Zone 1, Kakuma Refugee Camp',
      capacity: 100,
    ),
    HealthFacility(
      id: 'kakuma_zone_2_clinic',
      name: 'Kakuma Zone 2 Health Clinic',
      latitude: 3.3945,
      longitude: 35.3010,
      type: 'clinic',
      address: 'Zone 2, Kakuma Refugee Camp',
      capacity: 100,
    ),
    HealthFacility(
      id: 'kakuma_zone_3_clinic',
      name: 'Kakuma Zone 3 Health Clinic',
      latitude: 3.4010,
      longitude: 35.2880,
      type: 'clinic',
      address: 'Zone 3, Kakuma Refugee Camp',
      capacity: 80,
    ),

    // Kalobeyei Settlement - Kenya
    HealthFacility(
      id: 'kalobeyei_health_center',
      name: 'Kalobeyei Health Center',
      latitude: 3.5121,
      longitude: 35.2844,
      type: 'hospital',
      address: 'Kalobeyei Settlement, Turkana',
      capacity: 150,
    ),

    // Dadaab Refugee Complex - Kenya
    HealthFacility(
      id: 'dadaab_main_hospital',
      name: 'Dadaab Main Hospital',
      latitude: 0.3031,
      longitude: 40.3269,
      type: 'hospital',
      address: 'Main Area, Dadaab Refugee Complex',
      capacity: 300,
    ),
    HealthFacility(
      id: 'ifo_health_center',
      name: 'IFO Health Center',
      latitude: 0.2845,
      longitude: 40.3156,
      type: 'hospital',
      address: 'IFO Camp, Dadaab Refugee Complex',
      capacity: 200,
    ),
    HealthFacility(
      id: 'hagadera_clinic',
      name: 'Hagadera Health Clinic',
      latitude: 0.3210,
      longitude: 40.3401,
      type: 'clinic',
      address: 'Hagadera Camp, Dadaab Refugee Complex',
      capacity: 120,
    ),
    HealthFacility(
      id: 'kambios_clinic',
      name: 'Kambios Health Clinic',
      latitude: 0.3456,
      longitude: 40.3567,
      type: 'clinic',
      address: 'Kambios Camp, Dadaab Refugee Complex',
      capacity: 100,
    ),
  ];

  // ─────────────────────────────────────────────────────────────────
  // PUBLIC METHODS
  // ─────────────────────────────────────────────────────────────────

  /// Get user's current location with appropriate error handling
  Future<Position?> getCurrentLocation() async {
    try {
      final permission = await _requestLocationPermission();
      if (!permission) {
        return null; // User denied permission
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10, // Update every 10 meters
        ),
      ).timeout(
        const Duration(seconds: 15),
      );

      return position;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  /// Find nearest facility to given coordinates
  /// Returns the closest health facility and distance in kilometers
  Future<({HealthFacility facility, double distanceKm})?>
      findNearestFacility(double latitude, double longitude) async {
    try {
      if (_refugeeFacilities.isEmpty) {
        return null;
      }

      double nearestDistance = double.infinity;
      late HealthFacility nearestFacility;

      // Calculate distance to each facility
      for (final facility in _refugeeFacilities) {
        final distance = facility.distanceFrom(latitude, longitude);
        if (distance < nearestDistance) {
          nearestDistance = distance;
          nearestFacility = facility;
        }
      }

      return (facility: nearestFacility, distanceKm: nearestDistance);
    } catch (e) {
      print('Error finding nearest facility: $e');
      return null;
    }
  }

  /// Auto-assign user to nearest facility based on current location
  /// Updates user document with assigned facility
  Future<HealthFacility?> autoAssignFacility(String userId) async {
    try {
      // Get current location
      final position = await getCurrentLocation();
      if (position == null) {
        print('Could not get location for facility assignment');
        return null;
      }

      // Find nearest facility
      final nearestResult = await findNearestFacility(
        position.latitude,
        position.longitude,
      );

      if (nearestResult == null) {
        return null;
      }

      // Update user's facility assignment in Firestore
      await _firestore.collection('users').doc(userId).update({
        'assignedFacilityId': nearestResult.facility.id,
        'assignedFacilityName': nearestResult.facility.name,
        'assignedFacilityCoordinates': {
          'latitude': nearestResult.facility.latitude,
          'longitude': nearestResult.facility.longitude,
        },
        'facilityAssignmentTimestamp': FieldValue.serverTimestamp(),
        'facilityAssignmentDistance': nearestResult.distanceKm,
      });

      return nearestResult.facility;
    } catch (e) {
      print('Error auto-assigning facility: $e');
      return null;
    }
  }

  /// Get all available facilities (for manual selection)
  List<HealthFacility> getAllFacilities() {
    return _refugeeFacilities;
  }

  /// Get facilities near a specific location (within radius)
  Future<List<({HealthFacility facility, double distanceKm})>>
      getFacilitiesWithinRadius(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      final result = <({HealthFacility facility, double distanceKm})>[];

      for (final facility in _refugeeFacilities) {
        final distance = facility.distanceFrom(latitude, longitude);
        if (distance <= radiusKm) {
          result.add((facility: facility, distanceKm: distance));
        }
      }

      // Sort by distance (nearest first)
      result.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      return result;
    } catch (e) {
      print('Error getting facilities within radius: $e');
      return [];
    }
  }

  /// Manually assign facility to user
  Future<bool> manuallyAssignFacility(
    String userId,
    String facilityId,
  ) async {
    try {
      final facility = _refugeeFacilities.firstWhere(
        (f) => f.id == facilityId,
        orElse: () => throw Exception('Facility not found'),
      );

      // Get current position if available to calculate distance
      final position = await getCurrentLocation();
      final distance = position != null
          ? facility.distanceFrom(position.latitude, position.longitude)
          : null;

      await _firestore.collection('users').doc(userId).update({
        'assignedFacilityId': facility.id,
        'assignedFacilityName': facility.name,
        'assignedFacilityCoordinates': {
          'latitude': facility.latitude,
          'longitude': facility.longitude,
        },
        'facilityAssignmentTimestamp': FieldValue.serverTimestamp(),
        if (distance != null) 'facilityAssignmentDistance': distance,
        'facilityAssignmentMethod': 'manual',
      });

      return true;
    } catch (e) {
      print('Error manually assigning facility: $e');
      return false;
    }
  }

  /// Watch location changes and update facility assignment if needed
  /// Re-assigns to nearest facility if user moves > threshold distance
  Stream<HealthFacility> watchLocationAndReassign(
    String userId, {
    double reassignmentThresholdKm = 5.0,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 100, // Check every 100 meters
      ),
    ).asyncMap((position) async {
      final nearestResult = await findNearestFacility(
        position.latitude,
        position.longitude,
      );

      if (nearestResult == null) {
        throw Exception('Could not find nearest facility');
      }

      // Check if reassignment threshold exceeded
      if (nearestResult.distanceKm > reassignmentThresholdKm) {
        // Update assignment
        await _firestore.collection('users').doc(userId).update({
          'assignedFacilityId': nearestResult.facility.id,
          'assignedFacilityName': nearestResult.facility.name,
          'facilityAssignmentDistance': nearestResult.distanceKm,
          'facilityReassignmentTimestamp': FieldValue.serverTimestamp(),
        });
      }

      return nearestResult.facility;
    });
  }

  /// Calculate estimated arrival time to assigned facility
  /// Returns time in minutes
  Future<int?> getEstimatedArrivalTime(
    double userLatitude,
    double userLongitude,
    String facilityId,
  ) async {
    try {
      final facility = _refugeeFacilities.firstWhere(
        (f) => f.id == facilityId,
        orElse: () => throw Exception('Facility not found'),
      );

      final distanceKm = facility.distanceFrom(userLatitude, userLongitude);

      // Assume average walking speed in refugee camps: 5 km/h
      const walkingSpeedKmh = 5.0;
      final timeMinutes = ((distanceKm / walkingSpeedKmh) * 60).round();

      return timeMinutes;
    } catch (e) {
      print('Error calculating ETA: $e');
      return null;
    }
  }

  /// Get facility statistics for queue management
  Future<Map<String, dynamic>> getFacilityStats(String facilityId) async {
    try {
      // Get active queue count
      final queueSnapshot = await _firestore
          .collection('refugee_queue_system/queues/incoming')
          .where('facilityId', isEqualTo: facilityId)
          .where('status', isEqualTo: 'waiting')
          .get();

      // Get average wait time from completed entries (last 24 hours)
      final recentCompletedSnapshot = await _firestore
          .collection('refugee_queue_system/queues/incoming')
          .where('facilityId', isEqualTo: facilityId)
          .where('status', isEqualTo: 'discharged')
          .where('arrivalTime',
              isGreaterThan:
                  DateTime.now().subtract(const Duration(hours: 24)))
          .get();

      double avgWaitTime = 0;
      if (recentCompletedSnapshot.docs.isNotEmpty) {
        int totalWaitTime = 0;
        for (final doc in recentCompletedSnapshot.docs) {
          final arrivalTime = DateTime.parse(doc['arrivalTime']);
          final completionTime = DateTime.parse(doc['completionTime'] ?? '');
          totalWaitTime += completionTime.difference(arrivalTime).inMinutes;
        }
        avgWaitTime = totalWaitTime / recentCompletedSnapshot.docs.length;
      }

      return {
        'facilityId': facilityId,
        'activeQueueCount': queueSnapshot.docs.length,
        'averageWaitTimeMinutes': avgWaitTime.round(),
        'estimatedCapacityPercentage':
            ((queueSnapshot.docs.length / 100) * 100).round(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error getting facility stats: $e');
      return {};
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // PRIVATE METHODS
  // ─────────────────────────────────────────────────────────────────

  Future<bool> _requestLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        final requestedPermission = await Geolocator.requestPermission();
        return requestedPermission == LocationPermission.whileInUse ||
            requestedPermission == LocationPermission.always;
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        return true;
      }

      // Permission denied or restricted
      return false;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }
}
