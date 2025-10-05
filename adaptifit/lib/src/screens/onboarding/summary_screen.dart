import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:adaptifit/src/context/onboarding_provider.dart';
import 'package:adaptifit/src/screens/core_app/main_scaffold.dart';
import 'package:adaptifit/src/services/api_service.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  void _finishOnboarding() async {
    setState(() => _isLoading = true);

    final onboardingProvider =
        Provider.of<OnboardingProvider>(context, listen: false);

    try {
      final answers = onboardingProvider.answers;
      await _apiService.submitOnboarding(answers);
      await _apiService.regeneratePlan();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainScaffold()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<OnboardingProvider>(context);
    final answers = provider.answers;

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
            onPressed: _isLoading ? null : _finishOnboarding,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text('Generate My Plan'),
          ),
        ],
      ),
    );
  }
}
