import 'package:flutter/material.dart';
import 'package:ref_qeueu/widgets/logo_avatar.dart';

class WebRoleSelectionScreen extends StatelessWidget {
  final String facilityId;
  final String facilityName;

  const WebRoleSelectionScreen({
    super.key,
    required this.facilityId,
    required this.facilityName,
  });

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
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              const LogoAvatar(size: 60),
              const SizedBox(height: 24),
              const Text(
                'Select Your Role',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_hospital,
                      size: 16,
                      color: Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      facilityName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Role Cards
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.4,
                  children: [
                    _RoleCard(
                      title: 'Doctor',
                      icon: Icons.medical_services,
                      color: const Color(0xFF3B82F6),
                      onTap: () => _navigateToLogin(context, 'doctor'),
                    ),
                    _RoleCard(
                      title: 'Pharmacy',
                      icon: Icons.local_pharmacy,
                      color: const Color(0xFF10B981),
                      onTap: () => _navigateToLogin(context, 'pharmacy'),
                    ),
                    _RoleCard(
                      title: 'Laboratory',
                      icon: Icons.science,
                      color: const Color(0xFF8B5CF6),
                      onTap: () => _navigateToLogin(context, 'lab'),
                    ),
                    _RoleCard(
                      title: 'Maternity',
                      icon: Icons.child_friendly,
                      color: const Color(0xFFEC4899),
                      onTap: () => _navigateToLogin(context, 'maternity'),
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

  void _navigateToLogin(BuildContext context, String role) {
    Navigator.pushNamed(
      context,
      '/web/facility_login',
      arguments: {
        'role': role,
        'facilityId': facilityId,
        'facilityName': facilityName,
      },
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovering ? widget.color : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _hovering
                    ? widget.color.withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: _hovering ? 20 : 10,
                offset: Offset(0, _hovering ? 8 : 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.icon,
                  size: 40,
                  color: widget.color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _hovering ? widget.color : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
