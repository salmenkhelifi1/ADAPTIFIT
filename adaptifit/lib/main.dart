import 'package:adaptifit/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'package:adaptifit/src/constants/app_strings.dart';
import 'package:adaptifit/src/screens/auth/auth_gate.dart';
import 'package:adaptifit/src/context/onboarding_provider.dart';
import 'package:adaptifit/src/theme/app_theme.dart';

// Screens
import 'package:adaptifit/src/screens/auth/welcome_screen.dart';
import 'package:adaptifit/src/screens/auth/create_account_screen.dart';
import 'package:adaptifit/src/screens/auth/sign_in_screen.dart';
import 'package:adaptifit/src/screens/core_app/main_scaffold.dart';
import 'package:adaptifit/src/screens/core_app/settings_screen.dart';
import 'package:adaptifit/src/screens/core_app/coach_screen.dart';
import 'package:adaptifit/src/screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OnboardingProvider()),
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/create-account': (context) => const CreateAccountScreen(),
        '/signin': (context) => const SignInScreen(),
        '/main': (context) => const MainScaffold(),
        '/settings': (context) => const SettingsScreen(),
        '/chat': (context) => const CoachScreen(),
        '/authgate': (context) => const AuthGate(),
      },
    );
  }
}
