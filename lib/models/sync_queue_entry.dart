/// The kind of mutation that is queued for later sync.
enum SyncOperation {
  create,
  update,
  delete;

  String get label {
    switch (this) {
      case SyncOperation.create:
        return 'create';
      case SyncOperation.update:
        return 'update';
      case SyncOperation.delete:
        return 'delete';
    }
  }

  static SyncOperation fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'update':
        return SyncOperation.update;
      case 'delete':
        return SyncOperation.delete;
      case 'create':
      default:
        return SyncOperation.create;
    }
  }
}

/// Status of a queued sync entry.
enum SyncEntryStatus {
  pending,
  syncing,
  failed,
  done;

  static SyncEntryStatus fromString(String? value) {
    switch ((value ?? '').toLowerCase()) {
      case 'syncing':
        return SyncEntryStatus.syncing;
      case 'failed':
        return SyncEntryStatus.failed;
      case 'done':
        return SyncEntryStatus.done;
      case 'pending':
      default:
        return SyncEntryStatus.pending;
    }
  }
}

/// An entry in the offline sync queue.
///
/// Created when a mutation (visit record, queue join, ambulance status,
/// emergency request) is performed while the device is offline. The entry
/// is persisted locally and re-attempted when connectivity is restored.
class SyncQueueEntry {
  final String id;
  final String collection;
  final String documentId;
  final SyncOperation operation;
  final Map<String, dynamic> payload;

  final SyncEntryStatus status;
  final int attempts;
  final String? lastError;

  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final DateTime? syncedAt;

  const SyncQueueEntry({
    required this.id,
    required this.collection,
    required this.documentId,
    required this.operation,
    required this.payload,
    this.status = SyncEntryStatus.pending,
    this.attempts = 0,
    this.lastError,
    required this.createdAt,
    this.lastAttemptAt,
    this.syncedAt,
  });

  SyncQueueEntry copyWith({
    SyncEntryStatus? status,
    int? attempts,
    String? lastError,
    DateTime? lastAttemptAt,
    DateTime? syncedAt,
  }) {
    return SyncQueueEntry(
      id: id,
      collection: collection,
      documentId: documentId,
      operation: operation,
      payload: payload,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'collection': collection,
    'documentId': documentId,
    'operation': operation.name,
    'payload': payload,
    'status': status.name,
    'attempts': attempts,
    'lastError': lastError,
    'createdAt': createdAt.toIso8601String(),
    'lastAttemptAt': lastAttemptAt?.toIso8601String(),
    'syncedAt': syncedAt?.toIso8601String(),
  };

  factory SyncQueueEntry.fromJson(Map<String, dynamic> json) => SyncQueueEntry(
    id: json['id'] as String,
    collection: json['collection'] as String? ?? '',
    documentId: json['documentId'] as String? ?? '',
    operation: SyncOperation.fromString(json['operation'] as String?),
    payload: (json['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
    status: SyncEntryStatus.fromString(json['status'] as String?),
    attempts: json['attempts'] as int? ?? 0,
    lastError: json['lastError'] as String?,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    lastAttemptAt: json['lastAttemptAt'] != null
        ? DateTime.tryParse(json['lastAttemptAt'] as String)
        : null,
    syncedAt: json['syncedAt'] != null
        ? DateTime.tryParse(json['syncedAt'] as String)
        : null,
  );
}
