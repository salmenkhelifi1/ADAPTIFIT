class ChatMessage {
  final String text;
  final DateTime timestamp;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.timestamp,
    required this.isUser,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'timestamp': timestamp,
      'isUser': isUser,
    };
  }
}