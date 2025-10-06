import 'package:adaptifit/src/providers/api_service_provider.dart';
import 'package:adaptifit/src/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:adaptifit/src/screens/core_app/main_scaffold.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  void _finishOnboarding(BuildContext context, WidgetRef ref) async {
    final onboardingProviderNotifier = ref.read(onboardingProvider.notifier);

    try {
      final answers = onboardingProviderNotifier.answers;
      await ref.read(apiServiceProvider).submitOnboarding(answers);
      await ref.read(apiServiceProvider).regeneratePlan();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScaffold()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(onboardingProvider).answers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Your Answers'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ...answers.entries.map((entry) {
            return ListTile(
              title: Text(entry.key),
              subtitle: Text(entry.value.toString()),
            );
          }).toList(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _finishOnboarding(context, ref),
            child: const Text('Generate My Plan'),
          ),
        ],
      ),
    );
  }
}
