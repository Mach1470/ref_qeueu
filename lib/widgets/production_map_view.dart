import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ref_qeueu/services/maps_service.dart';

/// Production-ready Google Maps widget for displaying locations
/// Replaces MockMapView with real Google Maps functionality
class ProductionMapView extends StatefulWidget {
  final String? title;
  final List<Marker>? markers;
  final List<Polyline>? polylines;
  final List<Circle>? circles;
  final LatLng? initialCenter;
  final double zoomLevel;
  final bool showUserLocation;
  final VoidCallback? onMapCreated;

  const ProductionMapView({
    super.key,
    this.title,
    this.markers,
    this.polylines,
    this.circles,
    this.initialCenter,
    this.zoomLevel = 15.0,
    this.showUserLocation = false,
    this.onMapCreated,
  });

  @override
  State<ProductionMapView> createState() => _ProductionMapViewState();
}

class _ProductionMapViewState extends State<ProductionMapView> {
  late GoogleMapController _mapController;
  LatLng? _userLocation;
  bool _isLoading = true;
  late Set<Marker> _markers = {};
  late Set<Polyline> _polylines = {};
  late Set<Circle> _circles = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      if (widget.showUserLocation) {
        _userLocation = await MapsService().getUserLocation();
      }

      // Add provided markers
      if (widget.markers != null) {
        _markers.addAll(widget.markers!);
      }

      // Add user location marker if requested
      if (widget.showUserLocation && _userLocation != null) {
        _markers.add(
          MapsService().createUserMarker(_userLocation!),
        );
      }

      // Add polylines
      if (widget.polylines != null) {
        _polylines.addAll(widget.polylines!);
      }

      // Add circles
      if (widget.circles != null) {
        _circles.addAll(widget.circles!);
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error initializing map: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    widget.onMapCreated?.call();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final initialCenter = widget.initialCenter ?? _userLocation ?? MapsService.defaultCenter;

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: initialCenter,
        zoom: widget.zoomLevel,
      ),
      markers: _markers,
      polylines: _polylines,
      circles: _circles,
      myLocationEnabled: widget.showUserLocation,
      myLocationButtonEnabled: widget.showUserLocation,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
      compassEnabled: true,
    );
  }
}
