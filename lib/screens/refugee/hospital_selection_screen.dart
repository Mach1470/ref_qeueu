import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ref_qeueu/models/health_facility.dart';
import 'package:ref_qeueu/services/database_service.dart';
import 'package:ref_qeueu/services/location_based_facility_service.dart';
import 'package:ref_qeueu/widgets/glass_widgets.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HospitalSelectionScreen extends StatefulWidget {
  const HospitalSelectionScreen({super.key});

  @override
  State<HospitalSelectionScreen> createState() =>
      _HospitalSelectionScreenState();
}

class _HospitalSelectionScreenState extends State<HospitalSelectionScreen> {
  final _facilityService = LocationBasedFacilityService();

  // Route args
  List<Map<String, dynamic>> _selectedMembers = [];
  String _symptoms = '';
  String _symptomDuration = '';
  String _severity = 'Medium';
  List<String> _imagePaths = [];

  // State
  List<HealthFacility> _facilities = [];
  Map<String, double> _distances = {};
  Map<String, Map<String, dynamic>> _queueMetrics = {};
  String? _selectedFacilityId;
  Position? _userPosition;
  bool _isLoadingFacilities = true;
  bool _isSubmitting = false;
  String _submitStatus = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _selectedMembers =
          List<Map<String, dynamic>>.from(args['selectedMembers'] ?? []);
      _symptoms = args['symptoms'] ?? '';
      _symptomDuration = args['symptomDuration'] ?? '';
      _severity = args['severity'] ?? 'Medium';
      _imagePaths = List<String>.from(args['imageFiles'] ?? []);
    }
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    setState(() => _isLoadingFacilities = true);

    final allFacilities = _facilityService.getAllFacilities();

    // Try to get user location for distance calculation
    Position? pos;
    try {
      pos = await _facilityService.getCurrentLocation();
    } catch (_) {}

    // Build distance map
    final distanceMap = <String, double>{};
    if (pos != null) {
      for (final f in allFacilities) {
        distanceMap[f.id] = f.distanceFrom(pos.latitude, pos.longitude);
      }
    }

    // Sort by distance if we have location, otherwise keep original order
    final sorted = List<HealthFacility>.from(allFacilities);
    if (distanceMap.isNotEmpty) {
      sorted.sort((a, b) =>
          (distanceMap[a.id] ?? 9999).compareTo(distanceMap[b.id] ?? 9999));
    }

    // Auto-select nearest
    final nearestId = sorted.isNotEmpty ? sorted.first.id : null;

    if (mounted) {
      setState(() {
        _facilities = sorted;
        _distances = distanceMap;
        _userPosition = pos;
        _selectedFacilityId = nearestId;
        _isLoadingFacilities = false;
      });
    }

    // Load queue metrics for all facilities
    for (final f in sorted) {
      _loadMetrics(f.id);
    }
  }

  Future<void> _loadMetrics(String facilityId) async {
    try {
      final metrics =
          await DatabaseService.instance.getQueueMetrics(facilityId);
      if (mounted) {
        setState(() => _queueMetrics[facilityId] = metrics);
      }
    } catch (_) {}
  }

  Future<List<String>> _uploadImages(String userId) async {
    final urls = <String>[];
    for (final path in _imagePaths) {
      try {
        final file = File(path);
        if (!file.existsSync()) continue;
        final filename =
            '${DateTime.now().millisecondsSinceEpoch}_${path.split(Platform.pathSeparator).last}';
        final ref = FirebaseStorage.instance
            .ref()
            .child('queue_images')
            .child(userId)
            .child(filename);
        final task = await ref.putFile(file);
        final url = await task.ref.getDownloadURL();
        urls.add(url);
      } catch (e) {
        debugPrint('Image upload error: $e');
      }
    }
    return urls;
  }

  Future<void> _submitQueue() async {
    if (_selectedFacilityId == null || _selectedMembers.isEmpty) return;

    setState(() {
      _isSubmitting = true;
      _submitStatus = 'Preparing your queue request...';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'unknown';
      final facility =
          _facilities.firstWhere((f) => f.id == _selectedFacilityId);

      // Upload images
      List<String> imageUrls = [];
      if (_imagePaths.isNotEmpty) {
        if (mounted) setState(() => _submitStatus = 'Uploading photos...');
        imageUrls = await _uploadImages(userId);
      }

      // Submit each selected member to the queue
      if (mounted) {
        setState(() => _submitStatus =
            'Joining queue for ${_selectedMembers.length} ${_selectedMembers.length == 1 ? 'person' : 'people'}...');
      }

      String? firstTicketId;
      for (final member in _selectedMembers) {
        final profile = <String, dynamic>{
          'userId': userId,
          'memberId': member['id'],
          'name': member['name'] ?? 'Unknown',
          'relationship': member['relationship'] ?? 'Self',
          'symptoms': _symptoms,
          'symptomDuration': _symptomDuration,
          'severity': _severity,
          'imageUrls': imageUrls,
          'facilityName': facility.name,
          'role': 'refugee',
        };

        final ticketId = await DatabaseService.instance.addToJoinQueue(
          profile,
          hospitalId: _selectedFacilityId!,
          lat: _userPosition?.latitude,
          lng: _userPosition?.longitude,
        );

        firstTicketId ??= ticketId;
      }

      // Save active ticket to SharedPreferences
      if (firstTicketId != null) {
        await prefs.setString('active_ticket_id', firstTicketId);
        await prefs.setString('active_hospital_id', _selectedFacilityId!);
      }

      if (!mounted) return;
      setState(() => _submitStatus = 'Done!');

      Navigator.of(context).pushNamedAndRemoveUntil(
        '/refugee_home',
        (route) => false,
      );
    } catch (e) {
      debugPrint('Queue submit error: $e');
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _submitStatus = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Failed to join queue. Please try again.',
            style: GoogleFonts.dmSans(),
          ),
          backgroundColor: const Color(0xFF002147),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF001530), Color(0xFF002147)],
              ),
            ),
            child: Column(
              children: [
                _buildHeader(),
                if (!_isLoadingFacilities) _buildSummaryBar(),
                Expanded(
                  child: _isLoadingFacilities
                      ? _buildLoader()
                      : _buildFacilityList(),
                ),
                _buildBottomAction(),
              ],
            ),
          ),
          if (_isSubmitting) _buildSubmitOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 3 of 3',
                  style: GoogleFonts.dmSans(
                    color: const Color(0xFF82C4E8),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Select Facility',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (_userPosition != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF22C55E).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.my_location_rounded,
                        color: Color(0xFF22C55E), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      'GPS ON',
                      style: GoogleFonts.dmSans(
                        color: const Color(0xFF22C55E),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildSummaryBar() {
    final severityColor = _getSeverityColor(_severity);
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.medical_services_rounded,
                color: severityColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _symptoms.length > 60
                      ? '${_symptoms.substring(0, 60)}...'
                      : _symptoms,
                  style: GoogleFonts.dmSans(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$_severity severity · $_symptomDuration',
                  style: GoogleFonts.dmSans(
                      color: severityColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          if (_imagePaths.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.image_rounded,
                      color: Colors.white38, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '${_imagePaths.length}',
                    style: GoogleFonts.dmSans(
                        color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
              color: Color(0xFFFCBE11), strokeWidth: 3),
          const SizedBox(height: 20),
          Text(
            'Finding nearby facilities...',
            style:
                GoogleFonts.dmSans(color: Colors.white38, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      physics: const BouncingScrollPhysics(),
      itemCount: _facilities.length,
      itemBuilder: (ctx, i) {
        final f = _facilities[i];
        final isSelected = _selectedFacilityId == f.id;
        final distance = _distances[f.id];
        final metrics = _queueMetrics[f.id];
        final queueCount = metrics?['totalInQueue'] ?? metrics?['total'] ?? 0;
        final waitMin =
            metrics?['averageWaitTime'] ?? metrics?['waitMinutes'] ?? 0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFacilityId = f.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFCBE11).withOpacity(0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        )
                      ]
                    : [],
              ),
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                opacity: isSelected ? 0.14 : 0.05,
                borderColor: isSelected
                    ? const Color(0xFFFCBE11).withOpacity(0.7)
                    : Colors.white.withOpacity(0.08),
                borderWidth: isSelected ? 2 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _facilityTypeIcon(f.type),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      f.name,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (i == 0 && _userPosition != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF22C55E)
                                            .withOpacity(0.15),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        border: Border.all(
                                            color: const Color(0xFF22C55E)
                                                .withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        'NEAREST',
                                        style: GoogleFonts.dmSans(
                                          color: const Color(0xFF22C55E),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                f.address,
                                style: GoogleFonts.dmSans(
                                    color: Colors.white38, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildRadio(isSelected),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(
                        color: Colors.white.withOpacity(0.07), height: 1),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _statChip(
                          Icons.people_alt_rounded,
                          '$queueCount in queue',
                          const Color(0xFFFCBE11),
                        ),
                        const SizedBox(width: 10),
                        _statChip(
                          Icons.timer_outlined,
                          '~$waitMin min wait',
                          const Color(0xFFF59E0B),
                        ),
                        if (distance != null) ...[
                          const SizedBox(width: 10),
                          _statChip(
                            Icons.near_me_rounded,
                            _formatDistance(distance),
                            const Color(0xFF22C55E),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(delay: (i * 80).ms).slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _facilityTypeIcon(String type) {
    final isHospital = type == 'hospital';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isHospital
                ? const Color(0xFFFCBE11)
                : const Color(0xFF0EA5E9))
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: (isHospital
                  ? const Color(0xFFFCBE11)
                  : const Color(0xFF0EA5E9))
              .withOpacity(0.3),
        ),
      ),
      child: Icon(
        isHospital
            ? Icons.local_hospital_rounded
            : Icons.medical_services_rounded,
        color: isHospital
            ? const Color(0xFF82C4E8)
            : const Color(0xFF38BDF8),
        size: 22,
      ),
    );
  }

  Widget _buildRadio(bool selected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? const Color(0xFFFCBE11) : Colors.white24,
          width: 2,
        ),
        color: selected ? const Color(0xFFFCBE11) : Colors.transparent,
      ),
      child: selected
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
          : null,
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.dmSans(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    final canSubmit = _selectedFacilityId != null && !_isSubmitting;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      decoration: BoxDecoration(
        color: const Color(0xFF001530).withOpacity(0.95),
        border:
            Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: canSubmit ? _submitQueue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFCBE11),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.white.withOpacity(0.06),
              disabledForegroundColor: Colors.white24,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline_rounded, size: 22),
                const SizedBox(width: 10),
                Text(
                  'CONFIRM & JOIN QUEUE',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.75),
      child: Center(
        child: GlassCard(
          padding: const EdgeInsets.all(36),
          opacity: 0.15,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                  color: Color(0xFFFCBE11), strokeWidth: 3),
              const SizedBox(height: 24),
              Text(
                _submitStatus,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait...',
                style: GoogleFonts.dmSans(
                    color: Colors.white38, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────

  String _formatDistance(double km) {
    if (km < 1) return '${(km * 1000).round()} m away';
    return '${km.toStringAsFixed(1)} km away';
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return const Color(0xFF22C55E);
      case 'high':
        return const Color(0xFFEF4444);
      case 'critical':
        return const Color(0xFF9333EA);
      default:
        return const Color(0xFFF59E0B);
    }
  }
}
