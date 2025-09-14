import 'package:flutter/material.dart';
import '/src/constants/app_colors.dart';

class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightMintBackground,
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
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Your AI fitness coach',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: const [
                WelcomeBubble(
                  title: 'Hi Alex! 👋',
                  text:
                      'I\'m here to help you achieve your fitness goals. Ask me anything about your workouts, nutrition, or progress!',
                ),
                SizedBox(height: 16),
                ChatBubble(
                  text:
                      'Hi Alex! 👋 How are you feeling about your workout today?',
                  time: '2:40 PM',
                  isUser: false,
                ),
                ChatBubble(
                  text:
                      'I\'m ready to crush it! Should I do the upper body workout first?',
                  time: '2:42 PM',
                  isUser: true,
                ),
                ChatBubble(
                  text:
                      'Perfect energy! Yes, let\'s start with upper body. Remember to warm up for 5-10 minutes first. I\'ll track your progress and adjust if needed. 💪',
                  time: '2:43 PM',
                  isUser: false,
                ),
              ],
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
                decoration: InputDecoration(
                  hintText: 'Ask your coach anything...',
                  filled: true,
                  fillColor: AppColors.lightMintBackground,
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
                onPressed: () {},
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
      decoration: BoxDecoration(
        color: AppColors.lightMint,
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
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.black,
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

  const ChatBubble(
      {super.key,
      required this.text,
      required this.time,
      required this.isUser});

  @override
  Widget build(BuildContext context) {
    final alignment =
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isUser ? AppColors.primaryGreen : AppColors.white;
    final textColor = isUser ? AppColors.white : AppColors.black;

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
                child:
                    Icon(Icons.auto_awesome, color: AppColors.white, size: 16),
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
              ? const EdgeInsets.only(right: 8.0)
              : const EdgeInsets.only(left: 48.0),
          child: Text(
            time,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
