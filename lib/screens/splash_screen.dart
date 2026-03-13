import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';
import '../widgets/logo_avatar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _startInitialization();
  }

  @override
  void dispose() {
    _orbController.dispose();
    super.dispose();
  }

  Future<void> _startInitialization() async {
    // Artificial delay to show off the "Beautiful Loading" UX
    await Future.delayed(const Duration(seconds: 3));
    await _decideNavigation();
  }

  Future<void> _decideNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('has_seen_onboarding') ?? false;
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final rememberedRole = prefs.getString('remembered_role');

    if (!mounted) return;

    if (!hasSeen) {
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    if (isLoggedIn) {
      // Check for security lock
      final security = SecurityService.instance;
      if (await security.isBiometricsEnabled() || await security.isPinEnabled()) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/auth_lock');
          return;
        }
      }

      final route = await AuthService().getSavedRoute();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, route ?? '/role_selection');
      return;
    }

    if (rememberedRole != null) {
      switch (rememberedRole) {
        case 'refugee':
          Navigator.pushReplacementNamed(context, '/auth/refugee_login');
          return;
        case 'ambulance':
          Navigator.pushReplacementNamed(context, '/ambulance_request');
          return;
        default:
          Navigator.pushReplacementNamed(context, '/role_selection');
          return;
      }
    }

    Navigator.pushReplacementNamed(context, '/role_selection');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                ],
              ),
            ),
          ),

          // Animated Orbs (Premium background)
          AnimatedBuilder(
            animation: _orbController,
            builder: (context, child) {
              return Stack(
                children: [
                  _buildOrb(
                    color: const Color(0xFF386BB8).withOpacity(0.15),
                    size: 400,
                    offset: Offset(
                      100 * (1 + 0.2 * (0.5 - _orbController.value).abs()),
                      -50,
                    ),
                  ),
                  _buildOrb(
                    color: const Color(0xFFE11D48).withOpacity(0.1),
                    size: 300,
                    offset: Offset(
                      MediaQuery.of(context).size.width - 200,
                      MediaQuery.of(context).size.height - 250,
                    ),
                  ),
                ],
              );
            },
          ),

          // Glassmorphic Content
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 280,
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo with pulse animation
                      const LogoAvatar(size: 100)
                          .animate(onPlay: (c) => c.repeat())
                          .shimmer(duration: 2000.ms, color: Colors.white24)
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.05, 1.05),
                            duration: 1500.ms,
                            curve: Curves.easeInOut,
                          )
                          .then()
                          .scale(
                            begin: const Offset(1.05, 1.05),
                            end: const Offset(1, 1),
                            duration: 1500.ms,
                            curve: Curves.easeInOut,
                          ),
                      const SizedBox(height: 32),

                      // App Name
                      Text(
                        'MYQUEUE',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4,
                          color: Colors.white,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .slideY(begin: 0.2, end: 0),

                      const SizedBox(height: 12),

                      // Slogan
                      Text(
                        'Efficiency in Care',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white60,
                          letterSpacing: 1.2,
                        ),
                      ).animate().fadeIn(delay: 600.ms),

                      const SizedBox(height: 48),

                      // Custom Premium Loading Bar
                      _buildLoadingIndicator(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb(
      {required Color color, required double size, required Offset offset}) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 100,
              spreadRadius: 50,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 160,
            height: 4,
            child: LinearProgressIndicator(
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF386BB8)),
            ),
          ),
        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms),
        const SizedBox(height: 16),
        Text(
          'POWERING UP...',
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white38,
            letterSpacing: 2,
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .fadeIn(duration: 1000.ms)
            .then()
            .fadeOut(duration: 1000.ms),
      ],
    );
  }
}
