import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ref_qeueu/services/auth_service.dart';

class RefugeeLoginScreenNew extends StatefulWidget {
  const RefugeeLoginScreenNew({super.key});

  @override
  State<RefugeeLoginScreenNew> createState() => _RefugeeLoginScreenNewState();
}

class _RefugeeLoginScreenNewState extends State<RefugeeLoginScreenNew> {
  bool _isLoading = false;
  List<Map<String, String>> _rememberedAccounts = [];

  @override
  void initState() {
    super.initState();
    _checkRememberedAccounts();
  }

  Future<void> _checkRememberedAccounts() async {
    final accounts = await AuthService().getRememberedAccounts();
    if (mounted) setState(() => _rememberedAccounts = accounts);
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() => _isLoading = true);
    String? error;
    try {
      if (provider == 'Google') {
        error = await AuthService().signInWithGoogle();
      } else if (provider == 'Apple') {
        error = await AuthService().signInWithApple();
      }
      if (mounted) {
        if (error == null) {
          Navigator.pushReplacementNamed(context, '/refugee_home');
        } else {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBiometricLogin() async {
    setState(() => _isLoading = true);
    final success = await AuthService().authenticateWithBiometrics();
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pushReplacementNamed(context, '/refugee_home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Biometric authentication failed or cancelled')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safeTop = MediaQuery.of(context).padding.top;
    final blueH = size.height * 0.44;
    final cardTop = size.height * 0.34;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── UNHCR Blue top area ──
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
                  colors: [Color(0xFF001F47), Color(0xFF0072BC)],
                ),
              ),
            ),
          ),

          // ── Refugee illustration ──
          Positioned(
            top: safeTop + 54,
            left: 48,
            right: 48,
            height: blueH - safeTop - 58,
            child: Image.asset(
              'assets/illustrations/refugee_final.png',
              fit: BoxFit.contain,
            ),
          ),

          // ── White sign-in card ──
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF001F47),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to access your health profile and queue.',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: const Color(0xFF5A7A8A),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Primary: Phone Number
                      _PrimaryButton(
                        icon: Icons.phone_android_rounded,
                        label: 'Continue with Phone Number',
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.pushReplacementNamed(
                                context,
                                '/production_phone_login_refugee'),
                      ),

                      const SizedBox(height: 20),

                      // Divider
                      Row(children: [
                        Expanded(child: Divider(color: Colors.grey.shade200)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: GoogleFonts.dmSans(
                              color: const Color(0xFFADBCC8),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade200)),
                      ]),

                      const SizedBox(height: 20),

                      // Google
                      _SecondaryButton(
                        icon: Icons.g_mobiledata_rounded,
                        label: 'Continue with Google',
                        onPressed: _isLoading
                            ? null
                            : () => _handleSocialLogin('Google'),
                      ),

                      const SizedBox(height: 12),

                      // Biometric
                      _SecondaryButton(
                        icon: Icons.fingerprint_rounded,
                        label: 'Use Fingerprint / Face ID',
                        onPressed: _isLoading ? null : _handleBiometricLogin,
                      ),

                      if (_rememberedAccounts.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _SecondaryButton(
                          icon: Icons.switch_account_rounded,
                          label: 'Switch to Saved Account',
                          onPressed: () => Navigator.pushNamed(
                              context, '/account_selector'),
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Register link
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Don't have an account?  ",
                              style: GoogleFonts.dmSans(
                                color: const Color(0xFF7A9AAA),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                  context, '/auth/refugee_signup'),
                              child: Text(
                                'Register',
                                style: GoogleFonts.dmSans(
                                  color: const Color(0xFF0072BC),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Back button ──
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.white.withOpacity(0.35)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),

          // ── Loading overlay ──
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.35),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF0072BC)),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Large filled pill button (primary CTA) ──
class _PrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryButton(
      {required this.icon, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0072BC),
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: const Color(0x660072BC),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(29)),
        ),
      ),
    );
  }
}

// ── Light outlined button (secondary option) ──
class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _SecondaryButton(
      {required this.icon, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: const Color(0xFF0072BC)),
        label: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF001F47),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFD0E4F4), width: 1.5),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27)),
          backgroundColor: const Color(0xFFF8FBFE),
        ),
      ),
    );
  }
}
