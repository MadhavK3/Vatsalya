import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:maternal_infant_care/core/constants/env.dart';

class GeminiService {
  late final GenerativeModel _model;
  ChatSession? _chatSession;

  GeminiService({String? systemInstruction}) {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: Env.geminiApiKey,
      systemInstruction: systemInstruction != null ? Content.system(systemInstruction) : null,
    );
  }

  Future<String> generateContent(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response from AI.';
    } catch (e) {
      print('Gemini generateContent error: $e');
      return 'Sorry, I encountered an error. Please try again.';
    }
  }

  void initializeSession(List<Content> history) {
    _chatSession = _model.startChat(history: history);
  }

  Future<String> sendMessage(String message) async {
    if (Env.geminiApiKey.isEmpty) {
      return 'Error: Gemini API key is missing. Please check your .env file.';
    }

    try {
      _chatSession ??= _model.startChat();
      final response = await _chatSession!.sendMessage(Content.text(message));
      final text = response.text;
      
      if (text == null || text.isEmpty) {
        return 'I apologize, but I couldn\'t generate a response. Please try rephrasing your question.';
      }
      
      return text;
    } catch (e) {
      print('Gemini sendMessage error: $e');
      final errorStr = e.toString().toLowerCase();
      
      if (errorStr.contains('429') || errorStr.contains('quota')) {
        return 'Rate limit exceeded. Please wait a moment before sending another message.';
      } else if (errorStr.contains('403') || errorStr.contains('401')) {
        return 'API key error. Please verify your Gemini API key in the .env file.';
      } else if (errorStr.contains('finish_reason: safety')) {
        return 'I cannot answer this due to safety guidelines. Please ask something else related to maternal or infant care.';
      } else if (errorStr.contains('network') || errorStr.contains('socket')) {
        return 'Network error. Please check your internet connection and try again.';
      }
      
      // Reset session on other errors in case it's corrupted
      _chatSession = null;
      return 'Sorry, I encountered an error: ${e.toString().split(':').last.trim()}';
    }
  }

  void clearSession() {
    _chatSession = null;
  }
}
