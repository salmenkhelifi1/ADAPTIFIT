import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isWaitingForAI = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _typeWriter(String text) async {
    String currentText = "";
    setState(() {
      _messages.add({"role": "ai", "text": currentText});
    });

    for (int i = 0; i < text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      currentText += text[i];
      setState(() {
        _messages[_messages.length - 1]["text"] = currentText;
      });
      _scrollToBottom();
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty || _isWaitingForAI) return;

    final userMessage = _controller.text.trim();
    _controller.clear();

    setState(() {
      _messages.add({"role": "user", "text": userMessage});
      _isWaitingForAI = true;
    });
    _scrollToBottom();

    try {
      // Send once and wait for response
      final response = await http
          .post(
            Uri.parse('https://n8n.iwilltravelto.com/webhook/ask-coach'),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"message": userMessage}),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle JSON array response
        String aiText = "AI did not respond.";
        if (data is List && data.isNotEmpty) {
          aiText = data[0]['output'] ?? "AI did not respond.";
        }

        await _typeWriter(aiText);
      } else {
        await _typeWriter("Error: ${response.statusCode}");
      }
    } on TimeoutException {
      await _typeWriter("AI took too long to respond. Please try again.");
    } catch (e) {
      await _typeWriter("Error: $e");
    } finally {
      setState(() {
        _isWaitingForAI = false;
      });
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length + (_isWaitingForAI ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isWaitingForAI && index == _messages.length) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 10,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('AI is typing...'),
                    ),
                  );
                }

                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return Container(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 10,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(message['text']!),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    enabled: !_isWaitingForAI,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isWaitingForAI ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
