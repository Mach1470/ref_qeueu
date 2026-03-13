import 'package:flutter/material.dart';
import 'package:ref_qeueu/widgets/logo_avatar.dart';

class LoginTypeSelectionScreen extends StatelessWidget {
  const LoginTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const LogoAvatar(size: 70),
              const SizedBox(height: 32),
              const Text(
                'Welcome Back',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Select your access type to continue',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 60),

              // Two Large Cards
              Row(
                children: [
                  Expanded(
                    child: _LoginTypeCard(
                      title: 'Hospital Staff',
                      description:
                          'Access for Doctors, Pharmacists, Laboratory Technicians, and Maternity Staff',
                      icon: Icons.local_hospital,
                      color: const Color(0xFF3B82F6),
                      onTap: () => Navigator.pushNamed(
                          context, '/web/facility_selection'),
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: _LoginTypeCard(
                      title: 'Camp Management',
                      description: 'Analytics Dashboard and Camp-wide Insights',
                      icon: Icons.analytics,
                      color: const Color(0xFF8B5CF6),
                      onTap: () => Navigator.pushNamed(
                          context, '/camp_manager/dashboard'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginTypeCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LoginTypeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_LoginTypeCard> createState() => _LoginTypeCardState();
}

class _LoginTypeCardState extends State<_LoginTypeCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 320,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _hovering ? widget.color : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _hovering
                    ? widget.color.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: _hovering ? 30 : 20,
                offset: Offset(0, _hovering ? 12 : 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 60,
                  color: widget.color,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _hovering ? widget.color : const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                widget.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
