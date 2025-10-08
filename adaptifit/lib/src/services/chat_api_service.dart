import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_message.dart';

class ChatApiService {
  final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
  final String _token;

  ChatApiService(this._token);

  Future<List<ChatMessage>> getChatHistory() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/chat'),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Adaptifit-Mobile-App/1.0',
        'Accept': 'application/json',
        'Accept-Language': 'en-US,en;q=0.9',
        'Cache-Control': 'no-cache',
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> messagesJson = jsonDecode(response.body);
      return messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load chat history');
    }
  }

  Future<ChatMessage> sendMessage(String text) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/chat'),
      headers: {
        'Content-Type': 'application/json',
        'User-Agent': 'Adaptifit-Mobile-App/1.0',
        'Accept': 'application/json',
        'Accept-Language': 'en-US,en;q=0.9',
        'Cache-Control': 'no-cache',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      return ChatMessage.fromJson(responseBody['data']);
    } else {
      throw Exception('Failed to send message');
    }
  }
}
