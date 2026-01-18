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
    try {
      _chatSession ??= _model.startChat();
      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text ?? 'No response from AI.';
    } catch (e) {
      print('Gemini sendMessage error: $e');
      // Reset session on error in case it's corrupted
      _chatSession = null;
      return 'Sorry, I encountered an error. Please try again.';
    }
  }

  void clearSession() {
    _chatSession = null;
  }
}
