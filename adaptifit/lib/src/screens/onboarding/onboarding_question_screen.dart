import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:adaptifit/src/constants/app_colors.dart';
import 'package:adaptifit/src/context/onboarding_provider.dart';
import 'package:adaptifit/src/screens/core_app/main_scaffold.dart';
import 'package:adaptifit/src/services/auth_service.dart';
import 'package:adaptifit/src/services/firestore_service.dart';
import 'package:adaptifit/src/services/n8n_service.dart';

enum QuestionType {
  singleChoice,
  textInput,
  textArea,
  diet,
}

class OnboardingQuestion {
  final String title;
  final String subtitle;
  final QuestionType type;
  final String answerKey; // Unique key for storing the answer
  final List<String> options;
  final List<String> placeholders;

  OnboardingQuestion({
    required this.title,
    required this.subtitle,
    required this.type,
    required this.answerKey,
    this.options = const [],
    this.placeholders = const [],
  });
}

class OnboardingQuestionScreen extends StatefulWidget {
  const OnboardingQuestionScreen({super.key});

  @override
  State<OnboardingQuestionScreen> createState() =>
      _OnboardingQuestionScreenState();
}

class _OnboardingQuestionScreenState extends State<OnboardingQuestionScreen> {
  // Services
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final N8nService _n8nService = N8nService();

  // State
  int _currentQuestionIndex = 0;
  bool _isLoading = false;

  final List<OnboardingQuestion> _questions = [
    OnboardingQuestion(
      title: 'How many days per week can you realistically work out?',
      subtitle:
          'Be honest with yourself—consistency matters more than perfection. We’ll design your plan around your schedule.',
      type: QuestionType.singleChoice,
      answerKey: 'workoutFrequency',
      options: ['1', '2', '3', '4', '5', '6', '7'],
    ),
    OnboardingQuestion(
      title: 'How long would you like your personalized plan to last?',
      subtitle:
          'Most people choose 30, 60, or 90 days — but you can set any timeline that fits your goals.',
      type: QuestionType.textInput,
      answerKey: 'planDuration',
      placeholders: ['Enter number of days'],
    ),
    OnboardingQuestion(
      title: 'Do you have any injuries or physical limitations?',
      subtitle:
          'This helps us adapt your plan so you can train safely and effectively.',
      type: QuestionType.textArea,
      answerKey: 'injuries',
      placeholders: [
        'e.g., shoulder impingement, knee pain, lower back issues',
      ],
    ),
    OnboardingQuestion(
      title: 'Do you follow a specific diet or have nutrition preferences?',
      subtitle:
          'This helps us personalize your plan around your lifestyle. Add your diet style, macros, or calories if you’d like. If you skip, we’ll create only your workout plan and hide nutrition sections in the app.',
      type: QuestionType.diet,
      answerKey: 'diet',
      placeholders: [
        'e.g., high protein, vegetarian, keto, plant-based',
        '2000 kcal or macros in grams',
        'Enter custom dietary preferences',
      ],
    ),
    OnboardingQuestion(
      title: 'What is your current activity level?',
      subtitle: 'This helps us gauge your starting point.',
      type: QuestionType.singleChoice,
      answerKey: 'activityLevel',
      options: ['Sedentary', 'Lightly Active', 'Moderately Active', 'Very Active'],
    ),
    OnboardingQuestion(
      title: 'How much time can you dedicate to each workout session?',
      subtitle: 'This will help us tailor the length of your workouts.',
      type: QuestionType.singleChoice,
      answerKey: 'timePerSession',
      options: ['15-30 minutes', '30-45 minutes', '45-60 minutes', '60+ minutes'],
    ),
    OnboardingQuestion(
      title: 'Do you have access to a gym or will you be working out at home?',
      subtitle: 'This determines the type of exercises in your plan.',
      type: QuestionType.singleChoice,
      answerKey: 'gymAccess',
      options: ['Gym', 'Home', 'Both'],
    ),
    OnboardingQuestion(
      title: 'What is your preferred workout split?',
      subtitle: 'A workout split is how you organize your workouts throughout the week.',
      type: QuestionType.singleChoice,
      answerKey: 'workoutSplit',
      options: ['Full Body', 'Upper/Lower', 'Push/Pull/Legs', 'Body Part Split'],
    ),
    OnboardingQuestion(
      title: 'What equipment do you have access to?',
      subtitle: 'List all the equipment you have available for your workouts.',
      type: QuestionType.textArea,
      answerKey: 'equipmentList',
      placeholders: ['e.g., dumbbells, resistance bands, treadmill, etc.'],
    ),
  ];

  late TextEditingController _textController;
  late TextEditingController _dietStyleController;
  late TextEditingController _dietMacrosController;
  late TextEditingController _dietCustomController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _dietStyleController = TextEditingController();
    _dietMacrosController = TextEditingController();
    _dietCustomController = TextEditingController();

