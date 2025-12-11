import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Light background color used by the onboarding bottom info panel.
const Color _lightBackground = Color(0xFFF6F7F9);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  // Data for pages
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

  void _next() {
    if (_index < pages.length - 1) {
      _controller.animateToPage(_index + 1,
          duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    } else {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('has_seen_onboarding', true);
      });
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/role_selection', (r) => false);
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
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: _skip, child: Text('Skip', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)))
              ]),
            ),

            Expanded(
              child: Builder(builder: (ctx) {
                // Limit excessive system text scaling on the onboarding screens
                // so large accessibility font settings don't break the layout.
                final mq = MediaQuery.of(ctx);
                final clampedScale = mq.textScaleFactor.clamp(1.0, 1.15);
                return MediaQuery(
                  data: mq.copyWith(textScaleFactor: clampedScale),
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: pages.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) {
                          final page = pages[i];
                          return Column(
                            children: [
                              // Image area with a large headline overlaid so illustration
                              // remains full-bleed while the headline "sits in" the image.
                              Expanded(
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.asset(
                                        page.image,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                                    ),

                                    // No overlaid headline: keep the illustration full-bleed
                                    // and render the page title/subtitle in the bottom panel
                                    // (prevents duplicated text and keeps layout consistent).
                                  ],
                                ),
                              ),

                              // Bottom info panel: light background separate from image
                              // with the purple subsection title and explanatory text.
                              Container(
                                width: double.infinity,
                                color: _lightBackground,
                                padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      page.title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(ctx).primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      page.subtitle,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[800],
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Indicators and button live in the bottom panel so that
                                    // large font scaling won't push them off-screen.
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(
                                        pages.length,
                                        (j) => AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          height: 8,
                                          width: _index == j ? 24 : 8,
                                          decoration: BoxDecoration(
                                            color: _index == j
                                                ? primaryColor
                                                : primaryColor.withAlpha((0.3 * 255).round()),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _next,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryColor,
                                          minimumSize: const Size.fromHeight(55),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        child: Text(
                                          _index < pages.length - 1 ? 'Next' : 'Get Started',
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                    },
                  ),
                );
              }),
            ),

            // Controls moved into the bottom info panel inside each page
            // to avoid duplication and keep layout stable under text scaling.
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
  const _PageData({required this.image, required this.title, required this.subtitle});
}

