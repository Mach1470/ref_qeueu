import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

/// Service for managing Google Maps interactions
/// Handles map initialization, location tracking, and marker management
class MapsService {
  static final MapsService _instance = MapsService._internal();

  factory MapsService() => _instance;
  MapsService._internal();

  /// Default map center (Kakuma, Kenya)
  static const LatLng defaultCenter = LatLng(3.3939, 35.2969);
  
  /// Default zoom level
  static const double defaultZoom = 15.0;

  /// Initialize a GoogleMapController with user's current location
  Future<LatLng> getUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 10,
        ),
      ).timeout(const Duration(seconds: 15));
      
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting user location: $e');
      return defaultCenter;
    }
  }

  /// Create a marker for the user's location
  Marker createUserMarker(LatLng position, {String markerId = 'user_location'}) {
    return Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: const InfoWindow(title: 'Your Location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );
  }

  /// Create a marker for a health facility
  Marker createFacilityMarker(
    String facilityId,
    String facilityName,
    LatLng position,
  ) {
    return Marker(
      markerId: MarkerId(facilityId),
      position: position,
      infoWindow: InfoWindow(title: facilityName),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
  }

  /// Create a marker for an ambulance location
  Marker createAmbulanceMarker(
    String ambulanceId,
    String ambulanceName,
    LatLng position,
  ) {
    return Marker(
      markerId: MarkerId(ambulanceId),
      position: position,
      infoWindow: InfoWindow(title: ambulanceName),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
  }

  /// Calculate a polyline between two points
  Polyline createPolyline(
    String polylineId,
    LatLng origin,
    LatLng destination,
  ) {
    return Polyline(
      polylineId: PolylineId(polylineId),
      points: [origin, destination],
      color: const Color(0xFF386BB8),
      width: 4,
      geodesic: true,
    );
  }

  /// Create a circle around a location (for facility coverage area)
  Circle createCoverageCircle(
    String circleId,
    LatLng center,
    double radiusInMeters,
  ) {
    return Circle(
      circleId: CircleId(circleId),
      center: center,
      radius: radiusInMeters,
      fillColor: const Color(0xFF386BB8).withOpacity(0.1),
      strokeColor: const Color(0xFF386BB8),
      strokeWidth: 2,
    );
  }
}
