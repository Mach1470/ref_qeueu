import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ref_qeueu/services/auth_service.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';
import 'package:ref_qeueu/widgets/theme_toggle_button.dart';
import 'package:ref_qeueu/widgets/logo_avatar.dart';

class DoctorLoginScreen extends StatefulWidget {
  const DoctorLoginScreen({super.key});

  @override
  State<DoctorLoginScreen> createState() => _DoctorLoginScreenState();
}

class _DoctorLoginScreenState extends State<DoctorLoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  static const Color primaryBlue = Color(0xFF386BB8);
  static const Color textMain = Color(0xFF131316);

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulation delay
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (_idController.text.toLowerCase() == 'dr101' &&
          _passwordController.text == 'pass123') {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/doctor_home', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invalid Doctor ID or Password.'),
              behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Staff Access',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: textMain,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, '/role_selection', (route) => false),
        ),
        actions: const [ThemeToggleButton()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const LogoAvatar(size: 80),
              const SizedBox(height: 32),
              Text(
                'Healthcare Professional',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: textMain,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to manage facilities and patient queues.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              _inputCell(
                controller: _idController,
                hint: 'Staff/Doctor ID',
                icon: Icons.badge_outlined,
                validator: (val) => val!.isEmpty ? 'ID is required' : null,
              ),
              const SizedBox(height: 20),
              _inputCell(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscure: true,
                validator: (val) =>
                    val!.isEmpty ? 'Password is required' : null,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 3))
                    : Text('Login to Dashboard',
                        style: GoogleFonts.dmSans(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () async {
                  await AuthService().clearRememberedRole();
                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/role_selection', (route) => false);
                  }
                },
                child: Text('Not a healthcare worker?',
                    style: GoogleFonts.dmSans(color: const Color(0xFF64748B))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputCell({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
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
          Icon(icon, color: primaryBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscure,
              validator: validator,
              style: GoogleFonts.dmSans(fontSize: 16, color: textMain),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: GoogleFonts.dmSans(color: const Color(0xFF94A3B8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
