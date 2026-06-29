import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sync_queue_entry.dart';

/// Lightweight service that detects connectivity, persists a queue of
/// pending mutations to local storage, and flushes the queue when the
/// network comes back.
///
/// This service is intentionally framework-agnostic: the actual Firestore
/// call for each entry is delegated to [syncHandler], which the caller
/// provides (e.g. `DatabaseService.applySyncEntry`). The handler returns
/// `true` on success and `false` (or throws) on failure.
class OfflineSyncService extends ChangeNotifier {
  static const String _prefsKey = 'offline_sync_queue_v1';
  static const int maxAttempts = 5;

  bool _online = true;
  bool get online => _online;

  bool _syncing = false;
  bool get syncing => _syncing;

  int _pendingCount = 0;
  int get pendingCount => _pendingCount;

  final List<SyncQueueEntry> _queue = [];

  /// Stream of connectivity transitions: emits `true` when going online,
  /// `false` when going offline. The [flush] method should be called
  /// when an online transition is observed.
  final _connectivityController = StreamController<bool>.broadcast();
  Stream<bool> get connectivityChanges => _connectivityController.stream;

  /// Provider-supplied callback that performs the actual Firestore write
  /// for a queued entry. Return `true` on success.
  Future<bool> Function(SyncQueueEntry entry)? syncHandler;

  StreamSubscription<List<ConnectivityResult>>? _sub;

  OfflineSyncService({this.syncHandler});

  /// Load the persisted queue and start listening for connectivity changes.
  Future<void> initialize() async {
    await _loadQueue();

    // Seed with a known online state — we don't yet know the real one.
    _online = true;

    try {
      final initial = await Connectivity().checkConnectivity();
      _online = _isOnlineResult(initial);
    } catch (_) {
      _online = true; // fail-open so the app remains usable if plugin errors
    }

    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final wasOnline = _online;
      _online = _isOnlineResult(results);
      if (!wasOnline && _online) {
        _connectivityController.add(true);
        // Fire and forget — UI shows the syncing indicator via [_syncing].
        flush();
      } else if (wasOnline && !_online) {
        _connectivityController.add(false);
      }
      notifyListeners();
    });
  }

  bool _isOnlineResult(List<ConnectivityResult> results) {
    if (results.isEmpty) return true; // assume online when uncertain
    return results.any((r) => r != ConnectivityResult.none);
  }

  /// Enqueue a mutation to be applied to Firestore later.
  ///
  /// If we are currently online, this still queues the entry but also
  /// attempts an immediate flush so successful mutations are mirrored
  /// locally for offline replay.
  Future<void> enqueue({
    required String collection,
    required String documentId,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
  }) async {
    final entry = SyncQueueEntry(
      id: '${DateTime.now().microsecondsSinceEpoch}_$documentId',
      collection: collection,
      documentId: documentId,
      operation: operation,
      payload: payload,
      createdAt: DateTime.now(),
    );
    _queue.add(entry);
    _pendingCount = _queue.where((e) => e.status != SyncEntryStatus.done)
        .length;
    await _persistQueue();
    notifyListeners();

    if (_online) {
      // Don't await — caller shouldn't block on the network round-trip.
      unawaited(flush());
    }
  }

  /// Attempt to flush all pending entries to Firestore. Each entry's
  /// handler is invoked sequentially. Failed entries are kept in the
  /// queue with an incremented attempt counter.
  Future<void> flush() async {
    if (_syncing || syncHandler == null) return;
    if (_queue.isEmpty) return;
    _syncing = true;
    notifyListeners();

    try {
      final pending = _queue
          .where((e) => e.status != SyncEntryStatus.done)
          .toList(growable: false);

      for (var i = 0; i < _queue.length; i++) {
        final entry = _queue[i];
        if (entry.status == SyncEntryStatus.done) continue;
        if (!pending.contains(entry)) continue;

        _queue[i] = entry.copyWith(
          status: SyncEntryStatus.syncing,
          lastAttemptAt: DateTime.now(),
          attempts: entry.attempts + 1,
        );
        notifyListeners();

        try {
          final ok = await syncHandler!(_queue[i]);
          if (ok) {
            _queue[i] = _queue[i].copyWith(
              status: SyncEntryStatus.done,
              syncedAt: DateTime.now(),
              lastError: null,
            );
          } else {
            _queue[i] = _queue[i].copyWith(
              status: entry.attempts + 1 >= maxAttempts
                  ? SyncEntryStatus.failed
                  : SyncEntryStatus.pending,
              lastError: 'handler_returned_false',
            );
          }
        } catch (e) {
          _queue[i] = _queue[i].copyWith(
            status: entry.attempts + 1 >= maxAttempts
                ? SyncEntryStatus.failed
                : SyncEntryStatus.pending,
            lastError: e.toString(),
          );
        }
        await _persistQueue();
      }
    } finally {
      _syncing = false;
      _pendingCount = _queue.where((e) => e.status != SyncEntryStatus.done)
          .length;
      notifyListeners();
    }
  }

  Future<void> _loadQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null || raw.isEmpty) {
      _pendingCount = 0;
      return;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _queue
        ..clear()
        ..addAll(list
            .whereType<Map<String, dynamic>>()
            .map(SyncQueueEntry.fromJson));
      _pendingCount = _queue.where((e) => e.status != SyncEntryStatus.done)
          .length;
    } catch (_) {
      // Corrupt data — start clean rather than crash the app.
      _queue.clear();
      _pendingCount = 0;
      await prefs.remove(_prefsKey);
    }
  }

  Future<void> _persistQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_queue.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  /// Drop entries that have been successfully synced.
  Future<void> pruneSynced() async {
    _queue.removeWhere((e) => e.status == SyncEntryStatus.done);
    _pendingCount = _queue.length;
    await _persistQueue();
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _connectivityController.close();
    super.dispose();
  }
}
