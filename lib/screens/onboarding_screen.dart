import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_PageData> pages = const [
    _PageData(
      image: "assets/illustrations/welcome.png",
      title: "Welcome",
      subtitle:
          "A smarter way for refugees to access health services without waiting in long lines.",
    ),
    _PageData(
      image: "assets/illustrations/problem.png",
      title: "The Problem",
      subtitle:
          "Refugees spend hours in queues under the scorching sun, unsure when they will be served.",
    ),
    _PageData(
      image: "assets/illustrations/solution.png",
      title: "Our Solution",
      subtitle:
          "This app places you automatically in the hospital queue using your location — no more waiting outside.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Precache all images for smooth transitions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        for (final page in pages) {
          try {
            precacheImage(AssetImage(page.image), context);
          } catch (e) {
            // Ignore precache errors - images will load normally
          }
        }
      }
    });
  }

  /// -------------------------------
  /// 👇 IMPORTANT PART IS RIGHT HERE
  /// -------------------------------
  void _next() {
    if (_index < pages.length - 1) {
      _controller.animateToPage(
        _index + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    } else {
      // LAST PAGE → Go to Role Selection explicitly
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/role_selection', // <--- CHANGED FROM '/' TO MATCH ROUTE MAP
        (route) => false,
      );
    }
  }

  /// -------------------------------

  void _skip() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/role_selection', // <--- CHANGED FROM '/' TO MATCH ROUTE MAP
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F4F1),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skip,
                    child: const Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) {
                  final page = pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // IMAGE - Preloaded for smooth display
                        Expanded(
                          child: Image.asset(
                            page.image,
                            fit: BoxFit.contain,
                            cacheWidth: 800, // Optimize image loading
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image_not_supported,
                                    size: 100, color: Colors.grey),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // TITLE
                        Text(
                          page.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // SUBTITLE
                        Text(
                          page.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),

            // DOT INDICATORS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _index == i ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i ? Colors.teal : Colors.teal.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _index == pages.length - 1 ? "Get Started" : "Next",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 20),
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

  const _PageData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}
