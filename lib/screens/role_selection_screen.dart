import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ref_qeueu/services/auth_service.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _isDemoLoading = false;

  final List<_Role> _roles = const [
    _Role(
      id: 'refugee',
      title: 'Refugee',
      subtitle: 'Access healthcare',
      asset: 'assets/illustrations/refugee_final.png',
      route: '/auth/refugee_login',
      icon: Icons.people_alt_rounded,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    ),
    _Role(
      id: 'ambulance',
      title: 'Ambulance',
      subtitle: 'Emergency services',
      asset: 'assets/illustrations/ambulance_final.png',
      route: '/ambulance_request',
      icon: Icons.emergency_rounded,
      gradientColors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: kDebugMode
          ? FloatingActionButton.extended(
              backgroundColor: Colors.white.withOpacity(0.15),
              onPressed: _isDemoLoading
                  ? null
                  : () async {
                      setState(() => _isDemoLoading = true);
                      try {
                        await AuthService().saveRefugeeLogin('+000000000',
                            displayName: 'Stephen Demo',
                            demoId: 'demo-000',
                            queuePosition: 5);
                        await Future.delayed(const Duration(milliseconds: 300));
                      } catch (_) {}
                      if (mounted) {
                        setState(() => _isDemoLoading = false);
                        Navigator.pushNamed(context, '/refugee_home');
                      }
                    },
              icon: _isDemoLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.person, color: Colors.white),
              label: Text(
                _isDemoLoading ? 'Loading...' : 'Refugee Demo',
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E3A8A), // Deep Blue
              Color(0xFF2563EB), // Vivid Blue
              Color(0xFF1E40AF), // Royal Blue
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ─── HEADER with logo ───
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 20.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.25),
                            Colors.white.withOpacity(0.08),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/illustrations/app_logo.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'MyQueue',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── WELCOME GLASS CARD ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to MyQueue',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Select your role to get started',
                            style: GoogleFonts.dmSans(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Decorative dots / status bar
                          Row(
                            children: [
                              _StatusDot(
                                  color: const Color(0xFF34D399),
                                  label: 'Services Online'),
                              const SizedBox(width: 16),
                              _StatusDot(
                                  color: const Color(0xFF60A5FA),
                                  label: '${_roles.length} Roles'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ─── ROLE CARDS ───
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.70,
                    ),
                    itemCount: _roles.length,
                    itemBuilder: (context, index) {
                      final role = _roles[index];
                      return AnimatedBuilder(
                        animation: _ctrl,
                        builder: (context, child) {
                          double start = (index / _roles.length) * 0.4;
                          double end = start + 0.6;
                          var curve = CurvedAnimation(
                              parent: _ctrl,
                              curve: Interval(start, end,
                                  curve: Curves.easeOutBack));
                          final v = curve.value.clamp(0.0, 1.0);
                          return Transform.translate(
                            offset: Offset(0, 60 * (1 - v)),
                            child: Opacity(opacity: v, child: child),
                          );
                        },
                        child: _PremiumRoleCard(role: role),
                      );
                    },
                  ),
                ),
              ),

              // ─── BOTTOM BRANDING ───
              Padding(
                padding: const EdgeInsets.only(bottom: 32, top: 16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Humanitarian Healthcare Platform',
                      style: GoogleFonts.dmSans(
                        color: Colors.white38,
                        fontSize: 12,
                        letterSpacing: 0.5,
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

// ─── Status Dot Widget ───
class _StatusDot extends StatelessWidget {
  final Color color;
  final String label;
  const _StatusDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.5), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.dmSans(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ─── Data class ───
class _Role {
  final String id;
  final String title;
  final String subtitle;
  final String asset;
  final String route;
  final IconData icon;
  final List<Color> gradientColors;

  const _Role({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.route,
    required this.icon,
    required this.gradientColors,
  });
}

// ─── Premium Role Card ───
class _PremiumRoleCard extends StatefulWidget {
  final _Role role;
  const _PremiumRoleCard({required this.role});

  @override
  State<_PremiumRoleCard> createState() => _PremiumRoleCardState();
}

class _PremiumRoleCardState extends State<_PremiumRoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () async {
        try {
          await AuthService().setRememberedRole(widget.role.id);
          await Navigator.pushNamed(context, widget.role.route);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Route not available: ${widget.role.route}')),
            );
          }
        }
      },
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Role image — circular
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.role.gradientColors.first
                                .withOpacity(0.4),
                            width: 0.5, // Thinned out border
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.role.gradientColors.first
                                  .withOpacity(0.25),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Transform.scale(
                            scale: 1.15,
                            child: Image.asset(
                              widget.role.asset,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                widget.role.icon,
                                size: 48,
                                color: Colors.white30,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Title
                    Text(
                      widget.role.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Subtitle
                    Text(
                      widget.role.subtitle,
                      style: GoogleFonts.dmSans(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tap indicator pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: widget.role.gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: widget.role.gradientColors.first
                                .withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Login',
                            style: GoogleFonts.dmSans(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
