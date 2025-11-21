import 'package:flutter/material.dart';
import 'otp_verification_screen.dart';
import '../../services/auth_service.dart';

class RefugeeLoginScreen extends StatefulWidget {
  const RefugeeLoginScreen({super.key});

  @override
  State<RefugeeLoginScreen> createState() => _RefugeeLoginScreenState();
}

class _RefugeeLoginScreenState extends State<RefugeeLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _idOrEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  bool _usePhone = true; // toggle between phone and email/ID+password

  final AuthService _authService = AuthService();

  void _sendOtp() async {
    final raw = _phoneController.text.trim();
    if (raw.isEmpty || raw.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enter a valid phone number")));
      return;
    }
    final phone = raw.startsWith('+') ? raw : '+254$raw';
    setState(() => _loading = true);

    // here we simulate/abstract OTP sending; the AuthService returns a verificationId
    final result = await _authService.sendOtp(phone: phone);
    setState(() => _loading = false);

    if (!mounted) return;

    if (result != null) {
      // open OTP screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              OtpVerificationScreen(verificationId: result, phoneNumber: phone),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to send OTP")));
    }
  }

  void _emailLogin() async {
    final idOrEmail = _idOrEmailController.text.trim();
    final password = _passwordController.text;
    if (idOrEmail.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Enter credentials")));
      return;
    }
    setState(() => _loading = true);
    final error = await _authService.signInWithEmailOrId(
        idOrEmail: idOrEmail, password: password, role: 'refugee');
    setState(() => _loading = false);

    if (!mounted) return;

    if (error == null) {
      Navigator.pushNamedAndRemoveUntil(context, '/refugee_home', (_) => false);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            title: const Text('Refugee Login'),
            backgroundColor: Colors.teal,
            elevation: 0),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _usePhone ? _phoneView() : _emailView(),
        ),
      ),
    );
  }

  Widget _phoneView() {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Text('Login with phone',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text('You will receive an OTP to sign in'),
        const SizedBox(height: 20),
        _inputCell(
            prefix: '+254', controller: _phoneController, hint: '712345678'),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _loading ? null : _sendOtp,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              minimumSize: const Size.fromHeight(50)),
          child: _loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Send OTP'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _usePhone = false),
          child: const Text('Or login with email / ID & password'),
        ),
        const Spacer(),
        const Text('Don’t have an account? Sign up below'),
        const SizedBox(height: 8),

        // --- SIGNUP BUTTON FIX ---
        ElevatedButton(
          onPressed: () {
            // Navigate correctly to the full Signup Screen
            Navigator.pushNamed(context, '/auth/refugee_signup');
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.teal,
              side: BorderSide(color: Colors.teal.shade100)),
          child: const Text('Sign up'),
        ),
      ],
    );
  }

  Widget _emailView() {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Text('Login with Email / Individual Number',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        _inputCell(
            prefix: null,
            controller: _idOrEmailController,
            hint: 'ID number or email'),
        const SizedBox(height: 12),
        _inputCell(
            prefix: null,
            controller: _passwordController,
            hint: 'Password',
            obscure: true),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _loading ? null : _emailLogin,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              minimumSize: const Size.fromHeight(50)),
          child: _loading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Login'),
        ),
        const SizedBox(height: 12),
        TextButton(
            onPressed: () => setState(() => _usePhone = true),
            child: const Text('Or login with phone')),
      ],
    );
  }

  Widget _inputCell(
      {String? prefix,
      required TextEditingController controller,
      required String hint,
      bool obscure = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.teal.shade50)),
      child: Row(
        children: [
          if (prefix != null)
            Text(prefix,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.teal)),
          if (prefix != null) const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              keyboardType: TextInputType.text,
              decoration:
                  InputDecoration(border: InputBorder.none, hintText: hint),
            ),
          ),
        ],
      ),
    );
  }
}
