import 'package:flutter/material.dart';
import 'package:adaptifit/src/constants/app_colors.dart';
import 'package:adaptifit/src/screens/core_app/main_scaffold.dart';

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
  final List<String> options;
  final List<String> placeholders;

  OnboardingQuestion({
    required this.title,
    required this.subtitle,
    required this.type,
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
  final List<OnboardingQuestion> _questions = [
    OnboardingQuestion(
      title: 'How many days per week can you realistically work out?',
      subtitle:
          'Be honest with yourself—consistency matters more than perfection. We’ll design your plan around your schedule.',
      type: QuestionType.singleChoice,
      options: ['1', '2', '3', '4', '5', '6', '7'],
    ),
    OnboardingQuestion(
      title: 'How long would you like your personalized plan to last?',
      subtitle:
          'Most people choose 30, 60, or 90 days — but you can set any timeline that fits your goals.',
      type: QuestionType.textInput,
      placeholders: ['Enter number of days'],
    ),
    OnboardingQuestion(
      title: 'Do you have any injuries or physical limitations?',
      subtitle:
          'This helps us adapt your plan so you can train safely and effectively.',
      type: QuestionType.textArea,
      placeholders: [
        'e.g., shoulder impingement, knee pain, lower back issues',
      ],
    ),
    OnboardingQuestion(
      title: 'Do you follow a specific diet or have nutrition preferences?',
      subtitle:
          'This helps us personalize your plan around your lifestyle. Add your diet style, macros, or calories if you’d like. If you skip, we’ll create only your workout plan and hide nutrition sections in the app.',
      type: QuestionType.diet,
      placeholders: [
        'e.g., high protein, vegetarian, keto, plant-based',
        '2000 kcal or macros in grams',
        'Enter custom dietary preferences',
      ],
    ),
  ];

  int _currentQuestionIndex = 0;
  final Map<int, dynamic> _answers = {};

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
  }

  @override
  void dispose() {
    _textController.dispose();
    _dietStyleController.dispose();
    _dietMacrosController.dispose();
    _dietCustomController.dispose();
    super.dispose();
  }

  void _goToNextScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainScaffold()),
      (Route<dynamic> route) => false,
    );
  }

  void _nextQuestion() {
    _saveCurrentAnswer();
    setState(() {
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
        _loadAnswerForCurrentQuestion();
      } else {
        _goToNextScreen();
      }
    });
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _saveCurrentAnswer();
        _currentQuestionIndex--;
        _loadAnswerForCurrentQuestion();
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _saveCurrentAnswer() {
    final question = _questions[_currentQuestionIndex];
    switch (question.type) {
      case QuestionType.singleChoice:
        break;
      case QuestionType.textInput:
      case QuestionType.textArea:
        _answers[_currentQuestionIndex] = _textController.text;
        break;
      case QuestionType.diet:
        _answers[_currentQuestionIndex] = {
          'style': _dietStyleController.text,
          'macros': _dietMacrosController.text,
          'custom': _dietCustomController.text,
        };
        break;
    }
  }

  void _loadAnswerForCurrentQuestion() {
    final answer = _answers[_currentQuestionIndex];
    final question = _questions[_currentQuestionIndex];
    _textController.clear();
    _dietStyleController.clear();
    _dietMacrosController.clear();
    _dietCustomController.clear();

    if (answer == null) return;

    switch (question.type) {
      case QuestionType.singleChoice:
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

    bool isNextEnabled() {
      final answer = _answers[_currentQuestionIndex];
      switch (currentQuestion.type) {
        case QuestionType.singleChoice:
          return answer != null;
        case QuestionType.textInput:
        case QuestionType.textArea:
          return _textController.text.isNotEmpty;
        case QuestionType.diet:
          return _dietStyleController.text.isNotEmpty ||
              _dietMacrosController.text.isNotEmpty ||
              _dietCustomController.text.isNotEmpty;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.lightMintBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightMintBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
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
                onPressed: isNextEnabled() ? _nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  disabledBackgroundColor: AppColors.grey.shade400,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  _currentQuestionIndex == _questions.length - 1
                      ? 'Done'
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
        return _buildSingleChoiceList(question.options);
      case QuestionType.textInput:
        return _buildTextInput(question.placeholders.first, _textController);
      case QuestionType.textArea:
        return _buildTextArea(question.placeholders.first, _textController);
      case QuestionType.diet:
        return _buildDietForm(question.placeholders);
    }
  }

  Widget _buildSingleChoiceList(List<String> options) {
    return Column(
      children: options.map((option) {
        final isSelected = _answers[_currentQuestionIndex] == option;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GestureDetector(
            onTap: () =>
                setState(() => _answers[_currentQuestionIndex] = option),
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
                      : AppColors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Text(
                option,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.black,
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

  Widget _buildTextInput(String placeholder, TextEditingController controller) {
    return TextField(
      controller: controller,
      onChanged: (text) => setState(() {}),
      decoration: InputDecoration(
        hintText: placeholder,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildTextArea(String placeholder, TextEditingController controller) {
    return TextField(
      controller: controller,
      onChanged: (text) => setState(() {}),
      maxLines: 4,
      decoration: InputDecoration(
        hintText: placeholder,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primaryGreen, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildDietForm(List<String> placeholders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextInput(placeholders[0], _dietStyleController),
        const SizedBox(height: 16),
        _buildTextInput(placeholders[1], _dietMacrosController),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Set daily macros or calories (optional)',
            style: TextStyle(color: Colors.black54),
          ),
        ),
        _buildTextInput(placeholders[2], _dietCustomController),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Other (please specify)',
            style: TextStyle(color: Colors.black54),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: TextButton(
            onPressed: () {
              _answers[_currentQuestionIndex] = {'skipped': true};
              _goToNextScreen();
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
