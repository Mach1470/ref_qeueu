// Auth Service with login persistence
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyUserRole = 'user_role';
  static const String _keyUserId = 'user_id';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserEmail = 'user_email';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyPharmacyId = 'pharmacy_id';

  // Simulate sending OTP. Return a fake verificationId on success.
  Future<String?> sendOtp({required String phone}) async {
    await Future.delayed(const Duration(seconds: 1));
    // In production use FirebaseAuth.instance.verifyPhoneNumber(...)
    // For demo return a fake id
    return 'demo-verification-id';
  }

  // Simulate verifying OTP. Return null on success, or error string.
  Future<String?> verifyOtp({required String verificationId, required String otp}) async {
    await Future.delayed(const Duration(seconds: 1));
    if (otp == '123456') {
      // success
      return null;
    } else {
      return 'Invalid code. Use 123456 for demo.';
    }
  }

  // Simulate email/id+password sign in
  Future<String?> signInWithEmailOrId({required String idOrEmail, required String password, String? role}) async {
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
      return null;
    }
    return 'Invalid credentials (demo). Use password = "password".';
  }

  // Simulate sign up
  Future<String?> signUpBasic({required String individualNumber, required String phone, String? password, String? email}) async {
    await Future.delayed(const Duration(seconds: 1));
    // Save sign up state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, individualNumber);
    await prefs.setString(_keyUserPhone, phone);
    if (email != null && email.isNotEmpty) {
      await prefs.setString(_keyUserEmail, email);
    }
    // return null on success
    return null;
  }

  // Save login state for refugee (phone login)
  Future<void> saveRefugeeLogin(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserRole, 'refugee');
    await prefs.setString(_keyUserPhone, phone);
  }

  // Save login state for doctor
  Future<void> saveDoctorLogin(String doctorId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserRole, 'doctor');
    await prefs.setString(_keyUserId, doctorId);
  }

  // Save login state for pharmacy
  Future<void> savePharmacyLogin(String pharmacyId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserRole, 'pharmacy');
    await prefs.setString(_keyPharmacyId, pharmacyId);
  }

  // Save login state for lab
  Future<void> saveLabLogin(String labId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserRole, 'lab');
    await prefs.setString(_keyUserId, labId);
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
    await prefs.clear();
  }

  // Get route based on saved role
  Future<String?> getSavedRoute() async {
    try {
      final role = await getUserRole();
      switch (role) {
        case 'refugee':
          return '/refugee_home';
        case 'doctor':
          return '/doctor';
        case 'pharmacy':
          return '/pharmacy_dashboard';
        case 'lab':
          return '/lab';
        default:
          return null;
      }
    } catch (e) {
      // If there's an error, return null to default to onboarding
      return null;
    }
  }
}
