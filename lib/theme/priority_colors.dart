import 'package:flutter/material.dart';

/// Priority color coding for triage / queue / ambulance flows.
///
/// Per project brief: Red = Emergency, Amber = Urgent, Green = Routine.
/// These colors are also used to color-code priority badges across all roles
/// (refugee, CHW, ambulance) and the offline banner.
class PriorityColors {
  PriorityColors._();

  /// Emergency — immediate response required.
  static const Color emergency = Color(0xFFD32F2F);

  /// Urgent — should be seen soon but not life-threatening.
  static const Color urgent = Color(0xFFF57C00);

  /// Routine — standard queue position.
  static const Color routine = Color(0xFF2E7D32);

  /// Background tint for emergency badges.
  static const Color emergencySurface = Color(0xFFFFEBEE);

  /// Background tint for urgent badges.
  static const Color urgentSurface = Color(0xFFFFF3E0);

  /// Background tint for routine badges.
  static const Color routineSurface = Color(0xFFE8F5E9);

  /// Returns a (foreground, background) pair for a given priority string.
  /// Accepts 'emergency' | 'urgent' | 'routine' (case-insensitive), with
  /// 'routine' as the default for unknown values.
  static (Color foreground, Color background) forLabel(String? priority) {
    switch ((priority ?? '').toLowerCase()) {
      case 'emergency':
      case 'critical':
        return (emergency, emergencySurface);
      case 'urgent':
      case 'high':
        return (urgent, urgentSurface);
      case 'routine':
      case 'normal':
      case 'low':
      default:
        return (routine, routineSurface);
    }
  }
}

/// Triage priority levels used across the app.
enum TriagePriority {
  routine,
  urgent,
  emergency;

  String get label {
    switch (this) {
      case TriagePriority.routine:
        return 'Routine';
      case TriagePriority.urgent:
        return 'Urgent';
      case TriagePriority.emergency:
        return 'Emergency';
    }
  }

  /// Color for this priority (foreground).
  Color get color {
    switch (this) {
      case TriagePriority.routine:
        return PriorityColors.routine;
      case TriagePriority.urgent:
        return PriorityColors.urgent;
      case TriagePriority.emergency:
        return PriorityColors.emergency;
    }
  }

  /// Background tint for this priority.
  Color get surface {
    switch (this) {
      case TriagePriority.routine:
        return PriorityColors.routineSurface;
      case TriagePriority.urgent:
        return PriorityColors.urgentSurface;
      case TriagePriority.emergency:
        return PriorityColors.emergencySurface;
    }
  }

  static TriagePriority fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'emergency':
      case 'critical':
        return TriagePriority.emergency;
      case 'urgent':
      case 'high':
        return TriagePriority.urgent;
      case 'routine':
      case 'normal':
      case 'low':
      default:
        return TriagePriority.routine;
    }
  }
}

/// A small badge that color-codes a triage priority.
///
/// Used in refugee queue cards, CHW patient list, ambulance dispatch rows.
class PriorityBadge extends StatelessWidget {
  final TriagePriority priority;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: priority.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: priority.color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: priority.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            priority.label,
            style: TextStyle(
              color: priority.color,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
