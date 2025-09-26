import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:adaptifit/src/context/onboarding_provider.dart';
import 'package:adaptifit/src/screens/core_app/main_scaffold.dart';
import 'package:adaptifit/src/services/auth_service.dart';
import 'package:adaptifit/src/services/firestore_service.dart';
import 'package:adaptifit/src/services/n8n_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final N8nService _n8nService = N8nService();
  bool _isLoading = false;

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
