import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:adaptifit/src/constants/app_strings.dart';
import 'package:adaptifit/src/screens/auth/auth_gate.dart';
import 'package:adaptifit/src/context/onboarding_provider.dart';
import 'package:adaptifit/src/core/config/firebase_options.dart';
import 'package:adaptifit/src/theme/app_theme.dart';

// Screens
import 'package:adaptifit/src/screens/auth/welcome_screen.dart';
import 'package:adaptifit/src/screens/auth/create_account_screen.dart';
import 'package:adaptifit/src/screens/auth/sign_in_screen.dart';
import 'package:adaptifit/src/screens/core_app/main_scaffold.dart';
import 'package:adaptifit/src/screens/core_app/settings_screen.dart';
import 'package:adaptifit/src/screens/core_app/chat_screen.dart';
import 'package:adaptifit/src/screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => OnboardingProvider(),
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
        '/chat': (context) => const ChatScreen(),
        '/authgate': (context) => const AuthGate(),
      },
    );
  }
}
