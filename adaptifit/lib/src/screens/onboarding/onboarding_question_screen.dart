// lib/src/screens/onboarding/onboarding_question_screen.dart

import 'package:adaptifit/src/screens/onboarding/summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:adaptifit/src/constants/app_colors.dart';
import 'package:adaptifit/src/providers/auth_provider.dart';

// UPDATED: Added multiChoice type
enum QuestionType {
  singleChoice,
  multiChoice, // New
  textInput,
  textArea,
  diet,
  numberInput,
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

class OnboardingQuestionScreen extends ConsumerStatefulWidget {
  const OnboardingQuestionScreen({super.key});

  @override
  ConsumerState<OnboardingQuestionScreen> createState() =>
      _OnboardingQuestionScreenState();
}

class _OnboardingQuestionScreenState
    extends ConsumerState<OnboardingQuestionScreen> {
  int _currentQuestionIndex = 0;

  // UPDATED: First question changed to multiChoice to match screenshot
  final List<OnboardingQuestion> _questions = [
    // 1. Fitness goal
    OnboardingQuestion(
      title: 'What is your main fitness goal?',
      subtitle: 'You can choose more than one goal.',
      type: QuestionType.multiChoice, // Changed type
      answerKey: 'fitnessGoal',
      options: [
        'Build muscle',
        'Lose fat',
        'Improve endurance',
        'Improve mobility',
        'General wellness',
        'Other'
      ], // Changed options
    ),
    // 2. Experience level
    OnboardingQuestion(
      title: 'What is your fitness experience level?',
      subtitle:
          'This helps us set the right intensity and complexity for your workouts.',
      type: QuestionType.singleChoice,
      answerKey: 'experienceLevel',
      options: ['Beginner', 'Intermediate', 'Advanced'],
    ),
    // 3. Injuries/limitations
    OnboardingQuestion(
      title: 'Do you have any injuries or physical limitations?',
      subtitle:
          'This helps us adapt your plan so you can train safely and effectively.',
      type: QuestionType.textInput,
      answerKey: 'injuries',
      placeholders: ['e.g., shoulder impingement, knee pain, etc.'],
    ),
    // 4. Weekly workout frequency
    OnboardingQuestion(
      title: 'How many days per week can you realistically work out?',
      subtitle:
          'Be honest with yourself—consistency matters more than perfection.',
      type: QuestionType.singleChoice,
      answerKey: 'workoutFrequency',
      options: [
        '1 day',
        '2 days',
        '3 days',
        '4 days',
        '5 days',
        '6 days',
        '7 days'
      ],
    ),
    // 5. Plan duration
    OnboardingQuestion(
      title: 'How long would you like your personalized plan to last?',
      subtitle: 'Enter the duration in days.',
      type: QuestionType.numberInput,
      answerKey: 'planDuration',
      placeholders: ['e.g., 30'],
    ),
    // 6. Activity level
    OnboardingQuestion(
      title: 'What is your current activity level?',
      subtitle: 'This helps us gauge your starting point.',
      type: QuestionType.singleChoice,
      answerKey: 'activityLevel',
      options: [
        'Sedentary',
        'Lightly Active',
        'Moderately Active',
        'Very Active'
      ],
    ),
    // 7. Diet type/preferences
    OnboardingQuestion(
      title: 'Do you follow a specific diet or have nutrition preferences?',
      subtitle:
          'If you skip, we’ll create only your workout plan and hide nutrition sections in the app.',
      type: QuestionType.diet,
      answerKey: 'diet',
      placeholders: [
        'e.g., high protein, vegetarian, keto',
        '2000 kcal or macros in grams',
        'Enter custom dietary preferences'
      ],
    ),
    // 8. Time per session
    OnboardingQuestion(
      title: 'How much time can you dedicate to each workout session?',
      subtitle: 'Enter the time in minutes.',
      type: QuestionType.numberInput,
      answerKey: 'timePerSession',
      placeholders: ['e.g., 45'],
    ),
    // 9. Access to gym/home equipment
    OnboardingQuestion(
      title: 'Do you have access to a gym or will you be working out at home?',
      subtitle: 'This determines the type of exercises in your plan.',
      type: QuestionType.singleChoice,
      answerKey: 'gymAccess',
      options: ['Gym', 'Home'],
    ),
    // 10. What equipment do you have? (Conditional)
    OnboardingQuestion(
      title: 'What equipment do you have access to?',
      subtitle: 'List all the equipment you have available for your workouts.',
      type: QuestionType.textInput,
      answerKey: 'equipmentList',
      placeholders: ['e.g., dumbbells, resistance bands, treadmill, etc.'],
    ),
    // 11. Preferred workout split
    OnboardingQuestion(
      title: 'What is your preferred workout split?',
      subtitle:
          'A workout split is how you organize your workouts throughout the week.',
      type: QuestionType.singleChoice,
      answerKey: 'workoutSplit',
      options: [
        'Full Body',
        'Upper/Lower',
        'Push/Pull/Legs',
        'Body Part Split'
      ],
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

  void _nextQuestion() {
    final currentQuestion = _questions[_currentQuestionIndex];
    if (currentQuestion.answerKey == 'gymAccess') {
      final provider = ref.read(onboardingProvider);
      final answer = provider.answers['gymAccess'];
      if (answer == 'Gym') {
        final splitIndex =
            _questions.indexWhere((q) => q.answerKey == 'workoutSplit');
        setState(() {
          _currentQuestionIndex = splitIndex;
          _loadAnswerForCurrentQuestion();
        });
        return;
      }
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _loadAnswerForCurrentQuestion();
      });
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const SummaryScreen()));
    }
  }

  void _previousQuestion() {
    final currentQuestion = _questions[_currentQuestionIndex];
    if (currentQuestion.answerKey == 'workoutSplit') {
      final provider = ref.read(onboardingProvider);
      final answer = provider.answers['gymAccess'];
      if (answer == 'Gym') {
        final gymAccessIndex =
            _questions.indexWhere((q) => q.answerKey == 'gymAccess');
        setState(() {
          _currentQuestionIndex = gymAccessIndex;
          _loadAnswerForCurrentQuestion();
        });
        return;
      }
    }

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
    ref.read(onboardingProvider).updateAnswer(key, value);
    setState(() {});
  }

  void _loadAnswerForCurrentQuestion() {
    final provider = ref.read(onboardingProvider);
    final question = _questions[_currentQuestionIndex];
    final answer = provider.answers[question.answerKey];

    _textController.clear();
    _dietStyleController.clear();
    _dietMacrosController.clear();
    _dietCustomController.clear();

    if (answer == null) return;

    switch (question.type) {
      case QuestionType.singleChoice:
      case QuestionType.multiChoice:
        break;
      case QuestionType.textInput:
      case QuestionType.textArea:
      case QuestionType.numberInput:
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
    final provider = ref.watch(onboardingProvider);

    bool isNextEnabled() {
      final answer = provider.answers[currentQuestion.answerKey];
      if (answer == null) return false;

      switch (currentQuestion.type) {
        case QuestionType.singleChoice:
          return answer.toString().isNotEmpty;
        case QuestionType.multiChoice:
          return (answer as List).isNotEmpty;
        case QuestionType.textInput:
        case QuestionType.textArea:
        case QuestionType.numberInput:
          return answer.toString().isNotEmpty;
        case QuestionType.diet:
          if (answer['skipped'] == true) return true;
          return (answer['style']?.isNotEmpty ?? false) ||
              (answer['macros']?.isNotEmpty ?? false) ||
              (answer['custom']?.isNotEmpty ?? false);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.neutralGray,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            Text(
                              currentQuestion.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentQuestion.subtitle,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.subtitleGray,
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildInputArea(currentQuestion),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: ElevatedButton(
                        onPressed: isNextEnabled() ? _nextQuestion : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightGrey2,
                          disabledBackgroundColor: AppColors.lightGrey2,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentQuestionIndex == _questions.length - 1
                              ? 'Review Answers'
                              : 'Next',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    if (_currentQuestionIndex == 0) {
      // First screen: green hero header per Figma
      return Container(
        color: AppColors.primaryGreen,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 28),
            SizedBox(height: 20),
            Text(
              "Let's Begin",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Adaptifit creates a personalized fitness and\nnutrition plan just for you",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Subsequent screens: minimal header with back in grey circle
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: GestureDetector(
            onTap: _previousQuestion,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.neutralGray.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: AppColors.darkText),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(OnboardingQuestion question) {
    switch (question.type) {
      case QuestionType.singleChoice:
        return _buildSingleChoiceList(question);
      case QuestionType.multiChoice:
        return _buildMultiChoiceList(question);
      case QuestionType.textInput:
        return _buildTextInput(question, _textController);
      case QuestionType.textArea:
        return _buildTextArea(question, _textController);
      case QuestionType.diet:
        return _buildDietForm(question);
      case QuestionType.numberInput:
        return _buildNumberInput(question, _textController);
    }
  }

  Widget _buildMultiChoiceList(OnboardingQuestion question) {
    final provider = ref.watch(onboardingProvider);
    // Ensure the answer is a list, defaulting to an empty one if null or wrong type
    final selectedOptions =
        (provider.answers[question.answerKey] as List?)?.cast<String>() ?? [];

    return Column(
      children: question.options.map((option) {
        final isSelected = selectedOptions.contains(option);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GestureDetector(
            onTap: () {
              final newSelection = List<String>.from(selectedOptions);
              if (isSelected) {
                newSelection.remove(option);
              } else {
                newSelection.add(option);
              }
              _updateProviderAnswer(question.answerKey, newSelection);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.timestampGray,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    option,
                    style: const TextStyle(
                      color: AppColors.darkText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : AppColors.subtitleGray,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                            size: 16, color: AppColors.primaryGreen)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSingleChoiceList(OnboardingQuestion question) {
    final provider = ref.watch(onboardingProvider);
    final selectedOption = provider.answers[question.answerKey];

    return Column(
      children: question.options.map((option) {
        final isSelected = selectedOption == option;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GestureDetector(
            onTap: () => _updateProviderAnswer(question.answerKey, option),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen.withOpacity(0.1)
                    : Colors.white,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberInput(
      OnboardingQuestion question, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: (text) => _updateProviderAnswer(question.answerKey, text),
      decoration: InputDecoration(
        hintText: question.placeholders.first,
        filled: true,
        fillColor: AppColors.neutralGray.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
      ),
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
        fillColor: AppColors.neutralGray.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 1.5),
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
        fillColor: AppColors.neutralGray.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDietForm(OnboardingQuestion question) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: AppColors.neutralGray.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
    );

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
          decoration: inputDecoration.copyWith(
            hintText: question.placeholders[0],
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
          decoration: inputDecoration.copyWith(
            hintText: question.placeholders[1],
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
          decoration: inputDecoration.copyWith(
            hintText: question.placeholders[2],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () {
              _updateProviderAnswer(question.answerKey, {'skipped': true});
              _nextQuestion();
            },
            child: const Text(
              'Skip Nutrition',
              style: TextStyle(
                color: AppColors.subtitleGray,
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
