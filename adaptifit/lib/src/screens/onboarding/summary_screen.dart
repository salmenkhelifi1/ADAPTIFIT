import 'package:adaptifit/src/providers/api_service_provider.dart';
import 'package:adaptifit/src/providers/auth_provider.dart'; // Assuming this is your onboarding provider location
import 'package:adaptifit/src/providers/plan_provider.dart';
import 'package:adaptifit/src/providers/calendar_provider.dart';
import 'package:adaptifit/src/providers/today_plan_provider.dart';
import 'package:adaptifit/src/providers/weekly_progress_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:adaptifit/src/constants/app_colors.dart';
import 'package:adaptifit/src/screens/core_app/main_scaffold.dart';

// You might need to adjust this provider import based on your project structure
// For example:
// import 'package:adaptifit/src/providers/onboarding_provider.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  // This function remains the same as it contains your business logic.
  void _finishOnboarding(BuildContext context, WidgetRef ref) async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      final answers = ref.read(onboardingProvider.notifier).answers;
      await ref.read(apiServiceProvider).submitOnboarding(answers);
      await ref.read(apiServiceProvider).regeneratePlan();

      // Invalidate all relevant providers to refresh data after plan regeneration
      ref.invalidate(plansProvider);
      ref.invalidate(calendarEntriesProvider);
      ref.invalidate(todayPlanNotifierProvider);
      ref.invalidate(weeklyProgressProvider);

      if (context.mounted) {
        // Pop the loading dialog
        Navigator.of(context).pop();
        // Navigate to the main screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScaffold()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Pop the loading dialog
        Navigator.of(context).pop();
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  // Helper widget to build each row in the fitness profile
  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(onboardingProvider).answers;

    // --- UI Colors ---
    const buttonColor = Color(0xFF28A745); // A nice, vibrant green
    const cardColor = Colors.white;
    const textColor = Colors.black87;

    return Scaffold(
      backgroundColor: AppColors.neutralGray,
      appBar: AppBar(
        // Makes AppBar blend with the background
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Provides the back arrow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Card(
              color: cardColor,
              elevation: 1,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Fitness Profile',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Dynamically create rows from your provider data
                    ...answers.entries.map((entry) {
                      // This handles if a value is a list (like goals) or a single item
                      String valueText = '';
                      // Skip empty or irrelevant answers
                      if (entry.value == null ||
                          (entry.value is String && entry.value.isEmpty) ||
                          (entry.value is List && entry.value.isEmpty)) {
                        return const SizedBox.shrink();
                      }

                      if (entry.key == 'diet' && entry.value is Map) {
                        final dietMap = entry.value as Map;
                        if (dietMap['skipped'] == true) {
                          valueText = 'Skipped';
                        } else {
                          final parts = [
                            dietMap['style'],
                            dietMap['macros'],
                            dietMap['custom']
                          ].where((v) => v != null && v.isNotEmpty).toList();
                          valueText = parts.join('\n');
                        }
                      } else if (entry.value is List) {
                        valueText = (entry.value as List).join('\n');
                      } else {
                        valueText = entry.value.toString();
                        // Add units for specific duration fields
                        if (entry.key == 'planDuration') {
                          valueText = '$valueText days';
                        } else if (entry.key == 'timePerSession') {
                          valueText = '$valueText minutes';
                        }
                      }
                      if (valueText.isEmpty) return const SizedBox.shrink();
                      // Use our helper to create the row
                      return _buildProfileRow(
                        // A simple way to format the key (e.g., 'fitnessGoal' -> 'Fitness Goal')
                        entry.key
                            .replaceAllMapped(RegExp(r'(?<=[a-z])[A-Z]'),
                                (Match m) => ' ${m.group(0)}')
                            .replaceFirst(
                                entry.key[0], entry.key[0].toUpperCase()),
                        valueText,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Use bottomNavigationBar for a button that sticks to the bottom
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32), // Add bottom padding
        child: ElevatedButton(
          onPressed: () => _finishOnboarding(context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: const Text(
            'Confirm and Generate Plan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