    // Load initial answer for the first question
    _loadAnswerForCurrentQuestion();
  }

  @override
  void dispose() {
    _textController.dispose();
    _dietStyleController.dispose();
    _dietMacrosController.dispose();
    _dietCustomController.dispose();
    super.dispose();
  }

  void _finishOnboarding() async {
    setState(() => _isLoading = true);

    final onboardingProvider =
        Provider.of<OnboardingProvider>(context, listen: false);
    final User? user = _authService.getCurrentUser();

    if (user != null) {
      final answers = onboardingProvider.answers;
      await _firestoreService.updateOnboardingAnswers(answers);
      await _n8nService.triggerPlanGeneration(
          userId: user.uid, onboardingAnswers: answers);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScaffold()),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      // Handle error: user somehow not logged in
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Could not find logged in user.')),
      );
    }
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _loadAnswerForCurrentQuestion();
      } else {
        _finishOnboarding();
      }
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _loadAnswerForCurrentQuestion();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _updateProviderAnswer(String key, dynamic value) {
    Provider.of<OnboardingProvider>(context, listen: false)
        .updateAnswer(key, value);
    // Trigger a rebuild to update button state
    setState(() {});
  }

  void _loadAnswerForCurrentQuestion() {
    final provider = Provider.of<OnboardingProvider>(context, listen: false);
    final question = _questions[_currentQuestionIndex];
    final answer = provider.answers[question.answerKey];

    // Clear all controllers first
    _textController.clear();
    _dietStyleController.clear();
    _dietMacrosController.clear();
    _dietCustomController.clear();

    if (answer == null) return;

    switch (question.type) {
      case QuestionType.singleChoice:
        // The UI state is handled directly by reading from the provider
        break;
      case QuestionType.textInput:
      case QuestionType.textArea:
        if (answer is String) _textController.text = answer;
        break;
      case QuestionType.diet:
        if (answer is Map) {
          _dietStyleController.text = answer['style'] ?? '';
          _dietMacrosController.text = answer['macros'] ?? '';
          _dietCustomController.text = answer['custom'] ?? '';
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final provider = Provider.of<OnboardingProvider>(context);

    bool isNextEnabled() {
      final answer = provider.answers[currentQuestion.answerKey];
      if (answer == null) return false;

      switch (currentQuestion.type) {
        case QuestionType.singleChoice:
          return answer.toString().isNotEmpty;
        case QuestionType.textInput:
        case QuestionType.textArea:
          return answer.toString().isNotEmpty;
        case QuestionType.diet:
          return (answer['style']?.isNotEmpty ?? false) ||
              (answer['macros']?.isNotEmpty ?? false) ||
              (answer['custom']?.isNotEmpty ?? false);
        
      }
    }

    return Scaffold(
      backgroundColor: AppColors.neutralGray,
      appBar: AppBar(
        backgroundColor: AppColors.neutralGray,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: _previousQuestion,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      currentQuestion.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentQuestion.subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildInputArea(currentQuestion),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed:
                    isNextEnabled() && !_isLoading ? _nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  disabledBackgroundColor: AppColors.timestampGray,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _currentQuestionIndex == _questions.length - 1
                            ? 'Generate My Plan'
                            : 'Next',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(OnboardingQuestion question) {
    switch (question.type) {
      case QuestionType.singleChoice:
        return _buildSingleChoiceList(question);
      case QuestionType.textInput:
        return _buildTextInput(question, _textController);
      case QuestionType.textArea:
        return _buildTextArea(question, _textController);
      case QuestionType.diet:
        return _buildDietForm(question);
    }
  }

  Widget _buildSingleChoiceList(OnboardingQuestion question) {
    final provider = Provider.of<OnboardingProvider>(context);
    final selectedOption = provider.answers[question.answerKey];

    return Column(
      children: question.options.map((option) {
        final isSelected = selectedOption == option;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GestureDetector(
            onTap: () => _updateProviderAnswer(question.answerKey, option),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen.withOpacity(0.2)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.timestampGray,
                  width: 1.5,
                ),
              ),
              child: Text(
                option,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.darkText,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextInput(
      OnboardingQuestion question, TextEditingController controller) {
    return TextField(
      controller: controller,
      onChanged: (text) => _updateProviderAnswer(question.answerKey, text),
      decoration: InputDecoration(
        hintText: question.placeholders.first,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.timestampGray, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildTextArea(
      OnboardingQuestion question, TextEditingController controller) {
    return TextField(
      controller: controller,
      onChanged: (text) => _updateProviderAnswer(question.answerKey, text),
      maxLines: 4,
      decoration: InputDecoration(
        hintText: question.placeholders.first,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.timestampGray, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildDietForm(OnboardingQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _dietStyleController,
          onChanged: (text) => _updateProviderAnswer(question.answerKey, {
            'style': text,
            'macros': _dietMacrosController.text,
            'custom': _dietCustomController.text,
          }),
          decoration: InputDecoration(
            hintText: question.placeholders[0],
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _dietMacrosController,
          onChanged: (text) => _updateProviderAnswer(question.answerKey, {
            'style': _dietStyleController.text,
            'macros': text,
            'custom': _dietCustomController.text,
          }),
          decoration: InputDecoration(
            hintText: question.placeholders[1],
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _dietCustomController,
          onChanged: (text) => _updateProviderAnswer(question.answerKey, {
            'style': _dietStyleController.text,
            'macros': _dietMacrosController.text,
            'custom': text,
          }),
          decoration: InputDecoration(
            hintText: question.placeholders[2],
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () {
              _updateProviderAnswer(question.answerKey, {'skipped': true});
              _finishOnboarding();
            },
            child: const Text(
              'Skip Nutrition',
              style: TextStyle(
                color: Colors.black54,
                decoration: TextDecoration.underline,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
