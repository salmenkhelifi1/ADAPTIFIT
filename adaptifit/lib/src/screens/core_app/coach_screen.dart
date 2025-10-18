import 'package:adaptifit/src/models/chat_message.dart';
import 'package:adaptifit/src/services/chat_api_service.dart';
import 'package:adaptifit/src/services/chat_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:adaptifit/src/constants/app_colors.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatCacheService _chatCache = ChatCacheService();
  ChatApiService? _chatApiService;

  // Represents loading a new message from the AI, not the initial history
  bool _isAiTyping = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Simple approach - just initialize chat once
    _initializeChat();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _initializeChat() async {
    if (_chatApiService != null) return; // Already initialized

    const secureStorage = FlutterSecureStorage();
    final token = await secureStorage.read(key: 'jwt_token');
    if (token != null) {
      _chatApiService = ChatApiService(token);
      await _loadHistory();
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isAiTyping = true; // Show loading indicator while fetching history
    });
    try {
      if (_chatApiService != null) {
        await _chatCache.loadHistory(_chatApiService!);
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isAiTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  Future<void> _handleSendPressed() async {
    final text = _textController.text;
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().toString(), // Temporary ID
      text: text,
      sender: 'user',
      timestamp: DateTime.now(),
    );

    setState(() {
      _chatCache.addUserMessage(userMessage);
      _isAiTyping = true;
    });
    _scrollToBottom();

    _textController.clear();

    try {
      if (_chatApiService != null) {
        final aiMessage = await _chatApiService!.sendMessage(text);
        _chatCache.addAiMessage(aiMessage);
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isAiTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryGreen,
              child: Icon(Icons.auto_awesome, color: AppColors.white, size: 20),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AdaptiCoach',
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Your AI fitness coach',
                  style:
                      TextStyle(color: AppColors.timestampGray, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_chatCache.messages.isEmpty && !_isAiTyping)
            WelcomeBubble(
              title: 'Hi ${_userName ?? 'there'}! 👋',
              text:
                  'I\'m here to help you achieve your fitness goals. Ask me anything about your workouts, nutrition, or progress!',
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.all(16.0),
              itemCount: _chatCache.messages.length + (_isAiTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isAiTyping && index == 0) {
                  return const TypingIndicator();
                }
                final messageIndex = _isAiTyping ? index - 1 : index;
                if (messageIndex < 0 ||
                    messageIndex >= _chatCache.messages.length) {
                  return const SizedBox.shrink();
                }
                final message = _chatCache.messages[messageIndex];
                return ChatBubble(
                  text: message.text,
                  time: DateFormat('h:mm a').format(message.timestamp),
                  isUser: message.sender == 'user',
                );
              },
            ),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: AppColors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: (_) => _handleSendPressed(),
                decoration: InputDecoration(
                  hintText: 'Ask your coach anything...',
                  filled: true,
                  fillColor: AppColors.neutralGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 14.0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primaryGreen,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: AppColors.white),
                onPressed: _handleSendPressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeBubble extends StatelessWidget {
  final String title;
  final String text;
  const WelcomeBubble({super.key, required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.neutralGray,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.darkText,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isUser;

  const ChatBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final alignment =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isUser ? AppColors.primaryGreen : AppColors.white;
    final textColor = isUser ? AppColors.white : AppColors.darkText;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primaryGreen,
                child: Icon(
                  Icons.auto_awesome,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  text,
                  style: TextStyle(color: textColor, fontSize: 16, height: 1.4),
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: isUser
              ? const EdgeInsets.only(right: 8.0, top: 4)
              : const EdgeInsets.only(left: 48.0, top: 4),
          child: Text(
            time,
            style:
                const TextStyle(color: AppColors.timestampGray, fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primaryGreen,
          child: Icon(Icons.auto_awesome, color: AppColors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Coach is typing...', // Corrected escaping for single quote
            style: TextStyle(
                color: AppColors.timestampGray, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}
