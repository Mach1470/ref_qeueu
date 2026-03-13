import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/mock_map_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../widgets/glass_widgets.dart';

class AmbulanceNavigationScreen extends StatefulWidget {
  final Map<String, dynamic> request;

  const AmbulanceNavigationScreen({super.key, required this.request});

  @override
  State<AmbulanceNavigationScreen> createState() =>
      _AmbulanceNavigationScreenState();
}

class _AmbulanceNavigationScreenState extends State<AmbulanceNavigationScreen> {
  static const Color primaryRed = Color(0xFFE11900);
  static const Color accentRed = Color(0xFFFF3B30);
  static const Color deepIndigo = Color(0xFF1E1B4B);
  static const Color successGreen = Color(0xFF10B981);

  double? _currentLat;
  double? _currentLng;
  double? _patientLat;
  double? _patientLng;
  bool _loading = true;

  String _status = 'en_route'; // en_route, arrived, completed
  final int _etaMinutes = 5;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _initNavigation();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _initNavigation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final patientLat =
          widget.request['location']?['lat'] as double? ?? pos.latitude + 0.01;
      final patientLng =
          widget.request['location']?['lng'] as double? ?? pos.longitude + 0.01;

      if (!mounted) return;
      setState(() {
        _currentLat = pos.latitude;
        _currentLng = pos.longitude;
        _patientLat = patientLat;
        _patientLng = patientLng;
        _loading = false;
      });

      _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _updateDriverLocation();
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _updateDriverLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      await FirebaseDatabase.instance
          .ref('emergency_requests/${widget.request['id']}')
          .update({
        'driverLocation': {
          'lat': pos.latitude,
          'lng': pos.longitude,
        },
      });

      if (!mounted) return;
      setState(() {
        _currentLat = pos.latitude;
        _currentLng = pos.longitude;
      });
    } catch (e) {
      debugPrint('Location update error: $e');
    }
  }

  void _markArrived() async {
    setState(() => _status = 'arrived');

    await FirebaseDatabase.instance
        .ref('emergency_requests/${widget.request['id']}')
        .update({'status': 'arrived'});
  }

  void _completeTrip() async {
    try {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(color: successGreen),
          ),
        );
      }

      await FirebaseDatabase.instance
          .ref('emergency_requests/${widget.request['id']}')
          .update({
        'status': 'completed',
        'completedAt': ServerValue.timestamp,
      });

      if (!mounted) return;
      Navigator.pop(context); // Pop dialog
      Navigator.pop(context); // Pop navigation screen
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete trip: $e')),
        );
      }
    }
  }

  void _openMapsNavigation() async {
    if (_patientLat == null || _patientLng == null) return;

    final url = 'google.navigation:q=$_patientLat,$_patientLng&mode=d';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final webUrl = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$_patientLat,$_patientLng&travelmode=driving');
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepIndigo,
      body: _loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: primaryRed),
                  const SizedBox(height: 20),
                  Text(
                    'Initializing Navigation...',
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Full Screen Mock Map
                MockMapView(
                  showRoute: true,
                  primaryColor: primaryRed,
                  markers: [
                    if (_currentLat != null && _currentLng != null)
                      const MockMarker(
                        x: 150,
                        y: 300,
                        icon: Icons.navigation,
                        color: Colors.blueAccent,
                        label: 'You',
                      ),
                    if (_patientLat != null && _patientLng != null)
                      const MockMarker(
                        x: 100,
                        y: 100,
                        icon: Icons.person_pin,
                        color: primaryRed,
                        label: 'Patient',
                      ),
                  ],
                ),

                // Premium Gradient Overlay for depth
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          deepIndigo.withOpacity(0.8),
                          Colors.transparent,
                          Colors.transparent,
                          deepIndigo.withOpacity(0.9),
                        ],
                        stops: const [0.0, 0.2, 0.7, 1.0],
                      ),
                    ),
                  ),
                ),

                // Top Instruction Bar
                SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_back,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _status == 'arrived' ? 'ARRIVED' : 'EN ROUTE',
                                  style: GoogleFonts.rajdhani(
                                    color: primaryRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Text(
                                  _status == 'arrived'
                                      ? 'Assist Patient Now'
                                      : 'Head to Emergency',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryRed.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: primaryRed.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: primaryRed, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '$_etaMinutes MIN',
                                  style: GoogleFonts.rajdhani(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Floating Map Switcher
                Positioned(
                  top: 120,
                  right: 16,
                  child: Column(
                    children: [
                      _buildFloatingAction(
                        icon: Icons.map_outlined,
                        onTap: _openMapsNavigation,
                        label: 'G-Maps',
                      ),
                      const SizedBox(height: 12),
                      _buildFloatingAction(
                        icon: Icons.my_location,
                        onTap: () {}, // Recenter
                        label: 'Recenter',
                      ),
                    ],
                  ),
                ),

                // Bottom Patient Info Card
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          deepIndigo.withOpacity(0.0),
                          deepIndigo.withOpacity(0.95),
                          deepIndigo,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Patient Card
                        GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [primaryRed, accentRed],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryRed.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.person,
                                    color: Colors.white, size: 32),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.request['patientName'] ??
                                          'Emergency Patient',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on,
                                            color: primaryRed, size: 14),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            widget.request['location']
                                                    ?['address'] ??
                                                'Kakuma Camp, Block B',
                                            style: GoogleFonts.dmSans(
                                              color: Colors.white70,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              _buildCircularAction(
                                icon: Icons.phone,
                                color: successGreen,
                                onTap: () {
                                  final phone = widget.request['phone'];
                                  if (phone != null) {
                                    launchUrl(Uri.parse('tel:$phone'));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildMainButton(
                                text: _status == 'arrived'
                                    ? 'COMPLETE TRIP'
                                    : 'I HAVE ARRIVED',
                                color: _status == 'arrived'
                                    ? successGreen
                                    : primaryRed,
                                onTap: _status == 'arrived'
                                    ? _completeTrip
                                    : _markArrived,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: _buildSecondaryButton(
                                text: 'CANCEL',
                                onTap: () => _confirmCancel(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFloatingAction(
      {required IconData icon,
      required VoidCallback onTap,
      required String label}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: deepIndigo.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.rajdhani(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCircularAction(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildMainButton(
      {required String text,
      required Color color,
      required VoidCallback onTap}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
      {required String text, required VoidCallback onTap}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.rajdhani(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: deepIndigo.withOpacity(0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          title: Text(
            'Abort Mission?',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Cancelling an active emergency response is high risk. Are you sure?',
            style: GoogleFonts.dmSans(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('CONTINUE RESPONSE',
                  style: TextStyle(color: successGreen)),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseDatabase.instance
                    .ref('emergency_requests/${widget.request['id']}')
                    .update({'status': 'cancelled'});
                if (!mounted) return;
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text('ABORT', style: TextStyle(color: primaryRed)),
            ),
          ],
        ),
      ),
    );
  }
}
