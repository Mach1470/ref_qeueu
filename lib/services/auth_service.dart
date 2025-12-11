// Auth Service with login persistence
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ref_qeueu/services/database_service.dart';

class AuthService {
  static const String _keyUserRole = 'user_role';
  static const String _keyUserId = 'user_id';
  static const String _keyRememberedRole = 'remembered_role';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserEmail = 'user_email';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyPharmacyId = 'pharmacy_id';
  static const String _keySessionId = 'session_id';

  // Simulate sending OTP. Return a fake verificationId on success.
  Future<String?> sendOtp({required String phone}) async {
    await Future.delayed(const Duration(seconds: 1));
    // In production use FirebaseAuth.instance.verifyPhoneNumber(...)
    // For demo return a fake id
    return 'demo-verification-id';
  }

  // Simulate verifying OTP. Return null on success, or error string.
  Future<String?> verifyOtp(
      {required String verificationId, required String otp}) async {
    await Future.delayed(const Duration(seconds: 1));
    if (otp == '123456') {
      // success
      return null;
    } else {
      return 'Invalid code. Use 123456 for demo.';
    }
  }

  // Simulate email/id+password sign in
  Future<String?> signInWithEmailOrId(
      {required String idOrEmail,
      required String password,
      String? role}) async {
    await Future.delayed(const Duration(seconds: 1));
    // demo: password 'password' works
    if (password == 'password') {
      // Save login state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserEmail, idOrEmail);
      if (role != null) {
        await prefs.setString(_keyUserRole, role);
      }
      // Log event and start session
      try {
        final actorKey = idOrEmail.replaceAll('.', '_');
        await DatabaseService.instance.logEvent({
          'type': 'signin',
          'actor': actorKey,
          'role': role ?? 'user',
        });
        final sessionId = await DatabaseService.instance
            .startSession(actorKey, {'method': 'email'});
        if (sessionId != null) await prefs.setString(_keySessionId, sessionId);
      } catch (_) {}
      return null;
    }
    return 'Invalid credentials (demo). Use password = "password".';
  }

  // Simulate sign up
  Future<String?> signUpBasic(
      {required String individualNumber,
      required String phone,
      String? password,
      String? email}) async {
    await Future.delayed(const Duration(seconds: 1));
    // Save sign up state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, individualNumber);
    await prefs.setString(_keyUserPhone, phone);
    if (email != null && email.isNotEmpty) {
      await prefs.setString(_keyUserEmail, email);
    }
    // Attempt to create a Firebase Auth user when possible so the user shows up
    // in the Firebase Authentication console. Prefer creating with provided
    // email+password; if email is missing but a password exists we create a
    // synthetic email based on phone/ID so the account is still created.
    try {
      UserCredential? cred;
      final auth = FirebaseAuth.instance;
      if (email != null &&
          email.isNotEmpty &&
          password != null &&
          password.isNotEmpty) {
        cred = await auth.createUserWithEmailAndPassword(
            email: email, password: password);
      } else if (password != null && password.isNotEmpty) {
        // Create a synthetic email from phone or individualNumber to register
        final safe = (phone.isNotEmpty
            ? phone.replaceAll(RegExp(r'[^0-9]'), '')
            : individualNumber);
        final syntheticEmail = '$safe@phone.refugee.local';
        cred = await auth.createUserWithEmailAndPassword(
            email: syntheticEmail, password: password);
        // Save the synthetic email locally so subsequent sign-in can use it
        await prefs.setString(_keyUserEmail, syntheticEmail);
      }

      // If we created a Firebase user, include the uid in the profile written
      // to the Realtime Database for easier mapping.
      final profile = <String, dynamic>{
        'individualNumber': individualNumber,
        'phone': phone,
        'email': prefs.getString(_keyUserEmail),
        'role': 'refugee',
      };
      if (cred?.user != null) profile['uid'] = cred!.user!.uid;

      await DatabaseService.instance.createUserProfile(profile);
      await DatabaseService.instance.logEvent({
        'type': 'signup',
        'actor': profile['uid'] ?? phone,
        'role': 'refugee',
      });
      // If Firebase user was created, start a session and save session id locally
      if (cred?.user != null) {
        final actorKey = cred!.user!.uid;
        final sessionId = await DatabaseService.instance
            .startSession(actorKey, {'method': 'signup'});
        if (sessionId != null) await prefs.setString(_keySessionId, sessionId);
      }
    } catch (e) {
      // Non-fatal: fall back to storing profile in DB without an auth user
      try {
        await DatabaseService.instance.createUserProfile({
          'individualNumber': individualNumber,
          'phone': phone,
          'email': prefs.getString(_keyUserEmail),
          'role': 'refugee',
        });
        await DatabaseService.instance.logEvent({
          'type': 'signup',
          'actor': phone,
          'role': 'refugee',
        });
      } catch (_) {}
    }
    // return null on success
    // After creating the profile, also add the primary user to the join queue
    try {
      final actorKey = (email ?? phone).replaceAll('+', '').replaceAll(RegExp(r'[^0-9a-zA-Z]'), '_');
      final profile = {
        'individualNumber': individualNumber,
        'phone': phone,
        'email': prefs.getString(_keyUserEmail),
        'role': 'refugee',
        'name': prefs.getString('user_name') ?? individualNumber,
      };
      // Fire-and-forget; do not block signup flow on DB network
      Future(() async {
        try {
          await DatabaseService.instance.addToJoinQueue(profile);
        } catch (_) {}
      });
    } catch (_) {}

    return null;
  }

