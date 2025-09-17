// lib/src/context/onboarding_provider.dart

import 'package:flutter/material.dart';

class OnboardingProvider with ChangeNotifier {
  // A map to hold all the answers from the onboarding process
  final Map<String, dynamic> _answers = {};

  // A getter to safely access the answers
  Map<String, dynamic> get answers => _answers;

  // Method to add or update an answer
  void updateAnswer(String key, dynamic value) {
    _answers[key] = value;
    // This tells any listening widgets to rebuild
    notifyListeners();
  }
}
