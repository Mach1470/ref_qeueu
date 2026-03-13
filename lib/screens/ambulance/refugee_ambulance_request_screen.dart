import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/mock_map_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../widgets/glass_widgets.dart';

/// Refugee-side screen for requesting an ambulance (Uber-like experience)
/// Revamped with Premium "Urgent Action" theme.
class RefugeeAmbulanceRequestScreen extends StatefulWidget {
  const RefugeeAmbulanceRequestScreen({super.key});

  @override
  State<RefugeeAmbulanceRequestScreen> createState() =>
      _RefugeeAmbulanceRequestScreenState();
}

class _RefugeeAmbulanceRequestScreenState
    extends State<RefugeeAmbulanceRequestScreen> with TickerProviderStateMixin {
  static const Color premiumRed = Color(0xFFE11D48);
  static const Color successGreen = Color(0xFF10B981);
  static const Color deepBackground = Color(0xFF0F172A);

  double? _currentLat;
  double? _currentLng;
  bool _loading = true;
  String _status = 'idle'; // idle, searching, accepted, en_route, arrived

  // Driver info when accepted
  String? _driverName;
  String? _vehicleId;
  int _etaMinutes = 0;

  // Slide to request
  double _slideValue = 0;
  late AnimationController _pulseController;

  String? _requestId;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initLocation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Location permissions are permanently denied.')),
          );
        }
        setState(() => _loading = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (!mounted) return;
      setState(() {
        _currentLat = pos.latitude;
        _currentLng = pos.longitude;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestAmbulance() async {
    if (_currentLat == null || _currentLng == null) {
      await _initLocation();
      if (_currentLat == null || _currentLng == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Location missing. Please enable GPS.')),
          );
        }
        return;
      }
    }

    setState(() => _status = 'searching');

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? 'unknown';
      final userName = prefs.getString('user_name') ?? 'Patient';
      final userPhone = prefs.getString('user_phone') ?? '';

      final ref = FirebaseDatabase.instance.ref('emergency_requests').push();
      await ref.set({
        'refugeeId': userId,
        'patientName': userName,
        'phone': userPhone,
        'location': {
          'lat': _currentLat!,
          'lng': _currentLng!,
          'address': 'Kakuma Camp Area 3',
        },
        'status': 'searching',
        'createdAt': ServerValue.timestamp,
      });

      _requestId = ref.key;

      ref.onValue.listen((event) {
        if (!mounted) return;
        final data = event.snapshot.value as Map?;
        if (data == null) return;

        final status = data['status'] as String?;
        if (status == 'accepted') {
          setState(() {
            _status = 'accepted';
            _driverName = data['driverName'] ?? 'John Deng';
            _vehicleId = data['driverId'] ?? 'AMB-004';
            _etaMinutes = 5;
          });
        } else if (status == 'arrived') {
          setState(() => _status = 'arrived');
        } else if (status == 'completed' || status == 'cancelled') {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'idle');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to request: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _cancelRequest() async {
    if (_requestId == null) return;
    await FirebaseDatabase.instance
        .ref('emergency_requests/$_requestId')
        .update({'status': 'cancelled'});
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepBackground,
      body: _loading
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: premiumRed),
                    const SizedBox(height: 20),
                    Text(
                      'INITIALIZING EMERGENCY MODULE',
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                // Map Background with dark vignette
                MockMapView(
                  showRoute: _status == 'accepted' || _status == 'arrived',
                  primaryColor: premiumRed,
                  markers: [
                    if (_currentLat != null && _currentLng != null)
                      const MockMarker(
                        x: 180,
                        y: 350,
                        icon: Icons.person_pin_circle,
                        color: Color(0xFF386BB8),
                        label: 'You',
                      ),
                    if (_status == 'accepted' || _status == 'arrived')
                      const MockMarker(
                        x: 50,
                        y: 100,
                        icon: Icons.local_hospital,
                        color: premiumRed,
                        label: 'Ambulance',
                      ),
                  ],
                ),

                // Depth & Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withOpacity(0.9),
                        ],
                        stops: const [0.0, 0.2, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),

                // Pulsing Scan Effect
                if (_status == 'idle' && _currentLat != null)
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 150 + (_pulseController.value * 200),
                          height: 150 + (_pulseController.value * 200),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: premiumRed.withOpacity(
                                  0.4 * (1 - _pulseController.value)),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // App Bar & Status
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildGlassIconButton(
                          Icons.arrow_back_ios_new_rounded,
                          () => Navigator.pop(context),
                        ),
                        _buildStatusBadge(),
                      ],
                    ),
                  ),
                ),

                // Bottom Content
                _buildBottomSheet(),
              ],
            ),
    );
  }

  Widget _buildGlassIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    String text = 'SYSTEM READY';
    Color color = Colors.white;
    IconData icon = Icons.security_rounded;

    if (_status == 'searching') {
      text = 'LOCATING UNIT';
      color = Colors.amberAccent;
      icon = Icons.radar_rounded;
    } else if (_status == 'accepted') {
      text = 'AMBULANCE ASSIGNED';
      color = successGreen;
      icon = Icons.emergency_share_rounded;
    } else if (_status == 'arrived') {
      text = 'UNIT ARRIVED';
      color = successGreen;
      icon = Icons.check_circle_rounded;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.4), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 8),
              Text(
                text,
                style: GoogleFonts.rajdhani(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1E1B4B).withOpacity(0.95),
              const Color(0xFF0F172A).withOpacity(0.98),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 40,
                offset: const Offset(0, -10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 30),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2)),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.1), end: Offset.zero)
                        .animate(animation),
                    child: child,
                  ),
                );
              },
              child: _status == 'idle'
                  ? _buildIdleUI()
                  : _status == 'searching'
                      ? _buildSearchingUI()
                      : _buildDriverUI(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleUI() {
    return Column(
      key: const ValueKey('idle'),
      children: [
        Text(
          'EMERGENCY ASSISTANCE',
          style: GoogleFonts.rajdhani(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Initiate immediate response protocol. Verified medical units are on standby in your sector.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
              color: Colors.white60, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 40),
        _buildSlideToRequest(),
      ],
    );
  }

  Widget _buildSlideToRequest() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final btnS = 72.0;
        return Container(
          height: btnS,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  'SLIDE FOR EMERGENCY HELP',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white24,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 3.seconds),
              ),
              Positioned(
                left: _slideValue * (w - btnS),
                child: GestureDetector(
                  onHorizontalDragUpdate: (d) => setState(() {
                    _slideValue =
                        (_slideValue + d.delta.dx / (w - btnS)).clamp(0.0, 1.0);
                  }),
                  onHorizontalDragEnd: (d) {
                    if (_slideValue > 0.9) _requestAmbulance();
                    setState(() => _slideValue = 0);
                  },
                  child: Container(
                    width: btnS,
                    height: btnS,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [premiumRed, Color(0xFF991B1B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: premiumRed.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2),
                      ],
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: const Icon(Icons.keyboard_double_arrow_right_rounded,
                        color: Colors.white, size: 36),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchingUI() {
    return Column(
      key: const ValueKey('searching'),
      children: [
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation(premiumRed),
                strokeWidth: 3,
                backgroundColor: Colors.white.withOpacity(0.05),
              ),
            ),
            const Icon(Icons.radar_rounded, color: Colors.white, size: 30),
          ],
        ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
        const SizedBox(height: 30),
        Text(
          'CONNECTING TO DISPATCH...',
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Broadcasting your location to nearest units',
          style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 13),
        ),
        const SizedBox(height: 48),
        _buildCancelButton(),
      ],
    );
  }

  Widget _buildDriverUI() {
    return Column(
      key: const ValueKey('driver'),
      children: [
        GlassCard(
          padding: const EdgeInsets.all(20),
          backgroundColor: Colors.white.withOpacity(0.05),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05)
                  ]),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(Icons.support_agent_rounded,
                    color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _driverName ?? 'Rescue Team',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _vehicleId ?? 'AMB-REGION-4',
                      style: GoogleFonts.rajdhani(
                          color: premiumRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _status == 'arrived' ? 'ARRIVED' : 'ETA',
                    style: GoogleFonts.dmSans(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1),
                  ),
                  Text(
                    _status == 'arrived' ? 'NOW' : '$_etaMinutes MIN',
                    style: GoogleFonts.rajdhani(
                        color: successGreen,
                        fontWeight: FontWeight.w800,
                        fontSize: 22),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
                child: _buildActionButton(Icons.phone_in_talk_rounded,
                    'SECURE CALL', Colors.blueAccent)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildActionButton(Icons.messenger_outline_rounded,
                    'MESSAGE', Colors.white24)),
          ],
        ),
        const SizedBox(height: 20),
        _buildCancelButton(),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: color.withOpacity(color == Colors.blueAccent ? 0.2 : 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: color == Colors.blueAccent
                      ? const Color(0xFF60A5FA)
                      : Colors.white,
                  size: 18),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return TextButton(
      onPressed: _cancelRequest,
      child: Text(
        'CANCEL EMERGENCY REQUEST',
        style: GoogleFonts.rajdhani(
          color: Colors.white24,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 2,
        ),
      ),
    );
  }
}
