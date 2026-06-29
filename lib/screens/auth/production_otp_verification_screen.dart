import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:ref_qeueu/services/production_auth_service.dart';

class ProductionOtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String role; // refugee, ambulance_driver, chw

  const ProductionOtpVerificationScreen({
    required this.phoneNumber,
    required this.verificationId,
    required this.role,
    super.key,
  });

  @override
  State<ProductionOtpVerificationScreen> createState() =>
      _ProductionOtpVerificationScreenState();
}

class _ProductionOtpVerificationScreenState
    extends State<ProductionOtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _authService = ProductionAuthService();
  bool _isVerifying = false;
  String? _errorMessage;
  int _resendCountdown = 0;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    // Can resend after 30 seconds
    _resendCountdown = 30;
    setState(() => _canResend = false);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() => _resendCountdown--);
        _startResendTimer();
      } else if (mounted) {
        setState(() => _canResend = true);
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty) {
      _showError('Please enter the OTP code');
      return;
    }

    if (_otpController.text.length < 6) {
      _showError('OTP code must be 6 digits');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final result = await _authService.signInWithOtp(
        verificationId: widget.verificationId,
        otp: _otpController.text.trim(),
        role: widget.role,
        phoneNumber: widget.phoneNumber,
      );

      if (!mounted) return;

      if (result == null) {
        // Success - navigate based on role
        _navigateBasedOnRole();
      } else {
        // Error
        _showError(result);
      }
    } catch (e) {
      _showError('Verification failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  void _navigateBasedOnRole() {
    switch (widget.role) {
      case 'refugee':
        Navigator.pushReplacementNamed(context, '/refugee_home');
        break;
      case 'ambulance_driver':
        Navigator.pushReplacementNamed(context, '/ambulance_driver_dashboard');
        break;
      case 'chw':
        Navigator.pushReplacementNamed(context, '/chw_dashboard');
        break;
      default:
        Navigator.pushReplacementNamed(context, '/role_selection');
    }
  }

  Future<void> _resendOtp() async {
    if (!_canResend) return;

    setState(() => _isVerifying = true);

    try {
      final newVerificationId = await _authService.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
      );

      if (!mounted) return;

      if (newVerificationId == null) {
        _showError('Failed to resend OTP');
      } else {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP resent successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        _otpController.clear();
        _startResendTimer();
      }
    } catch (e) {
      _showError('Error resending OTP: $e');
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF065F46),
      ),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF10B981)),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color(0xFF065F46), width: 2),
      borderRadius: BorderRadius.circular(12),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color(0xFFF0FDF4),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verify Phone Number',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF10B981),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  size: 40,
                  color: Color(0xFF065F46),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Enter Verification Code',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              // Phone number
              Text(
                'Code sent to ${widget.phoneNumber}',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              // OTP Input
              Pinput(
                controller: _otpController,
                length: 6,
                showCursor: true,
                enabled: !_isVerifying,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                onCompleted: (_) => _verifyOtp(),
                errorTextStyle: GoogleFonts.dmSans(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: Colors.red[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF065F46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                  ),
                  onPressed: _isVerifying ? null : _verifyOtp,
                  child: _isVerifying
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Verify Code',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Resend Code
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (_canResend)
                    GestureDetector(
                      onTap: _resendOtp,
                      child: Text(
                        'Resend',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF065F46),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Resend in ${_resendCountdown}s',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              // Info Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_rounded,
                        size: 18, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your code expires in 10 minutes',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
