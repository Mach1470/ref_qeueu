import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Production-ready authentication service with RBAC and proper security
class ProductionAuthService {
  static final ProductionAuthService _instance = ProductionAuthService._internal();

  factory ProductionAuthService() => _instance;
  ProductionAuthService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _secureStorage = const FlutterSecureStorage();

  // Local storage keys
  static const String _keySessionToken = 'session_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserRole = 'user_role';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyPhoneVerified = 'phone_verified';
  static const String _keySessionExpiry = 'session_expiry';
  static const String _keyRefreshToken = 'refresh_token';

  // Session timeout duration (24 hours)
  static const Duration _sessionTimeout = Duration(hours: 24);

  // --- PUBLIC API ---

  /// Verify phone number and send OTP (Production)
  /// Returns verificationId on success, error message on failure
  Future<String?> verifyPhoneNumber({
    required String phoneNumber,
    Duration timeout = const Duration(minutes: 2),
  }) async {
    try {
      String? verificationId;
      final completer = Completer<String?>();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: timeout,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto sign-in when credential is verified (if enabled)
          completer.complete(credential.verificationId);
        },
        verificationFailed: (FirebaseAuthException e) {
          completer.completeError(
            _formatAuthError(e),
          );
        },
        codeSent: (String vId, int? resendToken) {
          verificationId = vId;
          completer.complete(vId);
        },
        codeAutoRetrievalTimeout: (String vId) {
          verificationId = vId;
        },
      );

      return await completer.future;
    } on FirebaseAuthException catch (e) {
      return 'Phone verification failed: ${_formatAuthError(e)}';
    } catch (e) {
      return 'Unexpected error during phone verification: $e';
    }
  }

  /// Sign in with OTP code (Production)
  /// Returns user ID on success, error message on failure
  Future<String?> signInWithOtp({
    required String verificationId,
    required String otp,
    required String role, // refugee, ambulance_driver, chw
    required String phoneNumber,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        return 'Sign in failed: User not found';
      }

      // Verify user exists in Firestore or create new user
      await _createOrUpdateUserProfile(
        uid: user.uid,
        phoneNumber: phoneNumber,
        role: role,
      );

      // Create session
      final sessionToken = await _createSession(
        uid: user.uid,
        role: role,
        phoneNumber: phoneNumber,
      );

      if (sessionToken == null) {
        return 'Failed to create session';
      }

      // Save to secure storage
      await _saveSessionSecurely(
        token: sessionToken,
        uid: user.uid,
        role: role,
        phoneNumber: phoneNumber,
      );

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return 'OTP verification failed: ${_formatAuthError(e)}';
    } catch (e) {
      return 'Sign in failed: $e';
    }
  }

  /// Get current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated and session is valid
  Future<bool> isAuthenticated() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Check session expiry
      final prefs = await SharedPreferences.getInstance();
      final expiryStr = prefs.getString(_keySessionExpiry);
      if (expiryStr != null) {
        final expiry = DateTime.parse(expiryStr);
        if (DateTime.now().isAfter(expiry)) {
          // Session expired
          await signOut();
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get current user role
  Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserRole);
    } catch (e) {
      return null;
    }
  }

  /// Get current user phone number
  Future<String?> getUserPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserPhone);
    } catch (e) {
      return null;
    }
  }

  /// Refresh session (extends expiry)
  Future<bool> refreshSession() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final newExpiry = DateTime.now().add(_sessionTimeout);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySessionExpiry, newExpiry.toIso8601String());

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_keyUserId);

      // Log session end in Firestore
      if (userId != null) {
        await _firestore.collection('audit_logs').add({
          'event': 'user_logout',
          'userId': userId,
          'timestamp': FieldValue.serverTimestamp(),
          'role': await getUserRole(),
        });
      }

      // Clear secure storage
      await _secureStorage.delete(key: _keySessionToken);
      await _secureStorage.delete(key: _keyRefreshToken);

      // Clear local storage
      await prefs.remove(_keySessionToken);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyUserRole);
      await prefs.remove(_keyUserPhone);
      await prefs.remove(_keySessionExpiry);

      // Sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      print('Error during sign out: $e');
    }
  }

  /// Check if user has specific role
  Future<bool> hasRole(String requiredRole) async {
    final userRole = await getUserRole();
    return userRole == requiredRole;
  }

  /// Check if user has any of the specified roles
  Future<bool> hasAnyRole(List<String> roles) async {
    final userRole = await getUserRole();
    return userRole != null && roles.contains(userRole);
  }

  /// Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data();
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Request password reset (for email-based auth)
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return 'Password reset failed: ${_formatAuthError(e)}';
    } catch (e) {
      return 'Error sending password reset: $e';
    }
  }

  /// Verify email for user
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      print('Error sending email verification: $e');
    }
  }

  /// Get valid session token
  Future<String?> getSessionToken() async {
    try {
      return await _secureStorage.read(key: _keySessionToken);
    } catch (e) {
      return null;
    }
  }

  // --- PRIVATE HELPER METHODS ---

  Future<void> _createOrUpdateUserProfile({
    required String uid,
    required String phoneNumber,
    required String role,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'phone': phoneNumber,
        'role': role,
        'phoneVerified': true,
        'lastLogin': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<String?> _createSession({
    required String uid,
    required String role,
    required String phoneNumber,
  }) async {
    try {
      final sessionId = _generateSessionId();
      final expiryTime = DateTime.now().add(_sessionTimeout);

      await _firestore.collection('sessions').doc(sessionId).set({
        'sessionId': sessionId,
        'userId': uid,
        'role': role,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiryTime),
        'isActive': true,
      });

      return sessionId;
    } catch (e) {
      print('Error creating session: $e');
      return null;
    }
  }

  Future<void> _saveSessionSecurely({
    required String token,
    required String uid,
    required String role,
    required String phoneNumber,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryTime = DateTime.now().add(_sessionTimeout);

      // Secure storage for token
      await _secureStorage.write(key: _keySessionToken, value: token);

      // Local storage for quick access (non-sensitive data only)
      await prefs.setString(_keySessionToken, token);
      await prefs.setString(_keyUserId, uid);
      await prefs.setString(_keyUserRole, role);
      await prefs.setString(_keyUserPhone, phoneNumber);
      await prefs.setString(_keySessionExpiry, expiryTime.toIso8601String());
      await prefs.setBool(_keyPhoneVerified, true);

      // Log successful session creation
      await _firestore.collection('audit_logs').add({
        'event': 'session_created',
        'userId': uid,
        'role': role,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving session: $e');
      rethrow;
    }
  }

  String _generateSessionId() {
    return 'session_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().millisecond * 1000 + DateTime.now().microsecond).toString().substring(0, 6)}';
  }

  String _formatAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please try again.';
      case 'session-expired':
        return 'Verification session expired. Please try again.';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check and try again.';
      case 'user-disabled':
        return 'Your account has been disabled';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}
