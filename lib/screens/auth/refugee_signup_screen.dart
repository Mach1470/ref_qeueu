import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RefugeeSignupScreen extends StatefulWidget {
  const RefugeeSignupScreen({super.key});

  @override
  State<RefugeeSignupScreen> createState() => _RefugeeSignupScreenState();
}

class _RefugeeSignupScreenState extends State<RefugeeSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
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

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final rawPhone = _phoneController.text.trim();
      // Ensure phone has country code (matching logic in Login Screen)
      final phone = rawPhone.startsWith('+') ? rawPhone : '+254$rawPhone';

      setState(() => _loading = true);

      // Call AuthService
      final error = await _authService.signUpBasic(
        individualNumber: _idController.text.trim(),
        phone: phone,
        password: _passwordController.text,
        email: _emailController.text.trim(),
        // You might want to add 'name' to your AuthService signUpBasic method
      );

      setState(() => _loading = false);

      if (!mounted) return;

      if (error == null) {
        // Success: Navigate to Home or Login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pushNamedAndRemoveUntil(
            context, '/refugee_home', (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor:
            const Color(0xFFF5F5F5), // Slight off-white to make inputs pop
        appBar: AppBar(
          title: const Text('Create Account'),
          backgroundColor: Colors.teal,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Sign up',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal)),
                const SizedBox(height: 8),
                const Text(
                    'Enter your details to register for the queue system.'),
                const SizedBox(height: 24),

                // Full Name
                _inputCell(
                  controller: _nameController,
                  hint: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (val) => val!.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                // Individual Number (ID)
                _inputCell(
                  controller: _idController,
                  hint: 'Individual Number / ID',
                  icon: Icons.badge_outlined,
                  validator: (val) => val!.isEmpty ? 'ID is required' : null,
                ),
                const SizedBox(height: 16),

                // Phone Number
                _inputCell(
                  controller: _phoneController,
                  hint: '712345678',
                  prefix: '+254',
                  inputType: TextInputType.phone,
                  validator: (val) => (val == null || val.length < 9)
                      ? 'Enter valid phone'
                      : null,
                ),
                const SizedBox(height: 16),

                // Email (Optional)
                _inputCell(
                  controller: _emailController,
                  hint: 'Email Address (Optional)',
                  icon: Icons.email_outlined,
                  inputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password
                _inputCell(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  obscure: _obscurePassword,
                  isPassword: true,
                  validator: (val) => (val != null && val.length < 6)
                      ? 'Min 6 characters'
                      : null,
                ),
                const SizedBox(height: 16),

                // Confirm Password
                _inputCell(
                  controller: _confirmPasswordController,
                  hint: 'Confirm Password',
                  icon: Icons.lock_outline,
                  obscure: _obscurePassword,
                  isPassword: true,
                  validator: (val) {
                    if (val != _passwordController.text)
                      return 'Passwords do not match';
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Sign Up Button
                ElevatedButton(
                  onPressed: _loading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Account',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),

                const SizedBox(height: 20),

                // Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        // Navigate back to login
                        Navigator.pop(context);
                        // Or specifically: Navigator.pushNamed(context, '/auth/refugee_login');
                      },
                      child: const Text('Login',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Consistent Input Styling Method
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade50),
      ),
      child: Row(
        children: [
          if (prefix != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(prefix,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.teal)),
            ),
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(icon, color: Colors.teal, size: 20),
            ),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: obscure,
              keyboardType: inputType,
              validator: validator,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400),
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
