import 'package:flutter/material.dart';
import 'package:ref_qeueu/models/health_facility.dart';
import 'package:ref_qeueu/widgets/logo_avatar.dart';

class FacilitySelectionScreen extends StatefulWidget {
  final String role; // 'doctor', 'pharmacy', 'lab', 'maternity'

  const FacilitySelectionScreen({super.key, required this.role});

  @override
  State<FacilitySelectionScreen> createState() =>
      _FacilitySelectionScreenState();
}

class _FacilitySelectionScreenState extends State<FacilitySelectionScreen> {
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
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              const LogoAvatar(size: 60),
              const SizedBox(height: 24),
              const Text(
                'Select Health Facility',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose the UNHCR facility where you work',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 48),

              // Facility Cards Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: mockHealthFacilities.length,
                  itemBuilder: (context, index) {
                    final facility = mockHealthFacilities[index];
                    return _FacilityCard(
                      facility: facility,
                      role: widget.role,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FacilityCard extends StatefulWidget {
  final HealthFacility facility;
  final String role;

  const _FacilityCard({
    required this.facility,
    required this.role,
  });

  @override
  State<_FacilityCard> createState() => _FacilityCardState();
}

class _FacilityCardState extends State<_FacilityCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final typeColor = _getTypeColor(widget.facility.type);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: () {
          // Navigate to role selection with facility context
          Navigator.pushNamed(
            context,
            '/web/role_selection',
            arguments: {
              'facilityId': widget.facility.id,
              'facilityName': widget.facility.name,
            },
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _hovering ? typeColor : const Color(0xFFE2E8F0),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _hovering
                    ? typeColor.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: _hovering ? 24 : 12,
                offset: Offset(0, _hovering ? 10 : 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.facility.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: typeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Facility Name
              Text(
                widget.facility.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Address
              Row(
                children: [
                  Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.facility.address,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),

              // Action
              Row(
                children: [
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward,
                    color: typeColor,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'hospital':
        return const Color(0xFF3B82F6); // Blue
      case 'clinic':
        return const Color(0xFF10B981); // Green
      case 'health_post':
        return const Color(0xFFF59E0B); // Amber
      default:
        return const Color(0xFF64748B); // Gray
    }
  }
}
