import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mediconnectcode/ViewModels/signup_viewmodel.dart';
import 'package:mediconnectcode/ViewModels/otp_viewmodel.dart';
import 'package:mediconnectcode/ViewModels/login_viewmodel.dart';
import 'package:mediconnectcode/ViewModels/doctor_details_viewmodel.dart';
import 'package:mediconnectcode/ViewModels/patient_home_viewmodel.dart';
import 'package:mediconnectcode/Views/Screens/welcome_screen.dart';
import 'package:mediconnectcode/Views/Screens/role_selection_screen.dart';
import 'package:mediconnectcode/Views/Screens/otp_verification_screen.dart';
import 'package:mediconnectcode/Views/Screens/login_screen.dart';
import 'package:mediconnectcode/Views/Screens/forgot_password_screen.dart';
import 'package:mediconnectcode/Views/Screens/symptom_checker_screen.dart';
import 'package:mediconnectcode/Views/Screens/patient_home_screen.dart';
import 'package:mediconnectcode/Views/Screens/doctor_details_screen.dart';
import 'package:mediconnectcode/Views/Screens/doctor_home_screen.dart';
import 'package:mediconnectcode/Views/Screens/settings_screen.dart';
import 'package:mediconnectcode/Views/Screens/all_pending_requests_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // App Check — debug mode pe debug provider, release pe Play Integrity
  await FirebaseAppCheck.instance.activate(
    androidProvider: const bool.fromEnvironment('dart.vm.product')
        ? AndroidProvider.playIntegrity
        : AndroidProvider.debug,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupViewModel()),
        ChangeNotifierProvider(create: (_) => OTPViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => DoctorDetailsViewModel()),
        ChangeNotifierProvider(create: (_) => PatientHomeViewModel()),
      ],
      child: MaterialApp(
        title: 'MediConnect',
        theme: AppTheme.lightTheme,
        initialRoute: '/welcome',
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/role-selection': (context) => const RoleSelectionScreen(),
          '/otp-verification': (context) =>
              const OTPVerificationScreen(phoneNumber: ''),
          '/login': (context) => const LoginScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/patient-home': (context) => const PatientHomeScreen(),
          '/symptom-checker': (context) => const SymptomCheckerScreen(),
          '/doctor-details': (context) => const DoctorDetailsScreen(),
          '/doctor-home': (context) => const DoctorHomeScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/pending-requests': (context) => const AllPendingRequestsScreen(),
        },
      ),
    );
  }
}

class AppTheme {
  // ── Colors ────────────────────────────────────────────────────────────────────
  static const Color primaryTeal = Color(0xFF1D9E75);
  static const Color primaryTealDark = Color(0xFF0F6E56);
  static const Color primaryTealLight = Color(0xFFE1F5EE);
  static const Color primaryTealMedium = Color(0xFF5DCAA5);
  static const Color primaryBlue = Color(0xFF378ADD);
  static const Color primaryBlueDark = Color(0xFF185FA5);
  static const Color primaryBlueLight = Color(0xFFE6F1FB);

  static const Color textPrimary = Color(0xFF1a1a2e);
  static const Color textSecondary = Color(0xFF6b7280);
  static const Color textTertiary = Color(0xFF9ca3af);

  static const Color bgColor = Color(0xFFf0f4f8);
  static const Color cardColor = Color(0xFFffffff);
  static const Color borderColor = Color(0xFFe5e7eb);

  static const Color accentRed = Color(0xFFE24B4A);
  static const Color accentAmber = Color(0xFFBA7517);
  static const Color accentAmberLight = Color(0xFFFAEEDA);

  static TextStyle heading([Color? color, double size = 22]) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: FontWeight.bold,
      color: color ?? textPrimary,
    );
  }

  static TextStyle body([Color? color, double size = 14]) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: FontWeight.normal,
      color: color ?? textSecondary,
    );
  }

  static TextStyle label([Color? color, double size = 12]) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color ?? textPrimary,
    );
  }

  static TextStyle small([Color? color, double size = 10]) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: FontWeight.normal,
      color: color ?? textTertiary,
    );
  }

  // ── Light Theme ───────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: const ColorScheme.light(
        primary: primaryTeal,
        secondary: primaryBlue,
        surface: cardColor,
        error: accentRed,
      ),
      scaffoldBackgroundColor: bgColor,
      appBarTheme: AppBarTheme(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryTeal,
          side: const BorderSide(color: borderColor, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryTeal, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentRed, width: 2),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 16,
      ),
      useMaterial3: true,
    );
  }
}
