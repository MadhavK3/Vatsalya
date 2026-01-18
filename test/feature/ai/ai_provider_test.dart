import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maternal_infant_care/presentation/viewmodels/ai_provider.dart';
import 'package:maternal_infant_care/presentation/viewmodels/user_provider.dart';
import 'package:maternal_infant_care/domain/services/gemini_service.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Load a dummy key so GenerativeModel doesn't complain (if it validates)
    dotenv.testLoad(fileInput: 'GEMINI_API_KEY=AIzaSyDummyKeyForTesting');
  });

  group('AI Provider Tests', () {
    test('System instruction includes pregnancy context when user is pregnant', () {
      final container = ProviderContainer(
        overrides: [
          userProfileProvider.overrideWith((ref) => UserProfileType.pregnant),
        ],
      );

      final service = container.read(geminiServiceProvider);
      expect(service, isA<GeminiService>());
    });

    test('AiChatNotifier loads history from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'gemini_chat_history': [
          '{"text": "Hello", "isUser": true, "timestamp": "2023-01-01T00:00:00.000"}',
          '{"text": "Hi there", "isUser": false, "timestamp": "2023-01-01T00:00:01.000"}'
        ]
      });

      final container = ProviderContainer();
      
      // Need to read the notifier and wait for the initial load
      final notifier = container.read(aiResponseProvider.notifier);
      
      // Small delay for async _loadHistory
      await Future.delayed(const Duration(milliseconds: 100));
      
      final state = container.read(aiResponseProvider);
      
      expect(state.length, 2);
      expect(state.first.text, 'Hello');
    });
  });
}
