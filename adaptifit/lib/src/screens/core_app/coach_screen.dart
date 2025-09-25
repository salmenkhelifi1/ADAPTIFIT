import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'package:adaptifit/src/constants/app_colors.dart';
import 'package:adaptifit/src/core/models/models.dart';
import 'package:adaptifit/src/services/n8n_service.dart';
import 'package:adaptifit/src/services/firestore_service.dart'; // Import FirestoreService

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final TextEditingController _textController = TextEditingController();
  final N8nService _n8nService = N8nService();
  final FirestoreService _firestoreService = FirestoreService(); // Initialize FirestoreService
  List<ChatMessage> _messages = []; // Change to non-final
  bool _isLoading = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName(); // Load user name without welcome message
    _firestoreService.getChatMessages().listen((messages) {
      setState(() {
        _messages = messages;
      });
    });
  }

  void _loadUserName() {
    // In a real app, you'd fetch the user's name from Firestore
    // For now, we'll use a placeholder.
    _userName = "Alex";
  }

  Future<void> _sendMessage() async {
    final text = _textController.text;
    if (text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Should not happen if user is logged in

    final userMessage = ChatMessage(
      senderId: user.uid,
      text: text,
      timestamp: DateTime.now(),
      messageType: 'user',
    );

    // Add message to Firestore
    await _firestoreService.addChatMessage(userMessage);

    setState(() {
      _isLoading = true;
    });

    _textController.clear();

    final response = await _n8nService.askAiCoach(
      userId: user.uid,
      prompt: text,
    );

    if (response != null) {
      final coachMessage = ChatMessage(
        senderId: 'ai_coach', // A special ID for the AI coach
        text: response,
        timestamp: DateTime.now(),
        messageType: 'ai',
      );
      // Add AI message to Firestore
      await _firestoreService.addChatMessage(coachMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.white,
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
                  style: TextStyle(color: AppColors.timestampGray, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_messages.isEmpty) // Conditional WelcomeBubble
            WelcomeBubble(
              title: 'Hi ${_userName ?? 'there'}! 👋',
              text:
                  'I\'m here to help you achieve your fitness goals. Ask me anything about your workouts, nutrition, or progress!',
            ),
          Expanded(
            child: ListView.builder(
              reverse: true, // To show newest messages at the bottom
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length + (_isLoading ? 1 : 0), // Add 1 for typing indicator
              itemBuilder: (context, index) {
                if (_isLoading && index == 0) {
                  return const TypingIndicator();
                }
                final message = _messages[index - (_isLoading ? 0 : 0)]; // Adjust index if typing indicator is present
                return ChatBubble(
                  text: message.text,
                  time: DateFormat('h:mm a').format(message.timestamp),
                  isUser: message.messageType == 'user',
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
                onSubmitted: (_) => _sendMessage(),
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
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// UI Components from original file, slightly adapted

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
            style: const TextStyle(color: AppColors.timestampGray, fontSize: 12),
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
            'Coach is typing...',
            style: TextStyle(color: AppColors.timestampGray, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }
}
