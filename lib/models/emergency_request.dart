import 'package:flutter/material.dart';
import '../theme/priority_colors.dart';

/// Source that triggered the request.
enum EmergencyRequestSource {
  refugee,
  chw,
  clinic;

  String get label {
    switch (this) {
      case EmergencyRequestSource.refugee:
        return 'Refugee';
      case EmergencyRequestSource.chw:
        return 'CHW';
      case EmergencyRequestSource.clinic:
        return 'Clinic';
    }
  }

  static EmergencyRequestSource fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'chw':
        return EmergencyRequestSource.chw;
      case 'clinic':
        return EmergencyRequestSource.clinic;
      case 'refugee':
      default:
        return EmergencyRequestSource.refugee;
    }
  }
}

/// Lifecycle of an emergency dispatch.
enum EmergencyRequestStatus {
  pending,
  accepted,
  rejected,
  enRoute,
  arrived,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case EmergencyRequestStatus.pending:
        return 'Pending';
      case EmergencyRequestStatus.accepted:
        return 'Accepted';
      case EmergencyRequestStatus.rejected:
        return 'Rejected';
      case EmergencyRequestStatus.enRoute:
        return 'En Route';
      case EmergencyRequestStatus.arrived:
        return 'Arrived';
      case EmergencyRequestStatus.completed:
        return 'Completed';
      case EmergencyRequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  static EmergencyRequestStatus fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'pending':
        return EmergencyRequestStatus.pending;
      case 'accepted':
        return EmergencyRequestStatus.accepted;
      case 'rejected':
        return EmergencyRequestStatus.rejected;
      case 'enroute':
      case 'en_route':
        return EmergencyRequestStatus.enRoute;
      case 'arrived':
        return EmergencyRequestStatus.arrived;
      case 'completed':
        return EmergencyRequestStatus.completed;
      case 'cancelled':
      default:
        return EmergencyRequestStatus.cancelled;
    }
  }
}

/// An emergency ambulance request.
///
/// Created by a refugee, a CHW escalating a triage case, or a clinic
/// coordinating a transfer. Timestamped and pinned to GPS coordinates so
/// the medical team and camp managers can see the geography of emergencies.
class EmergencyRequest {
  final String id;
  final String patientId;
  final String patientName;
  final int? patientAge;
  final String? patientPhone;
  final EmergencyRequestSource source;

  /// 'emergency' | 'urgent' | 'routine' — maps to [TriagePriority].
  final String priority;
  final String? chiefComplaint;
  final String? notes;
  final String? settlementId;

  /// Last known GPS coordinate of the patient.
  final double? lat;
  final double? lng;

  final EmergencyRequestStatus status;
  final String? assignedAmbulanceId;
  final String? assignedDriverName;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  /// Vitals captured by CHW (if source is CHW) — useful for the driver.
  final Map<String, dynamic>? vitals;

  const EmergencyRequest({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.patientAge,
    this.patientPhone,
    required this.source,
    required this.priority,
    this.chiefComplaint,
    this.notes,
    this.settlementId,
    this.lat,
    this.lng,
    required this.status,
    this.assignedAmbulanceId,
    this.assignedDriverName,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
    this.vitals,
  });

  TriagePriority get triagePriority => TriagePriority.fromString(priority);

  Color get priorityColor => triagePriority.color;
  Color get prioritySurface => triagePriority.surface;

  EmergencyRequest copyWith({
    EmergencyRequestStatus? status,
    String? assignedAmbulanceId,
    String? assignedDriverName,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return EmergencyRequest(
      id: id,
      patientId: patientId,
      patientName: patientName,
      patientAge: patientAge,
      patientPhone: patientPhone,
      source: source,
      priority: priority,
      chiefComplaint: chiefComplaint,
      notes: notes,
      settlementId: settlementId,
      lat: lat,
      lng: lng,
      status: status ?? this.status,
      assignedAmbulanceId: assignedAmbulanceId ?? this.assignedAmbulanceId,
      assignedDriverName: assignedDriverName ?? this.assignedDriverName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      vitals: vitals,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'patientId': patientId,
    'patientName': patientName,
    'patientAge': patientAge,
    'patientPhone': patientPhone,
    'source': source.name,
    'priority': priority,
    'chiefComplaint': chiefComplaint,
    'notes': notes,
    'settlementId': settlementId,
    'lat': lat,
    'lng': lng,
    'status': status.name,
    'assignedAmbulanceId': assignedAmbulanceId,
    'assignedDriverName': assignedDriverName,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'vitals': vitals,
  };

  factory EmergencyRequest.fromJson(Map<String, dynamic> json) =>
      EmergencyRequest(
        id: json['id'] as String,
        patientId: json['patientId'] as String? ?? '',
        patientName: json['patientName'] as String? ?? '',
        patientAge: json['patientAge'] as int?,
        patientPhone: json['patientPhone'] as String?,
        source: EmergencyRequestSource.fromString(json['source'] as String?),
        priority: json['priority'] as String? ?? 'routine',
        chiefComplaint: json['chiefComplaint'] as String?,
        notes: json['notes'] as String?,
        settlementId: json['settlementId'] as String?,
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        status: EmergencyRequestStatus.fromString(json['status'] as String?),
        assignedAmbulanceId: json['assignedAmbulanceId'] as String?,
        assignedDriverName: json['assignedDriverName'] as String?,
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
            DateTime.now(),
        completedAt: json['completedAt'] != null
            ? DateTime.tryParse(json['completedAt'] as String)
            : null,
        vitals: json['vitals'] is Map<String, dynamic>
            ? json['vitals'] as Map<String, dynamic>
            : null,
      );
}
