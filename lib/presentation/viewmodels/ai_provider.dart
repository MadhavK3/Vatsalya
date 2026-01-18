import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:maternal_infant_care/domain/services/gemini_service.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_provider.dart';
import 'package:maternal_infant_care/data/repositories/chat_history_repository.dart';
import 'package:maternal_infant_care/data/models/chat_session_model.dart';
import 'package:maternal_infant_care/data/models/chat_message_model.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';
import 'package:uuid/uuid.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  final userProfile = ref.watch(userProfileProvider);
  
  String instruction = "You are a helpful maternal and infant care assistant.";
  if (userProfile == UserProfileType.pregnant) {
    instruction += " The user is currently pregnant. Provide advice relevant to pregnancy.";
  } else if (userProfile == UserProfileType.toddlerParent) {
    instruction += " The user is a parent of a toddler. Provide advice relevant to parenting a toddler.";
  }
  
  instruction += " Do not prescribe medical treatments. Always advise consulting a healthcare professional for medical issues. If the query is not related to maternal or infant care, politely guide the user back to the topic.";

  return GeminiService(systemInstruction: instruction);
});

final aiResponseProvider = StateNotifierProvider<AiChatNotifier, List<ChatMessage>>((ref) {
  final service = ref.watch(geminiServiceProvider);
  final repoAsync = ref.watch(chatHistoryRepositoryProvider);
  return AiChatNotifier(service, repoAsync.value, ref);
});

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isError = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      isError: json['isError'] ?? false,
    );
  }
}

class AiChatNotifier extends StateNotifier<List<ChatMessage>> {
  final GeminiService _service;
  final ChatHistoryRepository? _repository;
  final Ref _ref;
  String? currentSessionId;

  AiChatNotifier(this._service, this._repository, this._ref) : super([]) {
    // Optionally load last session or start new?
    // For now, let's start fresh.
  }
  
  void startNewSession() {
    currentSessionId = null;
    state = [];
    _service.clearSession();
    _ref.invalidate(chatSessionsProvider);
  }

  Future<void> loadSession(String sessionId) async {
    if (_repository == null) return;
    
    final session = _repository!.getSession(sessionId);
    if (session != null) {
      currentSessionId = sessionId;
      
      // Convert Hive models to UI models
      final messages = session.messages.map((m) => ChatMessage(
        text: m.text,
        isUser: m.isUser,
        timestamp: m.timestamp,
      )).toList();
      
      state = messages;
      
      // Initialize Gemini context
      final contentHistory = messages.map((msg) {
          return Content(msg.isUser ? 'user' : 'model', [TextPart(msg.text)]);
        }).toList();
      _service.initializeSession(contentHistory);
      _ref.invalidate(chatSessionsProvider);
    }
  }

  Future<void> _saveCurrentSession() async {
    if (_repository == null) return;

    // Create session ID if new
    currentSessionId ??= const Uuid().v4();
    
    // Determine title (first user message or "New Chat")
    String title = "New Chat";
    final firstUserMsg = state.where((m) => m.isUser).firstOrNull;
    if (firstUserMsg != null) {
      title = firstUserMsg.text.length > 30 
          ? '${firstUserMsg.text.substring(0, 30)}...' 
          : firstUserMsg.text;
    }

    // Convert UI models to Hive models
    final hiveMessages = state.map((m) => ChatMessageModel(
      id: const Uuid().v4(), // Generate ID for message
      text: m.text,
      isUser: m.isUser,
      timestamp: m.timestamp,
    )).toList();

    final session = ChatSessionModel(
      id: currentSessionId!,
      title: title,
      lastUpdated: DateTime.now(),
      messages: hiveMessages,
    );

    await _repository!.saveSession(session);
    _ref.invalidate(chatSessionsProvider);
  }

  Future<void> sendMessage(String text) async {
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    state = [...state, userMessage];

    final response = await _service.sendMessage(text);

    final isError = response.startsWith('Error:') || 
                    response.startsWith('Rate limit') || 
                    response.startsWith('API key') ||
                    response.startsWith('Network error') ||
                    response.startsWith('Sorry, I encountered an error');

    final aiMessage = ChatMessage(
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
      isError: isError,
    );

    state = [...state, aiMessage];
    
    // Save to Hive
    await _saveCurrentSession();
  }

  Future<void> clearChat() async {
    // Only clears current view, doesn't delete session from DB unless explicit delete
    _service.clearSession();
    state = [];
    currentSessionId = null;
    _ref.invalidate(chatSessionsProvider);
  }
}
