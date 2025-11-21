import 'package:flutter/material.dart';
// Firebase imports (Added since firebase_options.dart exists in your tree)
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'services/auth_service.dart';

// --- SCREEN IMPORTS (Based on your tree) ---

// Core
import 'screens/onboarding_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/welccome_screen.dart'; // Note: typo in your file name 'welccome'
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';

// Auth
import 'screens/auth/refugee_login_screen.dart';
import 'screens/auth/refugee_signup_screen.dart';
import 'screens/auth/otp_verification_screen.dart';

// Role Homes
import 'screens/refugee_home_screen.dart';
import 'screens/doctor_home_screen.dart';
import 'screens/lab_home_screen.dart';
import 'screens/ambulance_request_screen.dart';

// Pharmacy
import 'screens/pharmacy/pharmacy_login_screen.dart';
import 'screens/pharmacy/pharmacy_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase since you have firebase_options.dart
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed (ignore if not using Firebase yet): $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();
  
  // This variable holds the ACTUAL widget to start with, preventing routing crashes
  Widget? _startScreen; 
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _decideStartScreen();
  }

  Future<void> _decideStartScreen() async {
    try {
      // 1. Check if user is logged in
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // 2. If logged in, check which role/screen they were on
        final savedRoute = await _authService.getSavedRoute();
        
        if (savedRoute != null && savedRoute.isNotEmpty) {
          // Map the saved string to a real Widget
          if (mounted) {
            setState(() {
              _startScreen = _getScreenForRoute(savedRoute);
              _isLoading = false;
            });
          }
        } else {
          // Logged in but no saved route? Default to Role Selection
          if (mounted) {
            setState(() {
              _startScreen = const RoleSelectionScreen();
              _isLoading = false;
            });
          }
        }
      } else {
        // 3. Not logged in -> Onboarding
        if (mounted) {
          setState(() {
            _startScreen = const OnboardingScreen();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error in startup logic: $e");
      // Fallback to Onboarding on error
      if (mounted) {
        setState(() {
          _startScreen = const OnboardingScreen();
          _isLoading = false;
        });
      }
    }
  }

  // --- CENTRAL ROUTE MAPPING ---
  // This maps your String paths to your Widgets. 
  // Used for both startup logic and navigation.
  Widget _getScreenForRoute(String routeName, {Object? args}) {
    switch (routeName) {
      // Core Flow
      case '/onboarding':
        return const OnboardingScreen();
      case '/welcome':
        return const WelcomeScreen(); // Fixed typo in class usage, keeping file name logic
      case '/role_selection':
        return const RoleSelectionScreen();
      
      // Auth - Refugee
      case '/auth/refugee_login':
        return const RefugeeLoginScreen();
      case '/auth/refugee_signup':
        return const RefugeeSignupScreen();
      
      // Auth - Pharmacy
      case '/pharmacy/login':
        return const PharmacyLoginScreen();

      // Dashboards / Homes
      case '/refugee_home':
        return const RefugeeHomeScreen();
      case '/doctor_home':
        return const DoctorHomeScreen();
      case '/lab_home':
        return const LabHomeScreen();
      case '/pharmacy_dashboard':
        return const PharmacyDashboardScreen();
      case '/ambulance_request':
        return const AmbulanceRequestScreen();
      case '/map':
        return const MapScreen();

      // Fallback
      default:
        return const RoleSelectionScreen();
    }
  }

  // --- ROUTE GENERATOR ---
  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    // Logic for screens that might need arguments (like OTP or Patient Details)
    /* if (settings.name == '/otp_verification') {
      final args = settings.arguments;
      return MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(verificationId: args as String),
      );
    } 
    */

    // Standard navigation
    final Widget screen = _getScreenForRoute(settings.name ?? '', args: settings.arguments);

    return MaterialPageRoute(
      builder: (context) => screen,
      settings: settings,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Refugee Queue System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      
      // *** THE FIX IS HERE ***
      // We do NOT use 'initialRoute'. We use 'home' with the calculated widget.
      home: _startScreen ?? const OnboardingScreen(),
      
      // We use onGenerateRoute for subsequent navigation (Navigator.pushNamed)
      onGenerateRoute: _onGenerateRoute,
    );
  }
}