import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:adaptifit/src/constants/app_strings.dart';
import 'package:adaptifit/src/constants/app_colors.dart';
import 'package:adaptifit/src/screens/auth/auth_gate.dart';
import 'package:adaptifit/src/context/onboarding_provider.dart';
import 'firebase_options.dart';

// Screens
import 'src/screens/auth/welcome_screen.dart';
import 'src/screens/auth/create_account_screen.dart';
import 'src/screens/auth/sign_in_screen.dart';
import 'src/screens/core_app/main_scaffold.dart';
import 'src/screens/core_app/settings_screen.dart';
import 'src/screens/core_app/chat_screen.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
        scaffoldBackgroundColor: AppColors.lightMintBackground,
        fontFamily: 'Poppins',
        useMaterial3: true,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          headlineMedium: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: AppColors.grey),
        ),
      ),
      home: const AuthGate(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/create-account': (context) => const CreateAccountScreen(),
        '/signin': (context) => const SignInScreen(),
        '/main': (context) => const MainScaffold(),
        '/settings': (context) => const SettingsScreen(),
        '/chat': (context) => const ChatScreen(),
      },
    );
  }
}
