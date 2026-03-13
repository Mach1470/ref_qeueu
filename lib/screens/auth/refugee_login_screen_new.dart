import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ref_qeueu/services/auth_service.dart';
import 'package:ref_qeueu/widgets/logo_avatar.dart';
import 'package:ref_qeueu/widgets/glass_widgets.dart';

class RefugeeLoginScreenNew extends StatefulWidget {
  const RefugeeLoginScreenNew({super.key});

  @override
  State<RefugeeLoginScreenNew> createState() => _RefugeeLoginScreenNewState();
}

class _RefugeeLoginScreenNewState extends State<RefugeeLoginScreenNew> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController(); // Phone or ID
  final _pinCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;
  List<Map<String, String>> _rememberedAccounts = [];

  @override
  void initState() {
    super.initState();
    _checkRememberedAccounts();
  }

  Future<void> _checkRememberedAccounts() async {
    final accounts = await AuthService().getRememberedAccounts();
    if (mounted) {
      setState(() => _rememberedAccounts = accounts);
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final identifier = _identifierCtrl.text.trim();
      await Future.delayed(const Duration(seconds: 1));

      if (identifier.isNotEmpty) {
        await AuthService().saveRefugeeLogin(
          identifier,
          displayName: 'Refugee User',
          demoId: identifier,
          queuePosition: 3,
        );

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/refugee_home');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E3A8A), // Deep Blue
                  Color(0xFF312E81), // Indigo
                  Color(0xFF4C1D95), // Deep Purple
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Decorative Blobs
          Positioned(
            top: -50,
            right: -50,
            child: _AnimatedBlob(
              color: Colors.blue.withOpacity(0.2),
              size: 250,
            ),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: _AnimatedBlob(
              color: Colors.purple.withOpacity(0.2),
              size: 300,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const LogoAvatar(size: 80),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your details to access your queue.',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: Colors.amber, size: 14),
                        const SizedBox(width: 8),
                        Text(
                          'DEMO MODE ACTIVE',
                          style: GoogleFonts.dmSans(
                            color: Colors.amber,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 40 * (1 - value)),
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: GlassCard(
                        padding: const EdgeInsets.all(32),
                        borderRadius: BorderRadius.circular(32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Text(
                                'Authorized Access',
                                style: GoogleFonts.dmSans(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 2,
                                width: 40,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.blueAccent,
                                      Colors.purpleAccent
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildTextField(
                                controller: _identifierCtrl,
                                label: 'PH Number / Identity ID',
                                hint: '+254... or 123456',
                                icon: Icons.person_rounded,
                              ),
                              const SizedBox(height: 24),
                              _buildTextField(
                                controller: _pinCtrl,
                                label: 'Secure Access PIN',
                                hint: 'Enter your PIN',
                                icon: Icons.vpn_key_rounded,
                                isPassword: true,
                                obscureText: _isObscure,
                                onToggleVisibility: () =>
                                    setState(() => _isObscure = !_isObscure),
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Reset Credentials",
                                    style: GoogleFonts.dmSans(
                                      color: const Color(0xFF60A5FA),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Container(
                                width: double.infinity,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF4F46E5)
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1)
                                          .withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Authenticate',
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 20),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_rememberedAccounts.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton.icon(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/account_selector'),
                        icon: const Icon(Icons.switch_account_rounded,
                            color: Colors.white70),
                        label: Text(
                          'Switch to Saved Account',
                          style: GoogleFonts.dmSans(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.dmSans(color: Colors.white60),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/auth/refugee_signup');
                        },
                        child: Text(
                          'Register',
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF60A5FA),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (kDebugMode) ...[
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          await AuthService().saveRefugeeLogin(
                            '+000000000',
                            displayName: 'Debug User',
                            demoId: 'debug-001',
                            queuePosition: 1,
                          );
                          if (mounted) {
                            Navigator.pushReplacementNamed(
                                context, '/refugee_home');
                          }
                        },
                        child: Text(
                          '[DEBUG] Quick Login',
                          style: GoogleFonts.dmSans(
                              color: Colors.redAccent.withOpacity(0.8)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(color: Colors.white24),
            prefixIcon: Icon(icon, color: Colors.indigo[200], size: 22),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.white54,
                      size: 20,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
          ),
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}

class _AnimatedBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _AnimatedBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 4),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 100,
                spreadRadius: 50,
              ),
            ],
          ),
        );
      },
    );
  }
}
