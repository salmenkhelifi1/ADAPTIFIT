// lib/src/context/onboarding_provider.dart

import 'package:flutter/material.dart';

class OnboardingProvider with ChangeNotifier {
  final Map<String, dynamic> _answers = {};

  Map<String, dynamic> get answers => _answers;

  void updateAnswer(String key, dynamic value) {
    _answers[key] = value;
    notifyListeners();
  }

  void setAnswers(Map<String, dynamic> newAnswers) {
    _answers.clear();
    _answers.addAll(newAnswers);
    notifyListeners();
  }
}