import 'package:flutter/material.dart';
import 'package:adaptifit/src/constants/app_strings.dart';
import 'package:adaptifit/src/constants/app_colors.dart';

// Screens
import 'package:adaptifit/src/screens/auth/welcome_screen.dart';
import 'package:adaptifit/src/screens/auth/create_account_screen.dart';
import 'package:adaptifit/src/screens/auth/sign_in_screen.dart';
import 'package:adaptifit/src/screens/core_app/chat_screen.dart';
import 'package:adaptifit/src/screens/core_app/settings_screen.dart';

void main() {
  runApp(const MyApp());
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
              color: AppColors.black),
          headlineMedium: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.black),
          bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14, color: AppColors.grey),
        ),
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/create-account': (context) => const CreateAccountScreen(),
        '/signin': (context) => const SignInScreen(),
        '/chat': (context) => const ChatScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
