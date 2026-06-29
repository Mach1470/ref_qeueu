import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme service supporting three modes:
///  - system (follow device)
///  - light
///  - dark
///  - highContrast (for CHW outdoor use — bold colors, larger text)
class ThemeService extends ChangeNotifier {
  static const String _prefKey = 'theme_mode';
  static const String _prefHighContrastKey = 'high_contrast';

  ThemeMode _mode = ThemeMode.system;
  bool _highContrast = false;

  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  /// True when the user has opted into the high-contrast theme variant.
  /// Independent of [mode] — high-contrast can layer on top of light or dark.
  bool get highContrast => _highContrast;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_prefKey);
    if (v == 'dark') {
      _mode = ThemeMode.dark;
    } else if (v == 'light') {
      _mode = ThemeMode.light;
    } else {
      _mode = ThemeMode.system;
    }
    _highContrast = prefs.getBool(_prefHighContrastKey) ?? false;
    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    final string = mode == ThemeMode.dark
        ? 'dark'
        : (mode == ThemeMode.light ? 'light' : 'system');
    await prefs.setString(_prefKey, string);
    notifyListeners();
  }

  Future<void> toggleDark() async {
    final newMode =
        (_mode == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
    await setMode(newMode);
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefHighContrastKey, value);
    notifyListeners();
  }

  Future<void> toggleHighContrast() => setHighContrast(!_highContrast);

  // ── Color palette ────────────────────────────────────────────────────
  static const Color primaryBlue = Color(0xFF386BB8);
  static const Color surfaceBlue = Color(0xFFF8FAFC);

  // High-contrast palette (WCAG AAA on text where possible).
  static const Color hcPrimary = Color(0xFF000000);
  static const Color hcBackground = Color(0xFFFFFFFF);
  static const Color hcSurface = Color(0xFF000000);
  static const Color hcOnSurface = Color(0xFFFFFFFF);
  static const Color hcAccent = Color(0xFF0D47A1); // dark blue
  static const Color hcError = Color(0xFFB00020);

  /// Returns a [ThemeData] tuned for outdoor / low-bandwidth visibility.
  /// Bolder text, thicker borders, larger hit targets.
  ThemeData buildHighContrastTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final bg = isDark ? Colors.black : hcBackground;
    final fg = isDark ? Colors.white : hcPrimary;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: hcAccent,
        onPrimary: Colors.white,
        secondary: hcAccent,
        onSecondary: Colors.white,
        error: hcError,
        onError: Colors.white,
        surface: bg,
        onSurface: fg,
      ),
      scaffoldBackgroundColor: bg,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: hcAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          side: BorderSide(color: fg, width: 2),
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: bg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: fg, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      iconTheme: IconThemeData(color: fg, size: 28),
    );
  }
}
