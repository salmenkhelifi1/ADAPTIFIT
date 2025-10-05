import 'package:adaptifit/src/screens/auth/welcome_screen.dart';
import 'package:adaptifit/src/screens/core_app/main_scaffold.dart';
import 'package:adaptifit/src/screens/onboarding/onboarding_question_screen.dart';
import 'package:adaptifit/src/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<void>? _authFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_authFuture == null) {
      _authFuture = Provider.of<AuthService>(context, listen: false).tryAutoLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _authFuture,
      builder: (context, snapshot) {
        // Use Consumer to react to auth changes
        return Consumer<AuthService>(
          builder: (context, auth, child) {
            // While waiting for the future to complete, show a loading indicator
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // After future completes, decide which screen to show
            if (auth.user != null) {
              if (auth.user!.onboardingCompleted) {
                return const MainScaffold();
              } else {
                return const OnboardingQuestionScreen();
              }
            } else {
              return const WelcomeScreen();
            }
          },
        );
      },
    );
  }
}