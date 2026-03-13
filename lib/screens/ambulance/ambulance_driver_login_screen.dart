import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ref_qeueu/widgets/glass_widgets.dart';

class AmbulanceDriverLoginScreen extends StatefulWidget {
  const AmbulanceDriverLoginScreen({super.key});

  @override
  State<AmbulanceDriverLoginScreen> createState() =>
      _AmbulanceDriverLoginScreenState();
}

class _AmbulanceDriverLoginScreenState
    extends State<AmbulanceDriverLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleIdCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _isLoading = false;
  bool _obscurePin = true;

  @override
  void dispose() {
    _vehicleIdCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('driver_vehicle_id', _vehicleIdCtrl.text.trim());
      await prefs.setBool('driver_logged_in', true);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/ambulance_driver_dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
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
                  Color(0xFF1E3A8A), // Deep Blue
                  Color(0xFF312E81), // Indigo
                  Color(0xFF4C1D95), // Deep Purple
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          // Decorative Blobs
          Positioned(
            top: -50,
            left: -50,
            child: _AnimatedBlob(
              color: Colors.indigo.withOpacity(0.2),
              size: 280,
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: _AnimatedBlob(
              color: Colors.blue.withOpacity(0.15),
              size: 320,
            ),
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
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(
                        Icons.local_hospital_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Driver Portal',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Emergency Response Dispatch System',
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1000),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 40 * (1 - value)),
                        child: Opacity(
                          opacity: value.clamp(0.0, 1.0),
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: GlassCard(
                        padding: const EdgeInsets.all(32),
                        borderRadius: BorderRadius.circular(32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      'Fleet Authentication',
                                      style: GoogleFonts.dmSans(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      height: 2,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Colors.redAccent,
                                            Colors.orangeAccent
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(1),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 40),
                              _buildInputLabel('Vehicle Fleet ID'),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _vehicleIdCtrl,
                                textCapitalization:
                                    TextCapitalization.characters,
                                style: GoogleFonts.dmSans(
                                    color: Colors.white, fontSize: 16),
                                decoration: _premiumInputDecoration(
                                  hint: 'e.g., AMB-001',
                                  icon: Icons.airport_shuttle_rounded,
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? 'Enter vehicle ID' : null,
                              ),
                              const SizedBox(height: 24),
                              _buildInputLabel('Operator Access PIN'),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _pinCtrl,
                                obscureText: _obscurePin,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                style: GoogleFonts.dmSans(
                                    color: Colors.white, fontSize: 16),
                                decoration: _premiumInputDecoration(
                                  hint: '••••••',
                                  icon: Icons.lock_rounded,
                                ).copyWith(
                                  counterText: '',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePin
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: Colors.white54,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscurePin = !_obscurePin),
                                  ),
                                ),
                                validator: (v) => v!.length < 4
                                    ? 'PIN must be 4-6 digits'
                                    : null,
                              ),
                              const SizedBox(height: 48),
                              Container(
                                width: double.infinity,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFEF4444),
                                      Color(0xFFDC2626)
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.redAccent.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Start Response Shift',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Icon(Icons.flash_on_rounded,
                                                size: 20),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'Contact dispatch if you forgot your PIN',
                      style: GoogleFonts.dmSans(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
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

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        fontWeight: FontWeight.w600,
        color: Colors.white70,
        fontSize: 14,
      ),
    );
  }

  InputDecoration _premiumInputDecoration(
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.dmSans(color: Colors.white24),
      prefixIcon: Icon(icon, color: Colors.white54, size: 22),
      filled: true,
      fillColor: Colors.white.withOpacity(0.08),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
      ),
    );
  }
}

class _AnimatedBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _AnimatedBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(seconds: 4),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 100,
                spreadRadius: 40,
              ),
            ],
          ),
        );
      },
    );
  }
}
