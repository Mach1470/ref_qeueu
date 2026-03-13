import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:ref_qeueu/services/security_service.dart';
import 'package:ref_qeueu/widgets/safe_scaffold.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AuthLockScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const AuthLockScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthLockScreen> createState() => _AuthLockScreenState();
}

class _AuthLockScreenState extends State<AuthLockScreen> {
  final SecurityService _security = SecurityService.instance;
  bool _usePin = false;

  @override
  void initState() {
    super.initState();
    _tryBiometric();
  }

  Future<void> _tryBiometric() async {
    if (await _security.isBiometricsEnabled()) {
      final success = await _security.authenticate();
      if (success) {
        widget.onAuthenticated();
      } else {
        setState(() => _usePin = true);
      }
    } else {
      setState(() => _usePin = true);
    }
  }

  void _onPinComplete(String pin) async {
    if (await _security.verifyPin(pin)) {
      widget.onAuthenticated();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid PIN'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_person_rounded, color: Color(0xFF6366F1), size: 80)
                .animate()
                .scale(duration: 600.ms, curve: Curves.easeOutBack)
                .shimmer(delay: 1.seconds),
            const SizedBox(height: 32),
            Text(
              'Security Required',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Authenticate to access your records',
              style: GoogleFonts.dmSans(color: Colors.white38, fontSize: 14),
            ),
            const SizedBox(height: 60),
            if (_usePin) ...[
              Pinput(
                length: 4,
                obscureText: true,
                onCompleted: _onPinComplete,
                defaultPinTheme: PinTheme(
                  width: 56,
                  height: 60,
                  textStyle: GoogleFonts.poppins(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 56,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF6366F1)),
                  ),
                ),
              ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              const SizedBox(height: 32),
              TextButton.icon(
                onPressed: _tryBiometric,
                icon: const Icon(Icons.fingerprint, size: 18),
                label: const Text('Use Biometrics'),
                style: TextButton.styleFrom(foregroundColor: Colors.white54),
              ),
            ] else
              _buildBiometricPrompt(),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricPrompt() {
    return Column(
      children: [
        const CircularProgressIndicator(color: Color(0xFF6366F1)),
        const SizedBox(height: 24),
        Text(
          'Waiting for authentication...',
          style: GoogleFonts.dmSans(color: Colors.white60),
        ),
      ],
    );
  }
}
