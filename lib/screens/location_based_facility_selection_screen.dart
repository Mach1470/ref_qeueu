import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ref_qeueu/services/location_based_facility_service.dart';
import 'package:ref_qeueu/models/health_facility.dart';

class LocationBasedFacilitySelectionScreen extends StatefulWidget {
  const LocationBasedFacilitySelectionScreen({super.key});

  @override
  State<LocationBasedFacilitySelectionScreen> createState() =>
      _LocationBasedFacilitySelectionScreenState();
}

class _LocationBasedFacilitySelectionScreenState
    extends State<LocationBasedFacilitySelectionScreen> {
  final _locationService = LocationBasedFacilityService();
  
  bool _isAutoAssigning = false;
  bool _isLoadingLocation = false;
  String? _errorMessage;
  HealthFacility? _assignedFacility;
  Position? _currentPosition;
  
  final List<({HealthFacility facility, double distanceKm})> _nearbyFacilities = [];
  
  int _selectedTab = 0; // 0: auto-assign, 1: nearby, 2: all facilities

  @override
  void initState() {
    super.initState();
    _loadAllFacilities();
  }

  Future<void> _loadAllFacilities() async {
    setState(() => _isLoadingLocation = true);
    
    try {
      // Get current location to calculate distances
      _currentPosition = await _locationService.getCurrentLocation();
      
      if (_currentPosition != null) {
        // Get nearby facilities
        final nearby = await _locationService.getFacilitiesWithinRadius(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          50.0, // 50 km radius
        );
        
        setState(() {
          _nearbyFacilities.clear();
          _nearbyFacilities.addAll(nearby);
        });
      }
    } catch (e) {
      _showError('Error loading facilities: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _autoAssignFacility(String userId) async {
    setState(() {
      _isAutoAssigning = true;
      _errorMessage = null;
    });

    try {
      final facility = await _locationService.autoAssignFacility(userId);
      
      if (!mounted) return;

      if (facility != null) {
        setState(() => _assignedFacility = facility);
        
        // Show success and navigate
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Assigned to ${facility.name}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/refugee/join_queue',
              arguments: {'facilityId': facility.id},
            );
          }
        });
      } else {
        _showError('Could not determine your location. Please select manually.');
      }
    } catch (e) {
      _showError('Auto-assignment failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isAutoAssigning = false);
      }
    }
  }

  Future<void> _selectFacility(String facilityId) async {
    final userId = 'user_id_placeholder'; // Get from auth
    
    try {
      final success = await _locationService.manuallyAssignFacility(
        userId,
        facilityId,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Facility selected. Proceeding to queue...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(
              context,
              '/refugee/join_queue',
              arguments: {'facilityId': facilityId},
            );
          }
        });
      } else {
        _showError('Failed to select facility');
      }
    } catch (e) {
      _showError('Error selecting facility: $e');
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Health Facility',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Tab Navigation
            _buildTabNavigation(),
            
            // Content based on selected tab
            if (_selectedTab == 0) _buildAutoAssignTab(),
            if (_selectedTab == 1) _buildNearbyFacilitiesTab(),
            if (_selectedTab == 2) _buildAllFacilitiesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTabButton('Auto-Assign', 0),
          _buildTabButton('Nearby', 1),
          _buildTabButton('All', 2),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? const Color(0xFF0072BC)
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? const Color(0xFF0072BC)
                  : Colors.grey[400],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoAssignTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF0072BC).withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Automatic Facility Assignment',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E40AF),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ll use your current location to find the nearest health facility.',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          if (_assignedFacility != null) ...[
            // Assigned Facility Card
            _buildFacilityCard(
              _assignedFacility!,
              isAssigned: true,
            ),
          ] else ...[
            // Auto-Assign Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0072BC),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isAutoAssigning
                    ? null
                    : () => _autoAssignFacility('user_placeholder'),
                icon: _isAutoAssigning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.location_on_rounded),
                label: Text(
                  _isAutoAssigning
                      ? 'Finding nearest facility...'
                      : 'Find My Nearest Facility',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                _errorMessage!,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: Colors.red[700],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNearbyFacilitiesTab() {
    if (_isLoadingLocation) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading nearby facilities...',
              style: GoogleFonts.dmSans(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    if (_nearbyFacilities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.location_off_rounded,
                size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No nearby facilities found',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check nearby area or view all facilities',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: _nearbyFacilities.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildFacilityCardWithDistance(
              item.facility,
              item.distanceKm,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAllFacilitiesTab() {
    final allFacilities = _locationService.getAllFacilities();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: allFacilities.map((facility) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildFacilityCard(facility),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFacilityCard(HealthFacility facility, {bool isAssigned = false}) {
    return GestureDetector(
      onTap: isAssigned ? null : () => _selectFacility(facility.id),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isAssigned
                  ? const Color(0xFF10B981)
                  : Colors.grey[200]!,
              width: isAssigned ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facility.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          facility.address,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAssigned)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Assigned',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF047857),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getTypeIcon(facility.type),
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${facility.type.replaceAll('_', ' ')} • ${facility.capacity} capacity',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (!isAssigned)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilityCardWithDistance(
    HealthFacility facility,
    double distanceKm,
  ) {
    final estimatedTimeMinutes = ((distanceKm / 5.0) * 60).round();

    return GestureDetector(
      onTap: () => _selectFacility(facility.id),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facility.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          facility.address,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0072BC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: const Color(0xFF0072BC),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${distanceKm.toStringAsFixed(1)} km • ~$estimatedTimeMinutes min',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0072BC),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'hospital':
        return Icons.local_hospital_rounded;
      case 'clinic':
        return Icons.medical_services_rounded;
      case 'health_post':
        return Icons.health_and_safety_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }
}
