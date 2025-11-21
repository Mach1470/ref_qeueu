import 'package:flutter/material.dart';

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
        asset: 'assets/illustrations/refugee.png',
        route: '/auth/refugee'),
    _Role(
        id: 'doctor',
        title: 'Doctor',
        asset: 'assets/illustrations/doctor.png',
        route: '/doctor'),
    _Role(
        id: 'lab',
        title: 'Lab',
        asset: 'assets/illustrations/lab.png',
        route: '/lab'),
    _Role(
        id: 'pharmacy',
        title: 'Pharmacy',
        asset: 'assets/illustrations/pharmacy.png',
        route: '/pharmacy_login'),
    _Role(
        id: 'ambulance',
        title: 'Ambulance',
        asset: 'assets/illustrations/ambulance.png',
        route: '/ambulance'),
  ];

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: _roles.length * 200));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        for (final r in _roles) {
          try {
            precacheImage(AssetImage(r.asset), context);
          } catch (e) {
            // Ignore precache errors - images will load normally
          }
        }
        if (mounted) {
          _ctrl.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Animation<double> _buildAnim(int i) {
    final start = i * 0.12;
    final end = start + 0.35;

    return CurvedAnimation(
      parent: _ctrl,
      curve:
          Interval(start.clamp(0, 1).toDouble(), end.clamp(0, 1).toDouble(),
              curve: Curves.easeOutBack),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int columns = 2;
    if (width >= 900) columns = 3;
    if (width < 520) columns = 1;

    return Scaffold(
      backgroundColor: const Color(0xFFE6F4F1),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.teal,
        title:
            const Text("Select your role", style: TextStyle(color: Colors.teal)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ------------ FIXED RESPONSIVE GRID ------------
            Expanded(
              child: GridView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: 1.8,
                ),
                itemCount: _roles.length,
                itemBuilder: (context, index) {
                  final role = _roles[index];

                  return AnimatedBuilder(
                    animation: _buildAnim(index),
                    builder: (context, child) {
                      final a = _buildAnim(index).value;
                      return Opacity(
                        opacity: a,
                        child: Transform.scale(
                          scale: 0.86 + (0.14 * a),
                          child: child,
                        ),
                      );
                    },
                    child: _RoleCard(role: role),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Role {
  final String id;
  final String title;
  final String asset;
  final String route;

  const _Role({
    required this.id,
    required this.title,
    required this.asset,
    required this.route,
  });
}

class _RoleCard extends StatelessWidget {
  final _Role role;

  const _RoleCard({required this.role});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.pushNamed(context, role.route);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                    Colors.teal.shade50,
                    Colors.teal.shade100,
                  ]),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Image.asset(role.asset),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  role.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 18, color: Colors.teal),
            ],
          ),
        ),
      ),
    );
  }
}
