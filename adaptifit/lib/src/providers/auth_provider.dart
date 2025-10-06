import 'package:adaptifit/src/context/onboarding_provider.dart';
import 'package:adaptifit/src/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingProvider = ChangeNotifierProvider<OnboardingProvider>((ref) {
  return OnboardingProvider();
});

final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) {
  return AuthService(ref);
});