  // Family member helpers (stored locally under the owner's device)
  Future<void> addFamilyMember(Map<String, dynamic> member) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'family_members';
    final existing = prefs.getStringList(key) ?? <String>[];
    existing.add(member.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&'));
    await prefs.setStringList(key, existing);
  }

  Future<List<Map<String, String>>> getFamilyMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'family_members';
    final existing = prefs.getStringList(key) ?? <String>[];
    final out = <Map<String, String>>[];
    for (final s in existing) {
      final map = <String, String>{};
      for (final part in s.split('&')) {
        final kv = part.split('=');
        if (kv.length == 2) {
          map[kv[0]] = Uri.decodeComponent(kv[1]);
        }
      }
      out.add(map);
    }
    return out;
  }

  // Save login state for refugee (phone login)
  // Save login state for refugee (phone login)
  // Optional demo fields let callers populate a small local demo profile
  Future<void> saveRefugeeLogin(String phone,
      {String? displayName, String? demoId, int? queuePosition}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserRole, 'refugee');
    await prefs.setString(_keyRememberedRole, 'refugee');
    await prefs.setString(_keyUserPhone, phone);

    // Optionally persist demo-visible fields locally so the UI can show them
    if (displayName != null && displayName.isNotEmpty) {
      await prefs.setString('user_name', displayName);
    }
    if (demoId != null && demoId.isNotEmpty) {
      await prefs.setString(_keyUserId, demoId);
    }
    if (queuePosition != null) {
      await prefs.setInt('queue_position', queuePosition);
    }

    // Log auth event and start session in Realtime DB
    try {
      final actorKey =
          phone.replaceAll('+', '').replaceAll(RegExp(r'[^0-9]'), '');

      // Create a lightweight demo profile record when demo details are provided
      if (displayName != null || demoId != null) {
        try {
          await DatabaseService.instance.createUserProfile({
            'name': displayName ?? 'Refugee',
            'phone': phone,
            'role': 'refugee',
            'demoId': demoId ?? '',
          });
        } catch (_) {}
      }

      await DatabaseService.instance.logEvent({
        'type': 'signin',
        'actor': actorKey,
        'role': 'refugee',
        'method': 'phone'
      });
      final sessionId = await DatabaseService.instance
          .startSession(actorKey, {'method': 'phone'});
      if (sessionId != null) await prefs.setString(_keySessionId, sessionId);
    } catch (_) {}
  }

  // Save login state for doctor
  Future<void> saveDoctorLogin(String doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserRole, 'doctor');
    await prefs.setString(_keyRememberedRole, 'doctor');
    await prefs.setString(_keyUserId, doctorId);
    try {
      final actorKey = doctorId;
      await DatabaseService.instance.logEvent({
        'type': 'signin',
        'actor': actorKey,
        'role': 'doctor',
      });
      final sessionId = await DatabaseService.instance
          .startSession(actorKey, {'method': 'password'});
      if (sessionId != null) await prefs.setString(_keySessionId, sessionId);
    } catch (_) {}
  }

  // Save login state for pharmacy
  Future<void> savePharmacyLogin(String pharmacyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserRole, 'pharmacy');
    await prefs.setString(_keyRememberedRole, 'pharmacy');
    await prefs.setString(_keyPharmacyId, pharmacyId);
    try {
      final actorKey = pharmacyId;
      await DatabaseService.instance.logEvent({
        'type': 'signin',
        'actor': actorKey,
        'role': 'pharmacy',
      });
      final sessionId = await DatabaseService.instance
          .startSession(actorKey, {'method': 'password'});
      if (sessionId != null) await prefs.setString(_keySessionId, sessionId);
    } catch (_) {}
  }

  // Save login state for lab
  Future<void> saveLabLogin(String labId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserRole, 'lab');
    await prefs.setString(_keyRememberedRole, 'lab');
    await prefs.setString(_keyUserId, labId);
    try {
      final actorKey = labId;
      await DatabaseService.instance.logEvent({
        'type': 'signin',
        'actor': actorKey,
        'role': 'lab',
      });
      final sessionId = await DatabaseService.instance
          .startSession(actorKey, {'method': 'password'});
      if (sessionId != null) await prefs.setString(_keySessionId, sessionId);
    } catch (_) {}
  }

  // Save login state for maternity (mirrors other role methods)
  Future<void> saveMaternityLogin(String maternityId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserRole, 'maternity');
    await prefs.setString(_keyRememberedRole, 'maternity');
    await prefs.setString(_keyUserId, maternityId);
    try {
      final actorKey = maternityId;
      // Perform logging/session start in a fire-and-forget future so that
      // lack of Realtime DB connectivity doesn't block the login flow.
      Future(() async {
        try {
          await DatabaseService.instance.logEvent({
            'type': 'signin',
            'actor': actorKey,
            'role': 'maternity',
          });
          final sessionId = await DatabaseService.instance
              .startSession(actorKey, {'method': 'password'});
          if (sessionId != null) {
            // store session id if available (no await - background)
            prefs.setString(_keySessionId, sessionId);
          }
        } catch (_) {}
      });
    } catch (_) {}
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (e) {
      // If SharedPreferences fails, return false
      return false;
    }
  }

  // Get saved user role
  Future<String?> getUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserRole);
    } catch (e) {
      return null;
    }
  }

  // Get saved user ID
  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserId);
    } catch (e) {
      return null;
    }
  }

  // Get saved phone
  Future<String?> getUserPhone() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserPhone);
    } catch (e) {
      return null;
    }
  }

  // Get saved email
  Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserEmail);
    } catch (e) {
      return null;
    }
  }

  // Logout - clear all saved data
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // End session in Realtime DB if present
    try {
      final role = prefs.getString(_keyUserRole);
      final sessionId = prefs.getString(_keySessionId);
      String? actorKey;
      if (role == 'refugee') {
        actorKey = prefs
            .getString(_keyUserPhone)
            ?.replaceAll('+', '')
            .replaceAll(RegExp(r'[^0-9]'), '');
      }
      if (role == 'doctor' || role == 'lab') {
        actorKey = prefs.getString(_keyUserId);
      }
      if (role == 'pharmacy') actorKey = prefs.getString(_keyPharmacyId);
      if (actorKey != null && sessionId != null) {
        await DatabaseService.instance.endSession(actorKey, sessionId);
        await DatabaseService.instance.logEvent({
          'type': 'signout',
          'actor': actorKey,
          'role': role ?? 'user',
        });
      }
    } catch (_) {}
    // Preserve the remembered role across logout
    final remembered = prefs.getString(_keyRememberedRole);
    await prefs.clear();
    if (remembered != null) {
      await prefs.setString(_keyRememberedRole, remembered);
    }
  }

  Future<void> setRememberedRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRememberedRole, role);
  }

  Future<String?> getRememberedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRememberedRole);
  }

  Future<void> clearRememberedRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRememberedRole);
  }

  // Get route based on saved role
  Future<String?> getSavedRoute() async {
    try {
      final role = await getUserRole() ?? await getRememberedRole();
      switch (role) {
        case 'refugee':
          return '/refugee_home';
        case 'doctor':
          return '/doctor_home';
        case 'pharmacy':
          return '/pharmacy_dashboard';
        case 'lab':
          return '/lab_home';
        case 'maternity':
          return '/maternity_home';
        default:
          return null;
      }
    } catch (e) {
      // If there's an error, return null to default to onboarding
      return null;
    }
  }
}
