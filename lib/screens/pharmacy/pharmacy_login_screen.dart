// lib/screens/pharmacy/pharmacy_login_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class PharmacyLoginScreen extends StatefulWidget {
  const PharmacyLoginScreen({super.key});

  @override
  State<PharmacyLoginScreen> createState() => _PharmacyLoginScreenState();
}

class _PharmacyLoginScreenState extends State<PharmacyLoginScreen> {
  final idCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    idCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    // TODO: replace with Firestore / real auth
    final id = idCtrl.text.trim();
    final pass = passCtrl.text;
    if (id.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter credentials')));
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // small fake delay
    
    // Save login state
    final authService = AuthService();
    await authService.savePharmacyLogin(id);
    
    setState(() => _loading = false);

    if (!mounted) return;

    // For now any credentials succeed
    Navigator.pushNamedAndRemoveUntil(context, '/pharmacy_dashboard', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Container(
              padding: const EdgeInsets.all(24),
              width: 380,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 6))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Pharmacy Login", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text("Use your pharmacy ID and password to log in", textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  TextField(
                    controller: idCtrl,
                    decoration: const InputDecoration(labelText: "Pharmacy ID", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Login"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
