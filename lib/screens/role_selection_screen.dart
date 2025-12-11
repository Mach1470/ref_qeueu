import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ref_qeueu/services/auth_service.dart';
import '../../widgets/logo_avatar.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  final Color primaryColor = Colors.teal;

  // Data structure for all roles, including the new 'Maternity' role
  final List<_Role> _roles = const [
    _Role(
        id: 'refugee',
        title: 'Refugee',
        asset: 'assets/illustrations/refugee.png',
        route: '/auth/refugee_login'),
    _Role(
        id: 'doctor',
        title: 'Doctor',
        asset: 'assets/illustrations/doctor.png',
        route: '/auth/doctor_login'), // Changed route to use the login screen
    _Role(
        id: 'maternity', // NEW ROLE ID
        title: 'Maternity',
        asset: 'assets/illustrations/maternity.png', // Requires this asset
        route: '/maternity/login'), // NEW ROUTE
    _Role(
        id: 'lab',
        title: 'Lab',
        asset: 'assets/illustrations/lab.png',
        route: '/lab_home'),
    _Role(
        id: 'pharmacy',
        title: 'Pharmacy',
        asset: 'assets/illustrations/pharmacy.png',
        route: '/pharmacy/login'),
    _Role(
        id: 'ambulance',
        title: 'Ambulance',
        asset: 'assets/illustrations/ambulance.png',
        route: '/ambulance_request'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    // Start the animation after the frame is built
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
      // Debug-only shortcut to open the refugee dashboard with demo login
      floatingActionButton: kDebugMode
          ? FloatingActionButton.extended(
              onPressed: () async {
                // Set a demo refugee login state and navigate to the refugee home
                try {
                  await AuthService().saveRefugeeLogin('+000000000');
                } catch (_) {}
                if (context.mounted) {
                  Navigator.pushNamed(context, '/refugee_home');
                }
              },
              icon: const Icon(Icons.person),
              label: const Text('Refugee Demo'),
            )
          : null,
      backgroundColor: primaryColor,
      // Slim, branded app bar that uses your primary color and logo
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: primaryColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          toolbarHeight: 64,
          titleSpacing: 16,
          title: Row(
            children: [
              LogoAvatar(size: 48),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'MyQueue',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Select your role',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          // No profile avatar or settings icon here by design.
        ),
      ),
      body: SafeArea(
        // We use SafeArea here to handle the status bar/notch correctly
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 8),

            // 2. CURVED WHITE BODY
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F9FA),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: GridView.builder(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: _roles.length,
                  itemBuilder: (context, index) {
                    final role = _roles[index];

                    return AnimatedBuilder(
                      animation: _ctrl,
                      builder: (context, child) {
                        // Staggered animation effect
                        double start = (index / _roles.length) * 0.5;
                        double end = start + 0.5;
                        var curve = CurvedAnimation(
                            parent: _ctrl,
                            curve: Interval(start, end,
                                curve: Curves.easeOutBack));

                        // Clamp the animated value to [0.0, 1.0] because some curves
                        // (e.g., easeOutBack) overshoot and return values outside the
                        // 0.0..1.0 range, which causes Opacity to assert.
                        final raw = curve.value;
                        final v = raw.clamp(0.0, 1.0);
                        return Transform.translate(
                          offset: Offset(0, 50 * (1 - v)),
                          child: Opacity(opacity: v, child: child),
                        );
                      },
                      child: _RoleCard(role: role),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data class for a single role entry
class _Role {
  final String id;
  final String title;
  final String asset;
  final String route;

  const _Role(
      {required this.id,
      required this.title,
      required this.asset,
      required this.route});
}

// Widget for displaying a single role card
class _RoleCard extends StatelessWidget {
  final _Role role;
  const _RoleCard({required this.role});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          // Persist the role the user selected so future launches default here
          await AuthService().setRememberedRole(role.id);
          await Navigator.pushNamed(context, role.route);
        } catch (e) {
          // Route not found or navigation error — show a friendly message instead of crashing
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Route not available: ${role.route}')),
            );
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withAlpha((0.06 * 255).round()),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                // This uses the role's image asset (e.g., refugee.png)
                child: Image.asset(
                  role.asset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey.shade50,
                    child: const Center(
                      child: Icon(Icons.broken_image,
                          size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            Text(role.title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3142))),
            const SizedBox(height: 4),
            Text("Tap to Login",
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[400],
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
