import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/mock_map_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:ref_qeueu/widgets/glass_widgets.dart';

/// Premium Ambulance Driver Dashboard with "Urgent Action" theme.
class AmbulanceDriverDashboard extends StatefulWidget {
  const AmbulanceDriverDashboard({super.key});

  @override
  State<AmbulanceDriverDashboard> createState() =>
      _AmbulanceDriverDashboardState();
}

class _AmbulanceDriverDashboardState extends State<AmbulanceDriverDashboard>
    with TickerProviderStateMixin {
  static const Color premiumRed = Color(0xFFE11D48);
  static const Color successGreen = Color(0xFF10B981);
  static const Color backgroundDark = Color(0xFF0F172A);

  double? _currentLat;
  double? _currentLng;
  bool _isOnline = false;
  String _vehicleId = 'AMB-004';
  String _driverName = 'Officer John';

  // Stats
  int _tripsToday = 4;
  final double _distanceKm = 12.8;
  final int _rating = 4;

  // Incoming request
  Map<String, dynamic>? _incomingRequest;
  Timer? _countdownTimer;
  int _countdown = 30;

  StreamSubscription? _requestSubscription;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _loadDriverInfo();
    _initLocation();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _requestSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadDriverInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _vehicleId = prefs.getString('driver_vehicle_id') ?? 'AMB-004';
      _driverName = prefs.getString('user_name') ?? 'Officer John';
    });
  }

  Future<void> _initLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (!mounted) return;
      setState(() {
        _currentLat = pos.latitude;
        _currentLng = pos.longitude;
      });
      if (_isOnline) _updateDriverLocation();
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  void _toggleOnlineStatus(bool value) {
    setState(() => _isOnline = value);

    if (_isOnline) {
      _startListeningForRequests();
      _updateDriverLocation();
    } else {
      _requestSubscription?.cancel();
      _incomingRequest = null;
      _countdownTimer?.cancel();
    }
  }

  void _startListeningForRequests() {
    final ref = FirebaseDatabase.instance.ref('emergency_requests');
    _requestSubscription = ref
        .orderByChild('status')
        .equalTo('searching')
        .onChildAdded
        .listen((event) {
      if (!_isOnline || _incomingRequest != null) return;

      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          _incomingRequest = {
            'id': event.snapshot.key,
            ...Map<String, dynamic>.from(data),
          };
          _countdown = 30;
        });
        _startCountdown();
      }
    });
  }

  void _updateDriverLocation() async {
    if (!_isOnline || _currentLat == null || _currentLng == null) return;

    try {
      await FirebaseDatabase.instance
          .ref('ambulance_drivers/$_vehicleId')
          .update({
        'status': 'online',
        'location': {'lat': _currentLat!, 'lng': _currentLng!},
        'lastUpdated': ServerValue.timestamp,
      });
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        _declineRequest();
      }
    });
  }

  void _declineRequest() {
    _countdownTimer?.cancel();
    setState(() => _incomingRequest = null);
  }

  void _acceptRequest() async {
    _countdownTimer?.cancel();
    final request = _incomingRequest;
    if (request == null) return;

    try {
      await FirebaseDatabase.instance
          .ref('emergency_requests/${request['id']}')
          .update({
        'status': 'accepted',
        'driverId': _vehicleId,
        'driverName': _driverName,
      });

      setState(() {
        _incomingRequest = null;
        _tripsToday++;
      });

      if (!mounted) return;
      Navigator.pushNamed(context, '/ambulance_navigation', arguments: request);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      body: Stack(
        children: [
          // Animated Background Orb
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: premiumRed.withOpacity(0.1),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.2, 1.2),
                duration: 3.seconds),
          ),

          // Map Preview
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: MockMapView(
                primaryColor: premiumRed,
                markers: [
                  if (_currentLat != null)
                    const MockMarker(
                        x: 200,
                        y: 300,
                        icon: Icons.local_hospital_rounded,
                        color: premiumRed),
                ],
              ),
            ),
          ),

          // Main Header
          SafeArea(
            child: Column(
              children: [
                _buildPremiumHeader(),
                const Spacer(),
                _buildStatsPanel(),
              ],
            ),
          ),

          // Incoming Request Overlay
          if (_incomingRequest != null) _buildRequestOverlay(),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        backgroundColor: Colors.white.withOpacity(0.05),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [
                  successGreen.withOpacity(0.2),
                  Colors.transparent
                ]),
                border: Border.all(
                    color: _isOnline ? successGreen : Colors.white10),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.medical_services_rounded,
                      color: _isOnline ? successGreen : Colors.white24,
                      size: 24),
                  if (_isOnline) _buildStatusPulse(),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_vehicleId,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  Text(
                    _isOnline ? "OPERATIONAL" : "INACTIVE",
                    style: GoogleFonts.rajdhani(
                      color: _isOnline ? successGreen : Colors.white38,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isOnline,
              onChanged: _toggleOnlineStatus,
              activeTrackColor: successGreen.withOpacity(0.3),
              activeThumbColor: successGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPulse() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 24 + (_pulseController.value * 20),
          height: 24 + (_pulseController.value * 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: successGreen
                    .withOpacity(0.5 * (1 - _pulseController.value))),
          ),
        );
      },
    );
  }

  Widget _buildStatsPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFF1E1B4B).withOpacity(0.9), backgroundDark],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                  child: _buildStatItem('Trips', _tripsToday.toString(),
                      Icons.emergency_rounded, premiumRed)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatItem('Distance', '${_distanceKm}km',
                      Icons.route_rounded, Colors.blueAccent)),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildStatItem('Rating', '$_rating.8',
                      Icons.star_rounded, Colors.amberAccent)),
            ],
          ),
          const SizedBox(height: 32),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      backgroundColor: Colors.white.withOpacity(0.03),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          Text(label,
              style: GoogleFonts.dmSans(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildShiftButton(
          "END SHIFT",
          premiumRed,
          () => Navigator.pushReplacementNamed(context, '/role_selection'),
        ),
        const SizedBox(height: 12),
        Text(
          "TOTAL TIME ONLINE: 04H 21M",
          style: GoogleFonts.rajdhani(
              color: Colors.white24,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1),
        ),
      ],
    );
  }

  Widget _buildShiftButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.rajdhani(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: Colors.black.withOpacity(0.85),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildEmergencyOrb(),
                const SizedBox(height: 30),
                _buildEmergencyBadge(),
                const SizedBox(height: 40),
                _buildRequestDetails(),
                const Spacer(),
                _buildAcceptanceActions(),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildEmergencyOrb() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: premiumRed.withOpacity(0.2),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.6, 1.6),
                duration: 1.seconds)
            .fadeOut(),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient:
                const LinearGradient(colors: [premiumRed, Color(0xFF991B1B)]),
            boxShadow: [
              BoxShadow(color: premiumRed.withOpacity(0.5), blurRadius: 20)
            ],
          ),
          child: const Icon(Icons.emergency_share_rounded,
              color: Colors.white, size: 40),
        ),
      ],
    );
  }

  Widget _buildEmergencyBadge() {
    return Column(
      children: [
        Text(
          "URGENT DISPATCH",
          style: GoogleFonts.rajdhani(
              color: premiumRed,
              fontWeight: FontWeight.w900,
              fontSize: 14,
              letterSpacing: 4),
        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
        const SizedBox(height: 8),
        Text(
          "Patient Awaiting Response",
          style: GoogleFonts.poppins(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildRequestDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        backgroundColor: Colors.white.withOpacity(0.05),
        child: Column(
          children: [
            _buildDetailRow(
                Icons.location_on_rounded,
                "PICKUP",
                _incomingRequest?['location']?['address'] ??
                    "Area 3, Refugee Camp"),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Colors.white10)),
            _buildDetailRow(
                Icons.person_pin_circle_rounded, "DISTANCE", "1.2 km away"),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white24, size: 18),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.rajdhani(
                    color: premiumRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    letterSpacing: 1)),
            Text(value,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildAcceptanceActions() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GestureDetector(
            onTap: _acceptRequest,
            child: Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [successGreen, Color(0xFF065F46)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: successGreen.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10))
                ],
              ),
              child: Center(
                child: Text(
                  "RESPOND NOW (${_countdown}S)",
                  style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      letterSpacing: 2),
                ),
              ),
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02)),
          const SizedBox(height: 20),
          TextButton(
            onPressed: _declineRequest,
            child: Text("DECLINE",
                style: GoogleFonts.rajdhani(
                    color: Colors.white24,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
