import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class N8nService {
  final String _generatePlanWebhookUrl =
      'https://adaptifit.app.n8n.cloud/webhook/generate-plan';
  final String _askCoachWebhookUrl =
      'https://adaptifit.app.n8n.cloud/webhook/ask-coach';

  /// Triggers the plan generation workflow and waits for the JSON plan response.
  Future<Map<String, dynamic>?> triggerPlanGeneration({
    required String userId,
    required Map<String, dynamic> onboardingAnswers,
  }) async {
    try {
      final requestBody = {
        'userId': userId,
        'onboardingAnswers': onboardingAnswers,
      };
      debugPrint('N8N Service: Sending plan generation request...');
      debugPrint('N8N Service: URL: $_generatePlanWebhookUrl');
      debugPrint('N8N Service: Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(_generatePlanWebhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      debugPrint(
          'N8N Service: Received response for plan generation. Status: ${response.statusCode}');
      debugPrint('N8N Service: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is Map && responseData.containsKey('output')) {
          return jsonDecode(responseData['output']) as Map<String, dynamic>?;
        }
        return responseData as Map<String, dynamic>?;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('N8N Service: ERROR during plan generation webhook call: $e');
      return null;
    }
  }

  /// Sends a chat message to the AI coach and gets a text response.
  Future<String?> askAiCoach({
    required String userId,
    required String prompt,
  }) async {
    try {
      final requestBody = {
        'userId': userId,
        'prompt': prompt,
      };
      debugPrint('N8N Service: Sending chat message to AI coach...');
      debugPrint('N8N Service: URL: $_askCoachWebhookUrl');
      debugPrint('N8N Service: Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse(_askCoachWebhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      debugPrint(
          'N8N Service: Received response from AI coach. Status: ${response.statusCode}');
      debugPrint('N8N Service: Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        // This part now needs to look for "output" as per our fix guide.
        if (responseBody is Map && responseBody.containsKey('output')) {
          return responseBody['output'] as String?;
        } else {
          debugPrint(
              'N8N Service: ERROR - Response JSON did not contain an "output" key.');
          return 'I seem to be having a technical issue. Please try again later.';
        }
      } else {
        return 'Sorry, I encountered an error. Please try again.';
      }
    } catch (e) {
      debugPrint('N8N Service: ERROR during AI coach webhook call: $e');
      return null;
    }
  }
}
