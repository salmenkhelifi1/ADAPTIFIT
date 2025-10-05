import 'package:adaptifit/src/models/chat_message.dart';
import 'package:adaptifit/src/services/chat_api_service.dart';
import 'package:flutter/foundation.dart';

class ChatCacheService {
  // Singleton pattern
  static final ChatCacheService _instance = ChatCacheService._internal();
  factory ChatCacheService() {
    return _instance;
  }
  ChatCacheService._internal();

  final List<ChatMessage> _messages = [];
  bool _hasFetchedHistory = false;

  List<ChatMessage> get messages => _messages;

  bool get hasMessages => _messages.isNotEmpty;

  Future<void> loadHistory(ChatApiService apiService) async {
    if (!_hasFetchedHistory) {
      try {
        final history = await apiService.getChatHistory();
        _messages.clear();
        _messages.addAll(history.reversed);
        _hasFetchedHistory = true;
      } catch (e) {
        if (kDebugMode) {
          print("Failed to load chat history: $e");
        }
        // Re-throw the exception to be handled by the UI
        rethrow;
      }
    }
  }

  void addUserMessage(ChatMessage message) {
    _messages.insert(0, message);
  }

  void addAiMessage(ChatMessage message) {
    _messages.insert(0, message);
  }
}
