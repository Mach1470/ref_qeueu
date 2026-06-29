/// A pending action stored locally while the device is offline.
///
/// When connectivity is restored, the SyncService replays these against
/// Firestore and clears the row on success.
class SyncQueueEntry {
  final int? id; // local SQLite primary key
  final String type; // 'join_queue' | 'ambulance_request' | 'chw_visit' | 'triage'
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;

  const SyncQueueEntry({
    this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
    this.lastError,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type,
        'payload': payload,
        'createdAt': createdAt.toIso8601String(),
        'attempts': attempts,
        'lastError': lastError,
      };

  factory SyncQueueEntry.fromMap(Map<String, dynamic> m) => SyncQueueEntry(
        id: m['id'] as int?,
        type: m['type'] as String? ?? '',
        payload: (m['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
        createdAt: DateTime.tryParse(m['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        attempts: (m['attempts'] as int?) ?? 0,
        lastError: m['lastError'] as String?,
      );

  SyncQueueEntry copyWith({int? attempts, String? lastError}) =>
      SyncQueueEntry(
        id: id,
        type: type,
        payload: payload,
        createdAt: createdAt,
        attempts: attempts ?? this.attempts,
        lastError: lastError ?? this.lastError,
      );
}
