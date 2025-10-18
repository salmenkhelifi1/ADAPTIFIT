import 'package:adaptifit/src/providers/api_service_provider.dart';
import 'package:adaptifit/src/providers/plan_provider.dart';
import 'package:adaptifit/src/providers/calendar_provider.dart';
import 'package:adaptifit/src/providers/today_plan_provider.dart';
import 'package:adaptifit/src/providers/weekly_progress_provider.dart';
import 'package:flutter/material.dart';
import 'package:adaptifit/src/utils/message_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RewritePlanScreen extends ConsumerStatefulWidget {
  const RewritePlanScreen({super.key});

  @override
  ConsumerState<RewritePlanScreen> createState() => _RewritePlanScreenState();
}

class _RewritePlanScreenState extends ConsumerState<RewritePlanScreen> {
  bool _isRegenerating = false;

  Future<void> _regeneratePlan() async {
    setState(() {
      _isRegenerating = true;
    });

    try {
      await ref.read(apiServiceProvider).regeneratePlan();

      // Invalidate all relevant providers to refresh data
      ref.invalidate(plansProvider);
      ref.invalidate(calendarEntriesProvider);
      ref.invalidate(todayPlanNotifierProvider);
      ref.invalidate(weeklyProgressProvider);

      if (mounted) {
        showSnackBarMessage(
          context,
          'Your plan is being regenerated. This may take a few minutes.',
        );
        Navigator.of(context).pop(); // Close the screen
      }
    } catch (e) {
      if (mounted) {
        showSnackBarMessage(
          context,
          'Failed to start plan regeneration: ${e.toString()}',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRegenerating = false;
        });
      }
    }
  }

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
                if (_isRegenerating)
                  const CircularProgressIndicator()
                else
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
                          onPressed: _regeneratePlan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1EB955),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Rewrite Plan'),
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
