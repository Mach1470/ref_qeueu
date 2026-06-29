import 'dart:async';
import 'dart:math' as math;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/offline_sync_service.dart';
import '../services/security_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _startInitialization();
  }

  @override
  void dispose() {
    _orbController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _startInitialization() async {
    // Flush any offline queue if online
    try {
      final results = await Connectivity().checkConnectivity();
      final online = results.any((r) => r != ConnectivityResult.none);
      if (!mounted) return;
      final sync = context.read<OfflineSyncService>();
      if (online) unawaited(sync.flush());
    } catch (_) {}

    // Minimum display time so the splash feels intentional
    await Future.delayed(const Duration(milliseconds: 2200));
    await _decideNavigation();
  }

  Future<void> _decideNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('has_seen_onboarding') ?? false;

    if (!mounted) return;

    if (!hasSeen) {
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    // Firebase Auth persists sessions across app restarts — check it first
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      // Sync local state to match Firebase session
      await prefs.setBool('is_logged_in', true);
      if (prefs.getString('user_role') == null) {
        await prefs.setString('user_role', 'refugee');
      }
      final security = SecurityService.instance;
      if (await security.isBiometricsEnabled() || await security.isPinEnabled()) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/auth_lock');
          return;
        }
      }
      final route = await AuthService().getSavedRoute();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, route ?? '/refugee_home');
      return;
    }

    // No Firebase session — check local flag and remembered role
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final rememberedRole = prefs.getString('remembered_role');

    if (isLoggedIn) {
      final route = await AuthService().getSavedRoute();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, route ?? '/role_selection');
      return;
    }

    // Return user to their role's login screen
    if (rememberedRole != null) {
      switch (rememberedRole) {
        case 'refugee':
          if (mounted) Navigator.pushReplacementNamed(context, '/auth/refugee_login');
          return;
        case 'ambulance':
          if (mounted) Navigator.pushReplacementNamed(context, '/ambulance_request');
          return;
        default:
          if (mounted) Navigator.pushReplacementNamed(context, '/role_selection');
          return;
      }
    }

    if (mounted) Navigator.pushReplacementNamed(context, '/role_selection');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF001530),
      body: Stack(
        children: [
          // ── Deep gradient background ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF001530), // UNHCR Navy
                  Color(0xFF002147), // UNHCR Deep Navy
                  Color(0xFF003D7A), // UNHCR Deep Blue
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // ── Animated background orbs ──
          AnimatedBuilder(
            animation: _orbController,
            builder: (context, _) {
              final t = _orbController.value;
              return Stack(
                children: [
                  // Top-left orb
                  Positioned(
                    top: -80 + 30 * math.sin(t * 2 * math.pi),
                    left: -60 + 20 * math.cos(t * 2 * math.pi),
                    child: _Orb(
                      color: const Color(0xFF0072BC).withOpacity(0.25),
                      size: 320,
                    ),
                  ),
                  // Bottom-right orb
                  Positioned(
                    bottom: -100 + 25 * math.cos(t * 2 * math.pi),
                    right: -80 + 20 * math.sin(t * 2 * math.pi),
                    child: _Orb(
                      color: const Color(0xFF0060A9).withOpacity(0.2),
                      size: 360,
                    ),
                  ),
                  // Centre accent orb
                  Positioned(
                    top: size.height * 0.38 + 15 * math.sin(t * math.pi),
                    left: size.width * 0.5 - 100,
                    child: _Orb(
                      color: const Color(0xFFFCBE11).withOpacity(0.1),
                      size: 200,
                    ),
                  ),
                ],
              );
            },
          ),

          // ── Main content ──
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing logo container
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0072BC).withOpacity(0.4),
                        blurRadius: 60,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Image.asset(
                        'assets/illustrations/app_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 700.ms, curve: Curves.easeOut)
                    .scale(
                      begin: const Offset(0.6, 0.6),
                      end: const Offset(1.0, 1.0),
                      duration: 900.ms,
                      curve: Curves.elasticOut,
                    ),

                const SizedBox(height: 36),

                // App name
                Text(
                  'MyQueue',
                  style: GoogleFonts.poppins(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    height: 1.1,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 600.ms)
                    .slideY(begin: 0.3, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Efficiency in Care',
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.55),
                    letterSpacing: 2.5,
                  ),
                ).animate().fadeIn(delay: 600.ms, duration: 700.ms),
              ],
            ),
          ),

          // ── Pulsing loading dots at the bottom ──
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Column(
              children: [
                _LoadingDots()
                    .animate()
                    .fadeIn(delay: 900.ms, duration: 600.ms),
                const SizedBox(height: 28),
                Text(
                  'UNHCR HEALTH PLATFORM',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.3),
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w600,
                  ),
                ).animate().fadeIn(delay: 1100.ms, duration: 800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pulsing three-dot loader ──
class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  final List<AnimationController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      _controllers.add(ctrl);
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) ctrl.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (_, __) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6 + _controllers[i].value * 6,
              decoration: BoxDecoration(
                color: Color.lerp(
                  Colors.white.withOpacity(0.3),
                  const Color(0xFFFCBE11),
                  _controllers[i].value,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          },
        );
      }),
    );
  }
}

// ── Background orb ──
class _Orb extends StatelessWidget {
  final Color color;
  final double size;
  const _Orb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 120,
            spreadRadius: 60,
          ),
        ],
      ),
    );
  }
}
