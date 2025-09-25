import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adaptifit/src/constants/app_colors.dart';
import 'package:adaptifit/src/context/onboarding_provider.dart';
import 'package:adaptifit/src/screens/onboarding/onboarding_question_screen.dart';

class OnboardingExperienceScreen extends StatefulWidget {
  const OnboardingExperienceScreen({super.key});

  @override
  State<OnboardingExperienceScreen> createState() =>
      _OnboardingExperienceScreenState();
}

class _OnboardingExperienceScreenState
    extends State<OnboardingExperienceScreen> {
  String? _selectedExperience;
  final List<String> _experienceLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill the selection if the user has already answered this question.
    // This is useful if they navigate back and forth.
    _selectedExperience =
        Provider.of<OnboardingProvider>(context, listen: false)
            .answers['experienceLevel'];
  }

  @override
  Widget build(BuildContext context) {
    print('Building OnboardingExperienceScreen');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightMintBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'What is your fitness experience level?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This helps us tailor your workouts so they feel just right—challenging but doable.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 40),
                    ..._experienceLevels.map((level) {
                      final isSelected = _selectedExperience == level;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedExperience = level;
                              // Save the user's choice to the provider
                              Provider.of<OnboardingProvider>(context,
                                      listen: false)
                                  .updateAnswer('experienceLevel', level);
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryGreen
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
                              level,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _selectedExperience != null
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const OnboardingQuestionScreen(),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  disabledBackgroundColor: AppColors.grey.shade400,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Next',
                  style: TextStyle(
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
}