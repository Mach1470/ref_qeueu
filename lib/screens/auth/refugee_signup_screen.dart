import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';


class RefugeeSignupScreen extends StatefulWidget {
  const RefugeeSignupScreen({super.key});

  @override
  State<RefugeeSignupScreen> createState() => _RefugeeSignupScreenState();
}

class _RefugeeSignupScreenState extends State<RefugeeSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  final AuthService _authService = AuthService();
  DateTime? _selectedDate;
  bool _isMinor = false;

  static const Color primaryBlue = Color(0xFFFCBE11); // UNHCR Gold
  static const Color textMain = Color(0xFF1E293B);

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              onSurface: textMain,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.toLocal()}".split(' ')[0];
        // Check age
        final age = DateTime.now().difference(picked).inDays ~/ 365;
        _isMinor = age < 18;
      });
    }
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select Date of Birth')),
        );
        return;
      }

      final rawPhone = _phoneController.text.trim();
      String phone = '';
      if (rawPhone.isNotEmpty) {
        phone = rawPhone.startsWith('+') ? rawPhone : '+254$rawPhone';
      } else if (_isMinor) {
        phone = '';
      }

      setState(() => _loading = true);

      final error = await _authService.signUpBasic(
        name: _nameController.text.trim(),
        dob: _dobController.text.trim(),
        individualNumber: _idController.text.trim(),
        phone: phone,
        password: _passwordController.text,
        email: _emailController.text.trim(),
      );

      setState(() => _loading = false);

      if (!mounted) return;

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Account created successfully!'),
              behavior: SnackBarBehavior.floating),
        );
        Navigator.pushNamedAndRemoveUntil(
            context, '/refugee_home', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _handleSocialSignup(String provider) async {
    setState(() => _loading = true);
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Very light clean background
      appBar: AppBar(
        title: Text('Create Account',
            style: GoogleFonts.merriweather(fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: Colors.transparent,
        foregroundColor: textMain,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join MyQueue',
                style: GoogleFonts.merriweather(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textMain,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create an account to access healthcare facilities and track your queue status.',
                style: GoogleFonts.merriweather(
                  fontSize: 16,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Social Auth Buttons (Matching Login Screen)
              Row(
                children: [
                  Expanded(
                    child: _buildSocialSquareButton(
                      iconData: Icons.g_mobiledata_rounded,
                      label: 'Google',
                      onPressed: () => _handleSocialSignup('Google'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSocialSquareButton(
                      iconData: Icons.apple,
                      label: 'Apple',
                      onPressed: () => _handleSocialSignup('Apple'),
                      isDark: true,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR REGISTER WITH EMAIL',
                      style: GoogleFonts.merriweather(
                        color: const Color(0xFF94A3B8),
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                ],
              ),
              const SizedBox(height: 32),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10), // 0.04
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _inputCell(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'John Doe',
                      icon: Icons.person_outline,
                      validator: (val) => val!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 20),
                    _inputCell(
                      controller: _idController,
                      label: 'Individual Number (ID)',
                      hint: '123-45678',
                      icon: Icons.badge_outlined,
                      validator: (val) => val!.isEmpty ? 'ID is required' : null,
                    ),
                    const SizedBox(height: 20),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: _inputCell(
                          controller: _dobController,
                          label: 'Date of Birth',
                          hint: 'YYYY-MM-DD',
                          icon: Icons.calendar_today_outlined,
                          validator: (val) => val!.isEmpty ? 'DOB is required' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _inputCell(
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: '712345678',
                      prefix: '+254',
                      icon: Icons.phone_android_outlined,
                      inputType: TextInputType.phone,
                      validator: (val) {
                        if (_isMinor && (val == null || val.isEmpty)) return null;
                        if (val == null || val.length < 9) return 'Enter valid phone';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _inputCell(
                      controller: _emailController,
                      label: 'Email Address (Optional)',
                      hint: 'email@example.com',
                      icon: Icons.email_outlined,
                      inputType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _inputCell(
                      controller: _passwordController,
                      label: 'Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      isPassword: true,
                      validator: (val) =>
                          (val != null && val.length < 6) ? 'Min 6 characters' : null,
                    ),
                    const SizedBox(height: 20),
                    _inputCell(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      isPassword: true,
                      validator: (val) {
                        if (val != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFCBE11), Color(0xFF003D7A)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFCBE11).withAlpha(102), // 0.4
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 3))
                      : Text('Create Account',
                          style: GoogleFonts.merriweather(
                              fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?",
                      style:
                          GoogleFonts.merriweather(color: const Color(0xFF64748B), fontSize: 15)),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Login here',
                        style: GoogleFonts.merriweather(
                            color: primaryBlue, fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialSquareButton({
    required IconData iconData,
    required String label,
    required VoidCallback onPressed,
    bool isDark = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isDark ? BorderSide.none : BorderSide(color: Colors.grey.withAlpha(51)), // 0.2
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.merriweather(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputCell({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? prefix,
    IconData? icon,
    bool obscure = false,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.merriweather(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: inputType,
          validator: validator,
          style: GoogleFonts.merriweather(fontSize: 16, color: textMain),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.merriweather(color: const Color(0xFF94A3B8)),
            prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF94A3B8), size: 20) : null,
            prefixText: prefix != null ? '$prefix ' : null,
            prefixStyle: GoogleFonts.merriweather(fontWeight: FontWeight.w900, color: textMain, fontSize: 16),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: const Color(0xFF94A3B8),
                        size: 20),
                    onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: const Color(0xFFE2E8F0), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
          ),
        ),
      ],
    );
  }
}
