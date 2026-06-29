import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';

class RefugeeSignupScreen extends StatefulWidget {
  const RefugeeSignupScreen({super.key});

  @override
  State<RefugeeSignupScreen> createState() => _RefugeeSignupScreenState();
}

class _RefugeeSignupScreenState extends State<RefugeeSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  final AuthService _auth = AuthService();
  DateTime? _selectedDate;
  bool _isMinor = false;

  static const _blue = Color(0xFF0072BC);
  static const _navy = Color(0xFF001F47);
  static const _slate = Color(0xFF5A7A8A);
  static const _border = Color(0xFFE0EAF0);
  static const _fill = Color(0xFFF5F8FB);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _blue,
            onPrimary: Colors.white,
            onSurface: _navy,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobCtrl.text = picked.toLocal().toString().split(' ')[0];
        _isMinor = DateTime.now().difference(picked).inDays ~/ 365 < 18;
      });
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      _showError('Please select your date of birth');
      return;
    }
    setState(() => _loading = true);
    final raw = _phoneCtrl.text.trim();
    final phone = raw.isEmpty ? '' : (raw.startsWith('+') ? raw : '+254$raw');
    final error = await _auth.signUpBasic(
      name: _nameCtrl.text.trim(),
      dob: _dobCtrl.text.trim(),
      individualNumber: _idCtrl.text.trim(),
      phone: phone,
      password: _passwordCtrl.text,
      email: _emailCtrl.text.trim(),
    );
    setState(() => _loading = false);
    if (!mounted) return;
    if (error == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/refugee_home', (_) => false);
    } else {
      _showError(error);
    }
  }

  Future<void> _handleSocial(String provider) async {
    setState(() => _loading = true);
    try {
      final error = provider == 'Google'
          ? await AuthService().signInWithGoogle()
          : await AuthService().signInWithApple();
      if (mounted) {
        if (error == null) {
          Navigator.pushReplacementNamed(context, '/refugee_home');
        } else {
          _showError(error);
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FB),
      appBar: AppBar(
        title: Text(
          'Create Account',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Text(
                'Join MyQueue',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _navy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Create an account to access healthcare and track your queue.',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: _slate,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              // ── Social buttons ──
              Row(
                children: [
                  Expanded(
                    child: _SmallSocialButton(
                      faIcon: FontAwesomeIcons.google,
                      label: 'Google',
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      onPressed: _loading ? null : () => _handleSocial('Google'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SmallSocialButton(
                      faIcon: FontAwesomeIcons.apple,
                      label: 'Apple',
                      backgroundColor: const Color(0xFF1C1C1E),
                      foregroundColor: Colors.white,
                      onPressed: _loading ? null : () => _handleSocial('Apple'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── OR divider ──
              Row(children: [
                Expanded(child: Divider(color: Colors.grey.shade200)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    'OR REGISTER WITH EMAIL',
                    style: GoogleFonts.dmSans(
                      color: const Color(0xFFADBCC8),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade200)),
              ]),

              const SizedBox(height: 20),

              // ── Form card ──
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _Field(
                      controller: _nameCtrl,
                      label: 'Full Name',
                      hint: 'John Doe',
                      icon: Icons.person_outline_rounded,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      controller: _idCtrl,
                      label: 'Individual Number (ID)',
                      hint: '123-45678',
                      icon: Icons.badge_outlined,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: _Field(
                          controller: _dobCtrl,
                          label: 'Date of Birth',
                          hint: 'YYYY-MM-DD',
                          icon: Icons.calendar_today_outlined,
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      controller: _phoneCtrl,
                      label: 'Phone Number',
                      hint: '712 345 678',
                      icon: Icons.phone_android_outlined,
                      prefix: '+254',
                      inputType: TextInputType.phone,
                      validator: (v) {
                        if (_isMinor && (v == null || v.isEmpty)) return null;
                        if (v != null && v.isNotEmpty && v.length < 9) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      controller: _emailCtrl,
                      label: 'Email (optional)',
                      hint: 'email@example.com',
                      icon: Icons.email_outlined,
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      controller: _passwordCtrl,
                      label: 'Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscure,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: const Color(0xFFADBCC8),
                          size: 18,
                        ),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) =>
                          (v == null || v.length < 6) ? 'Min 6 characters' : null,
                    ),
                    const SizedBox(height: 14),
                    _Field(
                      controller: _confirmCtrl,
                      label: 'Confirm Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscure: _obscure,
                      validator: (v) =>
                          v != _passwordCtrl.text ? 'Passwords do not match' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Submit button ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: const Color(0x440072BC),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text(
                          'Create Account',
                          style: GoogleFonts.poppins(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Login link ──
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Already have an account?  ',
                      style: GoogleFonts.dmSans(
                          color: _slate, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Sign in',
                        style: GoogleFonts.dmSans(
                          color: _blue,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Small horizontal social button (used side-by-side) ──
class _SmallSocialButton extends StatelessWidget {
  final FaIconData faIcon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;

  const _SmallSocialButton({
    required this.faIcon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(faIcon, size: 14, color: foregroundColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Form field ──
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? prefix;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType inputType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.prefix,
    this.obscure = false,
    this.suffixIcon,
    this.inputType = TextInputType.text,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF5A7A8A),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: inputType,
          validator: validator,
          style: GoogleFonts.dmSans(
              fontSize: 14, color: const Color(0xFF001F47)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
                fontSize: 14, color: const Color(0xFFADBCC8)),
            prefixIcon:
                Icon(icon, color: const Color(0xFFADBCC8), size: 18),
            prefixText: prefix != null ? '$prefix ' : null,
            prefixStyle: GoogleFonts.dmSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF001F47),
                fontSize: 14),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF5F8FB),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFE0EAF0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF0072BC), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
