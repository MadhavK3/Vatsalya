import 'dart:convert';
import 'package:http/http.dart' as http;

class AiRepository {
  final String _apiKey;
  // Using the v1 endpoint for gemini-pro-1.0 as requested
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  AiRepository({required String apiKey}) : _apiKey = apiKey;

  Future<String> sendMessage(String message) async {
    try {
      final url = Uri.parse('$_baseUrl?key=$_apiKey');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": message}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Parsing: candidates[0].content.parts[0].text
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          
          return data['candidates'][0]['content']['parts'][0]['text'] ?? 'No text response.';
        }
        return 'Empty response from AI.';
      } else {
        return 'Error request failed: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  void clearSession() {
    // Stateless HTTP implementation: no session to clear on the server side
    // The provider manages the local message history.
  }
}
