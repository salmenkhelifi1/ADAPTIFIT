import 'package:adaptifit/src/screens/auth/welcome_screen.dart';
import 'package:adaptifit/src/screens/core_app/main_scaffold.dart';
import 'package:adaptifit/src/screens/onboarding/onboarding_question_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:adaptifit/src/providers/auth_provider.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  Future<void>? _authFuture;

  @override
  void initState() {
    super.initState();
    _authFuture = ref.read(authServiceProvider).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authServiceProvider);
    return FutureBuilder<void>(
      future: _authFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

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
  }
}
