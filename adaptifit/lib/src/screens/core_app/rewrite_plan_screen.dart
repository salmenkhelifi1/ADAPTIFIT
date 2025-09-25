import 'package:flutter/material.dart';
import 'package:adaptifit/src/services/n8n_service.dart';
import 'package:adaptifit/src/utils/message_utils.dart';

class RewritePlanScreen extends StatelessWidget {
  final String userId;
  final Map<String, dynamic> onboardingAnswers;
  final N8nService n8nService;

  const RewritePlanScreen({
    super.key,
    required this.userId,
    required this.onboardingAnswers,
    required this.n8nService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Are you sure you want to rewrite your plan?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'If you continue, your current plan will be lost and replaced with a new one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1EB955),
                          side: const BorderSide(color: Color(0xFF1EB955)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        child: const Text('Rewrite Plan'),
                        onPressed: () {
                          n8nService.triggerPlanGeneration(
                            userId: userId,
                            onboardingAnswers: onboardingAnswers,
                          );
                          showSnackBarMessage(
                            context,
                            'Your plan is being regenerated. This may take a few minutes.',
                          );
                          Navigator.of(context).pop(); // Close the screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1EB955),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
