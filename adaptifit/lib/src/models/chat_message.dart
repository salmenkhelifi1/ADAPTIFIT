
class ChatMessage {
  final String id;
  final String text;
  final String sender;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'],
      text: json['text'],
      sender: json['sender'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
