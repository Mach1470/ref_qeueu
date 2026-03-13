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
  static const String _keyRememberedAccounts = 'remembered_accounts';

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

  // Login with email/id with timeouts
  Future<String?> signInWithEmailOrId(
      {required String idOrEmail,
      required String password,
      String? role}) async {
    try {
      await Future.delayed(const Duration(seconds: 1))
          .timeout(const Duration(seconds: 5));

      // demo: password 'password' works
      if (password == 'password') {
        final prefs = await SharedPreferences.getInstance()
            .timeout(const Duration(seconds: 5));
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyUserEmail, idOrEmail);
        if (role != null) {
          await prefs.setString(_keyUserRole, role);
        }
        
        // Remember account for multi-account selector
        await rememberAccount(
          id: idOrEmail,
          name: idOrEmail.split('@')[0], // Extract name from email or use id
          role: role ?? 'user',
          email: idOrEmail.contains('@') ? idOrEmail : null,
        );

        // Log event and start session - wrap in try-catch and timeout to prevent hang
        try {
          final actorKey = idOrEmail.replaceAll('.', '_');
          await DatabaseService.instance.logEvent({
            'type': 'signin',
            'actor': actorKey,
            'role': role ?? 'user',
          }).timeout(const Duration(seconds: 10));

          final sessionId = await DatabaseService.instance.startSession(
              actorKey,
              {'method': 'email'}).timeout(const Duration(seconds: 10));

          if (sessionId != null) {
            await prefs.setString(_keySessionId, sessionId);
          }
        } catch (dbError) {
          print('DEBUG: Non-fatal DB error during signin: $dbError');
          // Still return null (success) because local auth state is saved
        }
        return null;
      }
      return 'Invalid credentials (demo). Use password = "password".';
    } catch (e) {
      print('DEBUG: signInWithEmailOrId error: $e');
      return 'Login failed: ${e.toString()}';
    }
  }

  // Sign up with logging and timeouts for debugging
  Future<String?> signUpBasic(
      {required String individualNumber,
      required String phone,
      required String name,
      required String dob,
      String? password,
      String? email}) async {
    print('DEBUG: signUpBasic started for $individualNumber ($name)');

    try {
      await Future.delayed(const Duration(seconds: 1))
          .timeout(const Duration(seconds: 5));

      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 5));
      await prefs.setString(_keyUserId, individualNumber);
      await prefs.setString(_keyUserPhone, phone);
      if (email != null && email.isNotEmpty) {
        await prefs.setString(_keyUserEmail, email);
      }

      print('DEBUG: prefs saved. Attempting Firebase Auth...');

      UserCredential? cred;
      final auth = FirebaseAuth.instance;

      try {
        if (email != null &&
            email.isNotEmpty &&
            password != null &&
            password.isNotEmpty) {
          cred = await auth
              .createUserWithEmailAndPassword(email: email, password: password)
              .timeout(const Duration(seconds: 15));
        } else if (password != null && password.isNotEmpty) {
          final safe = (phone.isNotEmpty
              ? phone.replaceAll(RegExp(r'[^0-9]'), '')
              : individualNumber);
          final syntheticEmail = '$safe@phone.refugee.local';
          cred = await auth
              .createUserWithEmailAndPassword(
                  email: syntheticEmail, password: password)
              .timeout(const Duration(seconds: 15));
          await prefs.setString(_keyUserEmail, syntheticEmail);
        }
        print('DEBUG: Firebase Auth success: ${cred?.user?.uid}');
      } catch (authError) {
        print('DEBUG: Firebase Auth failed (non-fatal): $authError');
        // Continue to profile creation even if auth fails (offline or config issues)
      }

      final profile = <String, dynamic>{
        'name': name,
        'dob': dob,
        'individualNumber': individualNumber,
        'phone': phone,
        'email': prefs.getString(_keyUserEmail),
        'role': 'refugee',
        'createdAt': DateTime.now().toIso8601String(),
      };
      if (cred?.user != null) profile['uid'] = cred!.user!.uid;

      print('DEBUG: Creating user profile in Database...');
      // Increased timeout to 20s to prevent premature failure on slow networks
      await DatabaseService.instance
          .createUserProfile(profile)
          .timeout(const Duration(seconds: 20), onTimeout: () {
        print('DEBUG: Database createUserProfile timed out, but proceeding...');
      });

      print('DEBUG: Logging event...');
      await DatabaseService.instance.logEvent({
        'type': 'signup',
        'actor': profile['uid'] ?? phone,
        'role': 'refugee',
      }).timeout(const Duration(seconds: 5));

      if (cred?.user != null) {
        print('DEBUG: Starting session...');
        final actorKey = cred!.user!.uid;
        final sessionId = await DatabaseService.instance.startSession(actorKey,
            {'method': 'signup'}).timeout(const Duration(seconds: 10));
        if (sessionId != null) await prefs.setString(_keySessionId, sessionId);
      }

      print('DEBUG: signUpBasic completed successfully');
    } catch (e) {
      print('DEBUG: signUpBasic fatal error: $e');
      return 'Signup failed: ${e.toString()}';
    }

    // After creating the profile, also add the primary user to the join queue
    try {
      final profile = {
        'individualNumber': individualNumber,
        'phone': phone,
        'email': (email != null && email.isNotEmpty)
            ? email
            : '$individualNumber@phone.refugee.local',
        'role': 'refugee',
        'name': individualNumber,
      };
      unawaited(DatabaseService.instance
          .addToJoinQueue(profile)
          .timeout(const Duration(seconds: 10)));
    } catch (_) {}

    return null;
  }

  // Family member helpers (synced with Firestore)
  Future<void> addFamilyMember(Map<String, dynamic> member) async {
    final prefs = await SharedPreferences.getInstance();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // 1. Save locally for immediate UI update
    final key = 'family_members';
    final existing = prefs.getStringList(key) ?? <String>[];
    existing.add(member.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&'));
    await prefs.setStringList(key, existing);

    // 2. Sync to Firestore if logged in
    if (uid != null) {
      try {
        await DatabaseService.instance.addFamilyMember(uid, member);
      } catch (e) {
        print('DEBUG: Error syncing family member to Firestore: $e');
      }
    }
  }

  Future<List<Map<String, String>>> getFamilyMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'family_members';
    final existing = prefs.getStringList(key) ?? <String>[];

    final out = <Map<String, String>>[];
    if (existing.isNotEmpty) {
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
    } else {
      // Fallback: Fetch from Firestore if local is empty and user is logged in
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        try {
          final remoteMembers =
              await DatabaseService.instance.getFamilyMembers(uid);
          for (final member in remoteMembers) {
            final map = member.map((k, v) => MapEntry(k, v.toString()));
            out.add(map);

            // Re-populate local cache
            existing.add(map.entries
                .map((e) =>
                    '${e.key}=${Uri.encodeComponent(e.value.toString())}')
                .join('&'));
          }
          if (existing.isNotEmpty) await prefs.setStringList(key, existing);
        } catch (e) {
          print('DEBUG: Error fetching family members from Firestore: $e');
        }
      }
    }
    return out;
  }

  // Save login state for refugee (phone login)
  // Save login state for refugee (phone login) with timeouts
  Future<void> saveRefugeeLogin(String phone,
      {String? displayName, String? demoId, int? queuePosition}) async {
    try {
      final prefs = await SharedPreferences.getInstance()
          .timeout(const Duration(seconds: 5));
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserRole, 'refugee');
      await prefs.setString(_keyRememberedRole, 'refugee');
      await prefs.setString(_keyUserPhone, phone);

      if (displayName != null && displayName.isNotEmpty) {
        await prefs.setString('user_name', displayName);
      }
      if (demoId != null && demoId.isNotEmpty) {
        await prefs.setString(_keyUserId, demoId);
      }
      
      // Remember account for multi-account selector
      await rememberAccount(
        id: phone,
        name: displayName ?? 'Refugee',
        role: 'refugee',
        phone: phone,
      );
      if (queuePosition != null) {
        await prefs.setInt('queue_position', queuePosition);
      }

      // Log auth event and start session in Realtime DB in the background
      unawaited(Future(() async {
        try {
          final actorKey =
              phone.replaceAll('+', '').replaceAll(RegExp(r'[^0-9]'), '');

          if (displayName != null || demoId != null) {
            try {
              await DatabaseService.instance.createUserProfile({
                'name': displayName ?? 'Refugee',
                'phone': phone,
                'role': 'refugee',
                'demoId': demoId ?? '',
              }).timeout(const Duration(seconds: 10));
            } catch (_) {}
          }

          await DatabaseService.instance.logEvent({
            'type': 'signin',
            'actor': actorKey,
            'role': 'refugee',
            'method': 'phone'
          }).timeout(const Duration(seconds: 10));

          final sessionId = await DatabaseService.instance.startSession(
              actorKey,
              {'method': 'phone'}).timeout(const Duration(seconds: 10));

          if (sessionId != null) {
            final p = await SharedPreferences.getInstance();
            await p.setString(_keySessionId, sessionId);
          }
        } catch (_) {}
      }));
    } catch (e) {
      print('DEBUG: saveRefugeeLogin local error: $e');
    }
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
    // Preserve the remembered role and accounts across logout
    final remembered = prefs.getString(_keyRememberedRole);
    final accounts = prefs.getStringList(_keyRememberedAccounts);
    await prefs.clear();
    if (remembered != null) {
      await prefs.setString(_keyRememberedRole, remembered);
    }
    if (accounts != null) {
      await prefs.setStringList(_keyRememberedAccounts, accounts);
    }
  }

  // --- Multi-Account Management ---

  Future<void> rememberAccount({
    required String id,
    required String name,
    required String role,
    String? phone,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> accounts = prefs.getStringList(_keyRememberedAccounts) ?? [];
    
    // Format: id|name|role|phone|email
    final String entry = '$id|$name|$role|${phone ?? ''}|${email ?? ''}';
    
    // Remove if already exists with same id
    accounts.removeWhere((a) => a.startsWith('$id|'));
    accounts.insert(0, entry); // Most recent first
    
    // Keep last 5 accounts
    if (accounts.length > 5) accounts.removeLast();
    
    await prefs.setStringList(_keyRememberedAccounts, accounts);
  }

  Future<List<Map<String, String>>> getRememberedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> list = prefs.getStringList(_keyRememberedAccounts) ?? [];
    
    return list.map((s) {
      final parts = s.split('|');
      return {
        'id': parts.length > 0 ? parts[0] : '',
        'name': parts.length > 1 ? parts[1] : '',
        'role': parts.length > 2 ? parts[2] : '',
        'phone': parts.length > 3 ? parts[3] : '',
        'email': parts.length > 4 ? parts[4] : '',
      };
    }).toList();
  }

  Future<void> removeAccount(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> accounts = prefs.getStringList(_keyRememberedAccounts) ?? [];
    accounts.removeWhere((a) => a.startsWith('$id|'));
    await prefs.setStringList(_keyRememberedAccounts, accounts);
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

  Future<void> refugeeLogout() async {
    await logout();
  }

  // Set Profile Picture
  Future<void> setProfilePicture(String userId, String imageUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save locally
      await prefs.setString('profile_picture_$userId', imageUrl);
      
      // Save to Firestore
      await DatabaseService.instance.createUserProfile({
        'uid': userId,
        'profilePicture': imageUrl,
      });
    } catch (e) {
      print('DEBUG: setProfilePicture error: $e');
    }
  }

  // Get Profile Picture
  Future<String?> getProfilePicture(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_picture_$userId');
  }
}
