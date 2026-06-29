import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/theme_service.dart';
import 'services/offline_sync_service.dart';
import 'models/sync_queue_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Core Screens
import 'screens/onboarding_screen.dart';
import 'screens/role_selection_screen.dart';
import 'screens/splash_screen.dart';

// Auth Screens
import 'screens/auth/refugee_login_screen_new.dart';
import 'screens/auth/refugee_signup_screen.dart';
import 'screens/auth/production_phone_login_screen.dart';
import 'screens/auth/production_otp_verification_screen.dart';

// Dashboard Screens
import 'screens/refugee_home_screen_new.dart';
import 'screens/join_queue_selection_screen.dart';
import 'screens/add_family_member_screen.dart';
import 'screens/refugee/family_registration_screen.dart';
import 'screens/refugee/join_queue_dashboard.dart';
import 'screens/refugee/auth_lock_screen.dart';
import 'screens/refugee/account_selector_screen.dart';

// Ambulance Screens
import 'screens/ambulance/ambulance_driver_login_screen.dart';
import 'screens/ambulance/refugee_ambulance_request_screen.dart';
import 'screens/refugee/symptom_input_screen.dart';
import 'screens/refugee/hospital_selection_screen.dart';
import 'screens/ambulance/ambulance_driver_dashboard.dart';
import 'screens/ambulance/ambulance_navigation_screen.dart';

// CHW Screens
import 'screens/chw/chw_login_screen.dart';
import 'screens/chw/chw_dashboard.dart';
import 'screens/chw/chw_triage_screen.dart';

import 'screens/map_screen.dart';
import 'screens/refugee/profile_screen.dart';
import 'screens/location_based_facility_selection_screen.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final themeService = ThemeService();
  await themeService.load();

  final offlineSyncService = OfflineSyncService(
    syncHandler: (entry) async {
      try {
        final docRef = FirebaseFirestore.instance.collection(entry.collection).doc(entry.documentId);
        if (entry.operation == SyncOperation.create || entry.operation == SyncOperation.update) {
          await docRef.set(entry.payload, SetOptions(merge: true));
        } else if (entry.operation == SyncOperation.delete) {
          await docRef.delete();
        }
        return true;
      } catch (e) {
        debugPrint('Sync failed for entry ${entry.id}: $e');
        return false;
      }
    },
  );
  await offlineSyncService.initialize();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: themeService),
      ChangeNotifierProvider.value(value: offlineSyncService),
    ],
    child: const MyQueueApp(),
  ));
}

class MyQueueApp extends StatelessWidget {
  const MyQueueApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeSvc = Provider.of<ThemeService>(context);

    const Color primaryBlue = Color(0xFF386BB8);
    const Color surfaceBlue = Color(0xFFF8FAFC);

    // When the high-contrast theme is enabled, use it for both light and dark
    // — the user's brightness preference is still honored via [themeMode].
    final lightTheme = themeSvc.highContrast
        ? themeSvc.buildHighContrastTheme(Brightness.light)
        : ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryBlue,
              primary: primaryBlue,
              surface: Colors.white,
            ),
            scaffoldBackgroundColor: surfaceBlue,
            textTheme: GoogleFonts.merriweatherTextTheme(
              Theme.of(context).textTheme,
            ).copyWith(
              displayLarge: GoogleFonts.merriweather(fontWeight: FontWeight.w900),
              displayMedium: GoogleFonts.merriweather(fontWeight: FontWeight.w900),
              displaySmall: GoogleFonts.merriweather(fontWeight: FontWeight.w700),
              headlineMedium: GoogleFonts.merriweather(fontWeight: FontWeight.w700),
            ),
          );

    final darkTheme = themeSvc.highContrast
        ? themeSvc.buildHighContrastTheme(Brightness.dark)
        : ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryBlue,
              brightness: Brightness.dark,
              primary: primaryBlue,
            ),
            textTheme: GoogleFonts.merriweatherTextTheme(
              ThemeData.dark().textTheme,
            ).copyWith(
              displayLarge: GoogleFonts.merriweather(fontWeight: FontWeight.w900),
              displayMedium: GoogleFonts.merriweather(fontWeight: FontWeight.w900),
              displaySmall: GoogleFonts.merriweather(fontWeight: FontWeight.w700),
              headlineMedium: GoogleFonts.merriweather(fontWeight: FontWeight.w700),
            ),
          );

    return MaterialApp(
      title: 'MyQueue Mobile',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeSvc.mode,
      home: const SplashScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/role_selection': (context) => const RoleSelectionScreen(),
        '/auth/refugee_login': (context) => const RefugeeLoginScreenNew(),
        '/auth/refugee_signup': (context) => const RefugeeSignupScreen(),
        '/refugee_home': (context) => const RefugeeHomeScreenNew(),
        '/auth/otp_verification': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final String verificationId = args?['verificationId'] ?? 'unknown_id';
          final String phoneNumber = args?['phoneNumber'] ?? '';
          final String role = args?['role'] ?? 'refugee';

          return ProductionOtpVerificationScreen(
            verificationId: verificationId,
            phoneNumber: phoneNumber,
            role: role,
          );
        },
        '/join_queue_selection': (context) => const JoinQueueSelectionScreen(),
        '/add_family_member': (context) => const AddFamilyMemberScreen(),
        '/refugee_ambulance_request': (context) =>
            const RefugeeAmbulanceRequestScreen(),
        '/symptom_input': (context) => const SymptomInputScreen(),
        '/hospital_selection': (context) => const HospitalSelectionScreen(),
        '/ambulance_request': (context) => const AmbulanceDriverLoginScreen(),
        '/ambulance_driver_dashboard': (context) =>
            const AmbulanceDriverDashboard(),
        '/ambulance_navigation': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          if (args == null) {
            return const Scaffold(
                body: Center(child: Text('No request data found')));
          }
          return AmbulanceNavigationScreen(request: args);
        },
        '/map_screen': (context) => const MapScreen(),
        '/refugee/family_registration': (context) =>
            const FamilyRegistrationScreen(),
        '/refugee/join_queue': (context) => const JoinQueueDashboard(),
        '/profile': (context) => const ProfileScreen(),
        '/auth_lock': (context) => AuthLockScreen(
          onAuthenticated: () {
            Navigator.pushReplacementNamed(context, '/refugee_home');
          },
        ),
        '/account_selector': (context) => const AccountSelectorScreen(),
        '/chw_login': (context) => const CHWLoginScreen(),
        '/chw_dashboard': (context) => const CHWDashboard(),
        '/chw_triage': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          return CHWTriageScreen(
            patientName: args?['patientName'] as String?,
          );
        },
        // Production Authentication Routes
        '/production_phone_login_refugee': (context) =>
            const ProductionPhoneLoginScreen(role: 'refugee'),
        '/production_phone_login_ambulance': (context) =>
            const ProductionPhoneLoginScreen(role: 'ambulance_driver'),
        '/production_phone_login_chw': (context) =>
            const ProductionPhoneLoginScreen(role: 'chw'),
        
        // Location-Based Facility Assignment
        '/facility_selection': (context) =>
            const LocationBasedFacilitySelectionScreen(),
      },
    );
  }
}

// PharmacyDashboardScreen is provided in `lib/screens/pharmacy/pharmacy_dashboard_screen.dart`.
