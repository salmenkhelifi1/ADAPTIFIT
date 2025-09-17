// lib/src/services/n8n_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class N8nService {
  // IMPORTANT: Replace this with your actual N8N Webhook URL
  final String _webhookUrl =
      'https://n8n.iwilltravelto.com/webhook/ask-ai-assistant';

  Future<void> triggerPlanGeneration({
    required String userId,
    required Map<String, dynamic> onboardingAnswers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'onboardingAnswers': onboardingAnswers,
        }),
      );

      if (response.statusCode == 200) {
        print('Successfully triggered plan generation for user: $userId');
      } else {
        // Handle non-200 responses
        print(
            'Failed to trigger plan generation. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle network errors or other exceptions
      print('An error occurred while calling the N8N webhook: $e');
    }
  }
}
