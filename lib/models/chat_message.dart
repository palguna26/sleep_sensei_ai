enum Sender { user, assistant }

class ChatMessage {
  final String id;
  final Sender sender;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sender': sender.name,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'],
      sender: map['sender'] == 'user' ? Sender.user : Sender.assistant,
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
