import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _index = 0;
  late AnimationController _orbController;

  final List<_PageData> pages = const [
    _PageData(
      image: 'assets/illustrations/welcome.png',
      title: 'Welcome',
      subtitle: 'Get started with our app',
    ),
    _PageData(
      image: 'assets/illustrations/problem.png',
      title: 'The Challenge',
      subtitle:
          'Individuals often spend hours in queues under harsh conditions.',
    ),
    _PageData(
      image: 'assets/illustrations/solution.png',
      title: 'Our Digital Solution',
      subtitle:
          'This app places you automatically in the health facility\'s queue.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        for (final p in pages) {
          try {
            precacheImage(AssetImage(p.image), context);
          } catch (_) {}
        }
      }
    });
  }

  @override
  void dispose() {
    _orbController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < pages.length - 1) {
      _controller.animateToPage(
        _index + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    } else {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('has_seen_onboarding', true);
      });
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, '/role_selection', (r) => false);
    }
  }

  void _skip() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('has_seen_onboarding', true);
    });
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/role_selection', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
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
                    color: const Color(0xFF386BB8).withAlpha(38),
                    size: 400,
                    offset: Offset(
                      100 * (1 + 0.2 * (0.5 - _orbController.value).abs()),
                      -50,
                    ),
                  ),
                  _buildOrb(
                    color: const Color(0xFFE11D48).withAlpha(25),
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

          SafeArea(
            child: Column(
              children: [
                // Skip Button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _skip,
                        child: Text(
                          'Skip',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),

                // Main Content
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: pages.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) {
                      final page = pages[i];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App Name / Logo subtly at top
                          Text(
                            'MYQUEUE',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4,
                              color: Colors.white38,
                            ),
                          ).animate().fadeIn(delay: 500.ms),
                          const SizedBox(height: 48),

                          // Illustration (blended with background)
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 40.0),
                              child: Image.asset(
                                page.image,
                                fit: BoxFit.contain,
                              )
                                  .animate()
                                  .fadeIn(
                                      duration: 800.ms, curve: Curves.easeOut)
                                  .slideY(
                                      begin: 0.1,
                                      end: 0,
                                      curve: Curves.easeOut),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Glassmorphic Info Panel
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 15, sigmaY: 15),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(32),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withAlpha(13), // 0.05
                                        borderRadius: BorderRadius.circular(32),
                                        border: Border.all(
                                          color:
                                              Colors.white.withAlpha(25), // 0.1
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            page.title,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              height: 1.2,
                                            ),
                                          )
                                              .animate()
                                              .fadeIn(delay: 300.ms)
                                              .slideY(begin: 0.2, end: 0),
                                          const SizedBox(height: 16),
                                          Text(
                                            page.subtitle,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 15,
                                              color: Colors.white70,
                                              height: 1.5,
                                            ),
                                          ).animate().fadeIn(delay: 500.ms),
                                          const Spacer(),

                                          // Indicators
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: List.generate(
                                              pages.length,
                                              (j) => AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                curve: Curves.easeInOut,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4),
                                                height: 8,
                                                width: _index == j ? 24 : 8,
                                                decoration: BoxDecoration(
                                                  color: _index == j
                                                      ? const Color(0xFF386BB8)
                                                      : Colors.white
                                                          .withAlpha(51), // 0.2
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 32),

                                          // Action Button
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: _next,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF386BB8),
                                                foregroundColor: Colors.white,
                                                elevation: 8,
                                                shadowColor:
                                                    const Color(0xFF386BB8)
                                                        .withAlpha(128), // 0.5
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: Text(
                                                _index < pages.length - 1
                                                    ? 'Next Step'
                                                    : 'Get Started',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  letterSpacing: 1,
                                                ),
                                              ),
                                            ),
                                          ).animate().fadeIn(delay: 600.ms),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20), // Bottom padding
                        ],
                      );
                    },
                  ),
                ),
              ],
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
}

class _PageData {
  final String image;
  final String title;
  final String subtitle;
  const _PageData(
      {required this.image, required this.title, required this.subtitle});
}
