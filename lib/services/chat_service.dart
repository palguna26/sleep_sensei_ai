import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';

class ChatService {
  final _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<void> saveMessage(String uid, ChatMessage message) async {
    await _firestore
        .collection('users/$uid/chats')
        .doc(message.id)
        .set(message.toMap());
  }

  Future<List<ChatMessage>> fetchMessages(String uid) async {
    final snap = await _firestore
        .collection('users/$uid/chats')
        .orderBy('timestamp')
        .get();

    return snap.docs.map((doc) => ChatMessage.fromMap(doc.data())).toList();
  }

  Future<ChatMessage> sendToGPT(String prompt) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-4",
        "messages": [
          {"role": "user", "content": prompt}
        ],
      }),
    );

    if (response.statusCode == 200) {
      final content = jsonDecode(response.body)['choices'][0]['message']['content'];
      return ChatMessage(
        id: _uuid.v4(),
        sender: Sender.assistant,
        content: content,
        timestamp: DateTime.now(),
      );
    } else {
      throw Exception('Failed to get response from GPT: ${response.body}');
    }
  }
}
