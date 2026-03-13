import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _loading = false;
  final AuthService _authService = AuthService();

  static const Color primaryBlue = Color(0xFF386BB8);
  static const Color textMain = Color(0xFF131316);

  void _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Enter the 6-digit code"),
          behavior: SnackBarBehavior.floating));
      return;
    }

    setState(() => _loading = true);
    final error = await _authService.verifyOtp(
      verificationId: widget.verificationId,
      otp: otp,
    );

    if (error == null) {
      await _authService.saveRefugeeLogin(widget.phoneNumber);
    }

    setState(() => _loading = false);

    if (!mounted) return;

    if (error == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/refugee_home', (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), behavior: SnackBarBehavior.floating));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textMain,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.mark_email_read_outlined,
                  color: primaryBlue, size: 32),
            ),
            const SizedBox(height: 32),
            Text(
              'Verify Phone',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: textMain,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: GoogleFonts.dmSans(
                    fontSize: 16, color: const Color(0xFF64748B), height: 1.5),
                children: [
                  const TextSpan(
                      text: 'We sent a 6-digit verification code to '),
                  TextSpan(
                    text: widget.phoneNumber,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: textMain),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                    color: textMain),
                textAlign: TextAlign.center,
                maxLength: 6,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '000000',
                  hintStyle: GoogleFonts.dmSans(
                      color: const Color(0xFFCBD5E1), letterSpacing: 8),
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _verifyOtp,
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
                  : Text('Verify & Proceed',
                      style: GoogleFonts.dmSans(
                          fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () {
                  // Resend logic if needed
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Code resent (Demo)'),
                      behavior: SnackBarBehavior.floating));
                },
                child: Text('Resend Code',
                    style: GoogleFonts.dmSans(
                        color: primaryBlue, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
