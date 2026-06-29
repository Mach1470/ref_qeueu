import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ref_qeueu/services/auth_service.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  final List<_Role> _roles = const [
    _Role(
      id: 'refugee',
      title: 'Refugee',
      subtitle: 'Access healthcare',
      route: '/auth/refugee_login',
      faIcon: FontAwesomeIcons.personShelter,
      gradientColors: [Color(0xFF0072BC), Color(0xFF003D7A)],
    ),
    _Role(
      id: 'ambulance',
      title: 'Ambulance',
      subtitle: 'Emergency services',
      route: '/production_phone_login_ambulance',
      faIcon: FontAwesomeIcons.truckMedical,
      gradientColors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
    ),
    _Role(
      id: 'chw',
      title: 'Health Worker',
      subtitle: 'Manage triage',
      route: '/production_phone_login_chw',
      faIcon: FontAwesomeIcons.userNurse,
      gradientColors: [Color(0xFF065F46), Color(0xFF10B981)],
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF001F47), // UNHCR Navy
              Color(0xFF003D7A), // UNHCR Deep Blue
              Color(0xFF0060A9), // UNHCR Primary Blue
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

              // ─── WELCOME CARD ───
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D2045),
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.12)),
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
  final String route;
  final FaIconData faIcon;
  final List<Color> gradientColors;

  const _Role({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.route,
    required this.faIcon,
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
        child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0D2045),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Role icon — gradient circle with Font Awesome icon
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: widget.role.gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.role.gradientColors.first
                                    .withOpacity(0.45),
                                blurRadius: 24,
                                spreadRadius: 4,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: FaIcon(
                              widget.role.faIcon,
                              color: Colors.white,
                              size: 42,
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
    );
  }
}
