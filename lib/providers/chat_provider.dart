import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/chat_message.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _uid;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void init(String uid) {
    _uid = uid;
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (_uid == null) return;
    
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('chats')
          .orderBy('timestamp')
          .get();

      _messages = querySnapshot.docs
          .map((doc) => ChatMessage.fromMap(doc.data()))
          .toList();

      // Add welcome message if no messages exist
      if (_messages.isEmpty) {
        _messages.add(ChatMessage(
          id: _uuid.v4(),
          sender: Sender.assistant,
          content: "Hello! I'm your AI sleep coach. How can I help you improve your sleep today?",
          timestamp: DateTime.now(),
        ));
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading messages: $e');
      // Add fallback welcome message
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        sender: Sender.assistant,
        content: "Hello! I'm your AI sleep coach. How can I help you improve your sleep today?",
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (_uid == null || text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: _uuid.v4(),
      sender: Sender.user,
      content: text,
      timestamp: DateTime.now(),
    );
    
    _messages.add(userMessage);
    notifyListeners();
    
    // Save user message to Firebase
    await _saveMessage(userMessage);

    _isLoading = true;
    notifyListeners();

    try {
      final reply = await _sendToGPT(text);
      _messages.add(reply);
      await _saveMessage(reply);
    } catch (e) {
      debugPrint('Error getting AI response: $e');
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        sender: Sender.assistant,
        content: "I'm sorry, I'm having trouble connecting right now. Please try again later.",
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
      await _saveMessage(errorMessage);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveMessage(ChatMessage message) async {
    if (_uid == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('chats')
          .doc(message.id)
          .set(message.toMap());
    } catch (e) {
      debugPrint('Error saving message: $e');
    }
  }

  Future<ChatMessage> _sendToGPT(String prompt) async {
    // Load API key from environment
    String? apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty || apiKey == 'your-openai-api-key-here') {
      // Fallback to intelligent responses without API call
      return ChatMessage(
        id: _uuid.v4(),
        sender: Sender.assistant,
        content: _generateFallbackResponse(prompt),
        timestamp: DateTime.now(),
      );
    }

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": "gpt-4",
          "messages": [
            {
              "role": "system",
              "content": "You are a professional sleep coach and sleep expert. Provide helpful, evidence-based advice about sleep hygiene, sleep problems, and improving sleep quality. Keep responses concise but informative."
            },
            {"role": "user", "content": prompt}
          ],
          "max_tokens": 300,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        return ChatMessage(
          id: _uuid.v4(),
          sender: Sender.assistant,
          content: content,
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception('API request failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('OpenAI API error: $e');
      // Fallback response
      return ChatMessage(
        id: _uuid.v4(),
        sender: Sender.assistant,
        content: _generateFallbackResponse(prompt),
        timestamp: DateTime.now(),
      );
    }
  }

  String _generateFallbackResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('sleep') && message.contains('problem')) {
      return "I understand you're having sleep issues. Let's work on improving your sleep hygiene. Try to maintain a consistent sleep schedule and create a relaxing bedtime routine.";
    } else if (message.contains('insomnia')) {
      return "Insomnia can be challenging. Consider practicing relaxation techniques like deep breathing or meditation before bed. Also, avoid screens 1 hour before sleep.";
    } else if (message.contains('wake up') || message.contains('tired')) {
      return "If you're feeling tired during the day, it might be due to insufficient sleep or poor sleep quality. Aim for 7-9 hours of sleep and try to wake up at the same time daily.";
    } else if (message.contains('alarm') || message.contains('wake')) {
      return "Setting a consistent wake-up time helps regulate your circadian rhythm. Try to get up at the same time every day, even on weekends.";
    } else if (message.contains('bedtime') || message.contains('routine')) {
      return "A good bedtime routine is essential for quality sleep. Try reading a book, taking a warm bath, or listening to calming music 30 minutes before bed.";
    } else if (message.contains('stress') || message.contains('anxiety')) {
      return "Stress and anxiety can significantly impact sleep. Try journaling, meditation, or progressive muscle relaxation before bed to calm your mind.";
    } else if (message.contains('caffeine') || message.contains('coffee')) {
      return "Caffeine can stay in your system for 6-8 hours. Try to avoid caffeine after 2 PM to ensure it doesn't interfere with your sleep.";
    } else if (message.contains('exercise') || message.contains('workout')) {
      return "Regular exercise can improve sleep quality, but avoid intense workouts 2-3 hours before bedtime as they can be stimulating.";
    } else {
      return "Thank you for sharing that with me. Sleep is crucial for your health and well-being. Is there anything specific about your sleep that you'd like to discuss?";
    }
  }

  Future<void> clearChat() async {
    if (_uid == null) return;
    
    try {
      // Delete all messages from Firebase
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('chats')
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      // Clear local messages
      _messages.clear();
      
      // Add welcome message
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        sender: Sender.assistant,
        content: "Hello! I'm your AI sleep coach. How can I help you improve your sleep today?",
        timestamp: DateTime.now(),
      ));
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing chat: $e');
    }
  }
}
