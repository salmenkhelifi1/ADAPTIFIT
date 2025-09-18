import 'package:flutter/material.dart';

class OnboardingProvider with ChangeNotifier {
  final Map<String, dynamic> _answers = {};

  Map<String, dynamic> get answers => _answers;

  void updateAnswer(String key, dynamic value) {
    _answers[key] = value;
    notifyListeners();
  }

  void clearAnswers() {
    _answers.clear();
    notifyListeners();
  }
}
