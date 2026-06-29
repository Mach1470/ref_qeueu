import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const List<_PageData> _pages = [
    _PageData(
      image: 'assets/illustrations/welcome.png',
      title: 'Healthcare at\nYour Fingertips',
      subtitle:
          "Join your clinic queue from your phone and get notified when it's your turn — no waiting in the sun.",
    ),
    _PageData(
      image: 'assets/illustrations/problem.png',
      title: 'No More\nLong Waits',
      subtitle:
          'See your real-time position at nearby UNHCR health facilities. Save hours every visit.',
    ),
    _PageData(
      image: 'assets/illustrations/solution.png',
      title: 'Care for Your\nWhole Family',
      subtitle:
          'Register household members and request emergency ambulance services — all in one place.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final p in _pages) {
        try {
          precacheImage(AssetImage(p.image), context);
        } catch (_) {}
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < _pages.length - 1) {
      _controller.animateToPage(
        _index + 1,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/role_selection', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safeTop = MediaQuery.of(context).padding.top;
    final blueH = size.height * 0.54;
    final cardTop = size.height * 0.44;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Blue illustration panel ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: blueH,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0072BC), Color(0xFF004F8C)],
                ),
              ),
            ),
          ),

          // ── Swipeable illustrations ──
          Positioned(
            top: safeTop + 58,
            left: 0,
            right: 0,
            height: blueH - safeTop - 62,
            child: PageView.builder(
              controller: _controller,
              itemCount: _pages.length,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
                child: Image.asset(
                  _pages[i].image,
                  fit: BoxFit.contain,
                )
                    .animate(key: ValueKey('img$i'))
                    .fadeIn(duration: 420.ms)
                    .scaleXY(
                      begin: 0.88,
                      end: 1.0,
                      duration: 500.ms,
                      curve: Curves.easeOut,
                    ),
              ),
            ),
          ),

          // ── White content card ──
          Positioned(
            top: cardTop,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A0072BC),
                    blurRadius: 32,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dot page indicators
                      Row(
                        children: List.generate(_pages.length, (j) {
                          final active = _index == j;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: active ? 28 : 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFF0072BC)
                                  : const Color(0xFFCBDBEB),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 22),

                      // Slide title
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.12),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(
                              parent: anim,
                              curve: Curves.easeOut,
                            )),
                            child: child,
                          ),
                        ),
                        child: Align(
                          key: ValueKey('title$_index'),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _pages[_index].title,
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF001F47),
                              height: 1.25,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Slide subtitle
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        child: Align(
                          key: ValueKey('sub$_index'),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _pages[_index].subtitle,
                            style: GoogleFonts.dmSans(
                              fontSize: 15,
                              color: const Color(0xFF5A7A8A),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Continue / Get Started pill button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0072BC),
                            foregroundColor: Colors.white,
                            elevation: 6,
                            shadowColor: const Color(0x660072BC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            _index < _pages.length - 1
                                ? 'Continue'
                                : 'Get Started',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Skip link — hidden on last slide
                      if (_index < _pages.length - 1)
                        Center(
                          child: TextButton(
                            onPressed: _finish,
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF90A4AE),
                            ),
                            child: Text(
                              'Skip',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 44),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── MyQueue logo row (over blue area) ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
            bottom: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/illustrations/app_logo.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'MyQueue',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      'UNHCR',
                      style: GoogleFonts.dmSans(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
        ],
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
