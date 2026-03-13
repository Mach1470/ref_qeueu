import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class SecurityService {
  static final SecurityService instance = SecurityService._();
  SecurityService._();

  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _keyPin = 'security_pin';
  static const String _keyBiometricsEnabled = 'biometrics_enabled';
  static const String _keyPinEnabled = 'pin_enabled';

  // --- Biometric Logic ---

  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } on PlatformException catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return <BiometricType>[];
    }
  }

  Future<bool> authenticate() async {
    try {
      final bool authenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate to access MyQueue',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Biometric login',
            cancelButton: 'Use PIN',
          ),
          IOSAuthMessages(
            cancelButton: 'Use PIN',
          ),
        ],
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return authenticated;
    } on PlatformException catch (e) {
      print('DEBUG: Biometric alignment error: $e');
      return false;
    }
  }

  // --- PIN Logic ---

  Future<void> savePin(String pin) async {
    await _storage.write(key: _keyPin, value: pin);
    await setPinEnabled(true);
  }

  Future<bool> verifyPin(String pin) async {
    final savedPin = await _storage.read(key: _keyPin);
    return savedPin == pin;
  }

  Future<bool> hasPin() async {
    final pin = await _storage.read(key: _keyPin);
    return pin != null && pin.isNotEmpty;
  }

  // --- Settings Logic ---

  Future<bool> isBiometricsEnabled() async {
    final val = await _storage.read(key: _keyBiometricsEnabled);
    return val == 'true';
  }

  Future<void> setBiometricsEnabled(bool enabled) async {
    await _storage.write(key: _keyBiometricsEnabled, value: enabled.toString());
  }

  Future<bool> isPinEnabled() async {
    final val = await _storage.read(key: _keyPinEnabled);
    return val == 'true';
  }

  Future<void> setPinEnabled(bool enabled) async {
    await _storage.write(key: _keyPinEnabled, value: enabled.toString());
  }

  Future<bool> isSecurityActive() async {
    return await isPinEnabled() || await isBiometricsEnabled();
  }
}
