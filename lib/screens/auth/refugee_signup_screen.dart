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

  bool _loading = false;
  bool _obscurePassword = true;
  final AuthService _authService = AuthService();
  final TextEditingController _dobController = TextEditingController();
  DateTime? _selectedDate;
  bool _isMinor = false;

  static const Color primaryBlue = Color(0xFF386BB8);
  static const Color textMain = Color(0xFF131316);

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
      // If minor and phone is empty, use 'N/A' or handle in backend.
      // AuthService needs to be updated to handle this, but for now we pass empty if minor.
      String phone = '';
      if (rawPhone.isNotEmpty) {
        phone = rawPhone.startsWith('+') ? rawPhone : '+254$rawPhone';
      } else if (_isMinor) {
        // Allow empty for minor
        phone = '';
      }

      setState(() => _loading = true);

      //Pass DOB to auth service (need to update AuthService later or pass in profile data)
      // For now using signUpBasic which simulates it.

      final error = await _authService.signUpBasic(
        name: _nameController.text.trim(),
        dob: _dobController.text.trim(),
        individualNumber: _idController.text.trim(),
        phone: phone,
        password: _passwordController.text,
        email: _emailController.text.trim(),
      );

      // TODO: Save DOB to profile in a separate step or update signUpBasic.
      // I'll update AuthService in the next step to accept DOB.

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('New Account',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: textMain,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join MyQueue',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textMain,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create an account to access healthcare facilities and track your queue status.',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
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
              const SizedBox(height: 32),
              _inputLabel('Full Name'),
              _inputCell(
                controller: _nameController,
                hint: 'John Doe',
                icon: Icons.person_outline,
                validator: (val) => val!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 20),
              _inputLabel('Individual Number (ID)'),
              _inputCell(
                controller: _idController,
                hint: '123-45678',
                icon: Icons.badge_outlined,
                validator: (val) => val!.isEmpty ? 'ID is required' : null,
              ),
              const SizedBox(height: 20),
              _inputLabel('Date of Birth'),
              InkWell(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: _inputCell(
                    controller: _dobController,
                    hint: 'YYYY-MM-DD',
                    icon: Icons.calendar_today_outlined,
                    validator: (val) => val!.isEmpty ? 'DOB is required' : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _inputLabel('Phone Number'),
              _inputCell(
                controller: _phoneController,
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
              _inputLabel('Email Address (Optional)'),
              _inputCell(
                controller: _emailController,
                hint: 'email@example.com',
                icon: Icons.email_outlined,
                inputType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              _inputLabel('Password'),
              _inputCell(
                controller: _passwordController,
                hint: '••••••••',
                icon: Icons.lock_outline,
                obscure: _obscurePassword,
                isPassword: true,
                validator: (val) =>
                    (val != null && val.length < 6) ? 'Min 6 characters' : null,
              ),
              const SizedBox(height: 20),
              _inputLabel('Confirm Password'),
              _inputCell(
                controller: _confirmPasswordController,
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
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _loading ? null : _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3))
                    : Text('Create Account',
                        style: GoogleFonts.dmSans(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?",
                      style:
                          GoogleFonts.dmSans(color: const Color(0xFF64748B))),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Login',
                        style: GoogleFonts.dmSans(
                            color: primaryBlue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textMain,
        ),
      ),
    );
  }

  Widget _inputCell({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    IconData? icon,
    bool obscure = false,
    bool isPassword = false,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          if (icon != null) Icon(icon, color: primaryBlue, size: 20),
          if (icon != null) const SizedBox(width: 12),
          if (prefix != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(prefix,
                  style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold, color: textMain)),
            ),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscure,
              keyboardType: inputType,
              validator: validator,
              style: GoogleFonts.dmSans(fontSize: 16, color: textMain),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: GoogleFonts.dmSans(color: const Color(0xFF94A3B8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: const Color(0xFF94A3B8),
                            size: 20),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
