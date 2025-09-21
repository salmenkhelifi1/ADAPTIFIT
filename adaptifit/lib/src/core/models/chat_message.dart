class ChatMessage {
  final String senderId; // User ID or a special ID for AI
  final String text;
  final DateTime timestamp;
  final String messageType; // e.g., 'user', 'ai'

  ChatMessage({
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.messageType,
  });

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(), // Store as ISO 8601 string
      'messageType': messageType,
    };
  }

  factory ChatMessage.fromFirestore(Map<String, dynamic> data) {
    return ChatMessage(
      senderId: data['senderId'] as String,
      text: data['text'] as String,
      timestamp: DateTime.parse(data['timestamp'] as String),
      messageType: data['messageType'] as String,
    );
  }
}