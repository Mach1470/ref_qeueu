import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CHWLoginScreen extends StatefulWidget {
  const CHWLoginScreen({super.key});

  @override
  State<CHWLoginScreen> createState() => _CHWLoginScreenState();
}

class _CHWLoginScreenState extends State<CHWLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _chwIdCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePin = true;
  String? _errorMessage;

  @override
  void dispose() {
    _chwIdCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final chwId = _chwIdCtrl.text.trim();
      final pin = _pinCtrl.text.trim();

      // Query Firestore for CHW record matching this ID
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('chwId', isEqualTo: chwId)
          .where('role', isEqualTo: 'chw')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 15));

      if (snapshot.docs.isEmpty) {
        setState(() => _errorMessage = 'CHW ID not found in system.');
        return;
      }

      final doc = snapshot.docs.first;
      final data = doc.data();

      // Validate PIN
      final storedPin = data['pin']?.toString() ?? '';
      if (storedPin.isEmpty || storedPin != pin) {
        setState(() => _errorMessage = 'Incorrect PIN. Please try again.');
        return;
      }

      // Save session to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('chw_id', chwId);
      await prefs.setString('chw_doc_id', doc.id);
      await prefs.setString('chw_name', data['name']?.toString() ?? 'Health Worker');
      await prefs.setString('chw_facility_id', data['assignedFacilityId']?.toString() ?? '');
      await prefs.setString('chw_facility_name', data['facilityName']?.toString() ?? '');
      await prefs.setString('chw_role', 'chw');
      await prefs.setBool('chw_logged_in', true);
      await prefs.setString('chw_status', 'active');

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/chw_dashboard');
    } on FirebaseException catch (e) {
      setState(() => _errorMessage = 'Network error. Please check your connection.');
      debugPrint('CHW login Firestore error: ${e.message}');
    } catch (e) {
      setState(() => _errorMessage = 'Login failed. Please try again.');
      debugPrint('CHW login error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF065F46),
                  Color(0xFF047857),
                  Color(0xFF10B981),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            top: -50,
            left: -50,
            child: _AnimatedBlob(color: Colors.green.withOpacity(0.2), size: 280),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: _AnimatedBlob(color: const Color(0xFF10B981).withOpacity(0.15), size: 320),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(Icons.local_hospital_rounded, size: 40, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Community Health Worker',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage patient triage and routing',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _chwIdCtrl,
                          style: const TextStyle(color: Colors.white),
                          textInputAction: TextInputAction.next,
                          decoration: _inputDecoration('CHW ID', Icons.badge_rounded),
                          validator: (v) =>
                              (v?.isEmpty ?? true) ? 'Please enter your CHW ID' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _pinCtrl,
                          style: const TextStyle(color: Colors.white),
                          obscureText: _obscurePin,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                          decoration: _inputDecoration('PIN', Icons.lock_rounded).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePin
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.white.withOpacity(0.6),
                              ),
                              onPressed: () => setState(() => _obscurePin = !_obscurePin),
                            ),
                          ),
                          validator: (v) {
                            if (v?.isEmpty ?? true) return 'Please enter your PIN';
                            if (v!.length < 4) return 'PIN must be at least 4 digits';
                            return null;
                          },
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              border: Border.all(color: Colors.red.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2.5),
                                  )
                                : Text(
                                    'Sign In',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF065F46),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Hint for fresh deployments
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.white.withOpacity(0.7), size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Your CHW ID and PIN are assigned by your facility administrator.',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.6)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.withOpacity(0.7)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      errorStyle: const TextStyle(color: Colors.white70),
    );
  }
}

class _AnimatedBlob extends StatefulWidget {
  final Color color;
  final double size;

  const _AnimatedBlob({required this.color, required this.size});

  @override
  State<_AnimatedBlob> createState() => _AnimatedBlobState();
}

class _AnimatedBlobState extends State<_AnimatedBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            (_controller.value - 0.5) * 30,
            (_controller.value - 0.5) * 40,
          ),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.5),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
