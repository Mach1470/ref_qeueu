import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ref_qeueu/services/auth_service.dart';

class RefugeeLoginScreenNew extends StatefulWidget {
  const RefugeeLoginScreenNew({super.key});

  @override
  State<RefugeeLoginScreenNew> createState() => _RefugeeLoginScreenNewState();
}

class _RefugeeLoginScreenNewState extends State<RefugeeLoginScreenNew> {
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleGoogle() async {
    setState(() => _isLoading = true);
    try {
      final error = await AuthService().signInWithGoogle();
      if (mounted) {
        if (error == null) {
          Navigator.pushReplacementNamed(context, '/refugee_home');
        } else {
          _showError(error);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleApple() async {
    setState(() => _isLoading = true);
    try {
      final error = await AuthService().signInWithApple();
      if (mounted) {
        if (error == null) {
          Navigator.pushReplacementNamed(context, '/refugee_home');
        } else {
          _showError(error);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDemo() async {
    setState(() => _isLoading = true);
    try {
      final error = await AuthService().signInAsDemo();
      if (mounted) {
        if (error == null) {
          Navigator.pushReplacementNamed(context, '/refugee_home');
        } else {
          _showError(error);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final error = await AuthService().signInWithEmailOrId(
        idOrEmail: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: 'refugee',
      );
      if (mounted) {
        if (error == null) {
          Navigator.pushReplacementNamed(context, '/refugee_home');
        } else {
          _showError(error);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safeTop = MediaQuery.of(context).padding.top;
    final blueH = size.height * 0.40;
    final cardTop = size.height * 0.30;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Blue top panel ──
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

          // ── Illustration ──
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
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back!',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF001F47),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to access your health profile and queue.',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: const Color(0xFF5A7A8A),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Google ──
                      _SocialButton(
                        faIcon: FontAwesomeIcons.google,
                        label: 'Continue with Google',
                        backgroundColor: const Color(0xFF0072BC),
                        foregroundColor: Colors.white,
                        onPressed: _isLoading ? null : _handleGoogle,
                      ),

                      const SizedBox(height: 12),

                      // ── Apple ──
                      _SocialButton(
                        faIcon: FontAwesomeIcons.apple,
                        label: 'Continue with Apple',
                        backgroundColor: const Color(0xFF1C1C1E),
                        foregroundColor: Colors.white,
                        onPressed: _isLoading ? null : _handleApple,
                      ),

                      const SizedBox(height: 24),

                      // ── OR divider ──
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

                      const SizedBox(height: 24),

                      // ── Email / Password form ──
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _InputField(
                              controller: _emailCtrl,
                              hint: 'Email or Individual ID',
                              icon: Icons.person_outline_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Required'
                                      : null,
                            ),
                            const SizedBox(height: 12),
                            _InputField(
                              controller: _passwordCtrl,
                              hint: 'Password',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: const Color(0xFFADBCC8),
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (v) =>
                                  (v == null || v.length < 6)
                                      ? 'Min 6 characters'
                                      : null,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Sign In button ──
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleEmailSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0072BC),
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: const Color(0x440072BC),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                          ),
                          child: Text(
                            'Sign In',
                            style: GoogleFonts.poppins(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Register link ──
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

                      const SizedBox(height: 20),

                      // ── Demo access ──
                      Center(
                        child: GestureDetector(
                          onTap: _isLoading ? null : _handleDemo,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color(0xFFE0EAF0)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Try Demo  →',
                              style: GoogleFonts.dmSans(
                                color: const Color(0xFF5A7A8A),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Back button (Positioned to fix Stack sizing) ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.35)),
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
            ),
          ),

          // ── Loading overlay ──
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0072BC)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Social auth button ──
class _SocialButton extends StatelessWidget {
  final FaIconData faIcon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.faIcon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(faIcon, size: 16, color: foregroundColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600, color: foregroundColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Text input field ──
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.dmSans(fontSize: 15, color: const Color(0xFF001F47)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            GoogleFonts.dmSans(fontSize: 15, color: const Color(0xFFADBCC8)),
        prefixIcon: Icon(icon, color: const Color(0xFFADBCC8), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF5F8FB),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFE0EAF0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF0072BC), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }
}
