import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:ref_qeueu/services/production_auth_service.dart';
import 'package:ref_qeueu/screens/auth/production_otp_verification_screen.dart';

class ProductionPhoneLoginScreen extends StatefulWidget {
  final String role;

  const ProductionPhoneLoginScreen({required this.role, super.key});

  @override
  State<ProductionPhoneLoginScreen> createState() =>
      _ProductionPhoneLoginScreenState();
}

class _ProductionPhoneLoginScreenState extends State<ProductionPhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _authService = ProductionAuthService();
  bool _isLoading = false;
  String? _errorMessage;
  String _fullPhoneNumber = '';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_fullPhoneNumber.isEmpty) {
      _showError('Please enter a valid phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final verificationId = await _authService.verifyPhoneNumber(
        phoneNumber: _fullPhoneNumber,
      );

      if (!mounted) return;

      if (verificationId != null && !verificationId.startsWith('Phone')) {
        // Success - navigate to OTP verification
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductionOtpVerificationScreen(
              phoneNumber: _fullPhoneNumber,
              verificationId: verificationId,
              role: widget.role,
            ),
          ),
        );
      } else {
        _showError(verificationId ?? 'Failed to send OTP');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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

  String _getRoleDisplayName() {
    switch (widget.role) {
      case 'refugee':
        return 'Refugee';
      case 'ambulance_driver':
        return 'Ambulance Driver';
      case 'chw':
        return 'Health Worker';
      default:
        return 'User';
    }
  }

  Color _getRoleColor() {
    switch (widget.role) {
      case 'refugee':
        return const Color(0xFF0072BC);
      case 'ambulance_driver':
        return const Color(0xFFEF4444);
      case 'chw':
        return const Color(0xFF065F46);
      default:
        return const Color(0xFF0072BC);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor();

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  roleColor,
                  roleColor.withOpacity(0.7),
                  roleColor.withOpacity(0.5),
                ],
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),
                  // Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getRoleDisplayName(),
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    'Sign In',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Subtitle
                  Text(
                    'Enter your phone number to continue',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Phone Input
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Phone Number',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      IntlPhoneField(
                        controller: _phoneController,
                        enabled: !_isLoading,
                        initialCountryCode: 'KE', // Kenya (Kakuma/Dadaab)
                        disableLengthCheck: false,
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          counterText: '',
                        ),
                        style: const TextStyle(color: Colors.white),
                        dropdownTextStyle:
                            const TextStyle(color: Colors.black),
                        onChanged: (phone) {
                          setState(() =>
                              _fullPhoneNumber = phone.completeNumber);
                        },
                        onCountryChanged: (country) {},
                      ),
                    ],
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.5),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  // Send OTP Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      onPressed: _isLoading ? null : _sendOtp,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Send OTP',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: roleColor,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Info Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          size: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'We\'ll send you a secure OTP code to verify your number',
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
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
        ],
      ),
    );
  }
}
