import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  final DatabaseReference _root = FirebaseDatabase.instance.ref();

  // Push a user profile (called on sign up)
  Future<DatabaseReference> createUserProfile(
      Map<String, dynamic> profile) async {
    final ref = _root.child('users').push();
    final data = Map<String, dynamic>.from(profile);
    data['createdAt'] = ServerValue.timestamp;
    await ref.set(data);
    return ref;
  }

  // Log a global event (auth, service start/end, prescribe, etc.)
  Future<void> logEvent(Map<String, dynamic> event) async {
    final ref = _root.child('events').push();
    final data = Map<String, dynamic>.from(event);
    data['timestamp'] = ServerValue.timestamp;
    await ref.set(data);
  }

  // Start a session for a user; returns session key
  Future<String?> startSession(
      String actorKey, Map<String, dynamic> meta) async {
    final ref =
        _root.child('userActivity').child(actorKey).child('sessions').push();
    final data = Map<String, dynamic>.from(meta);
    data['loginAt'] = ServerValue.timestamp;
    await ref.set(data);
    return ref.key;
  }

  // End the session
  Future<void> endSession(String actorKey, String sessionId) async {
    final ref = _root
        .child('userActivity')
        .child(actorKey)
        .child('sessions')
        .child(sessionId);
    await ref.update({'logoutAt': ServerValue.timestamp});
  }

  // Append a service log entry
  Future<void> pushServiceLog(String service, Map<String, dynamic> log) async {
    final ref = _root.child('serviceLogs').child(service).push();
    await ref.set({
      ...log,
      'timestamp': ServerValue.timestamp,
    });
  }

  // Add a refugee profile to the join queue. Includes optional location.
  // Returns the pushed queue key on success.
  Future<String?> addToJoinQueue(Map<String, dynamic> profile,
      {double? lat, double? lng}) async {
    final ref = _root.child('joinQueue').push();
    final data = Map<String, dynamic>.from(profile);
    data['queuedAt'] = ServerValue.timestamp;
    if (lat != null && lng != null) {
      data['location'] = {'lat': lat, 'lng': lng};
    }
    await ref.set(data);
    return ref.key;
  }
}
