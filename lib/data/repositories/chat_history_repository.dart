import 'package:hive_flutter/hive_flutter.dart';
import 'package:maternal_infant_care/core/constants/app_constants.dart';
import 'package:maternal_infant_care/data/models/chat_session_model.dart';

class ChatHistoryRepository {
  late Box<ChatSessionModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<ChatSessionModel>(AppConstants.chatHistoryBox);
  }

  List<ChatSessionModel> getSessions() {
    final sessions = _box.values.toList();
    // Sort by lastUpdated desc
    sessions.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    return sessions;
  }

  ChatSessionModel? getSession(String id) {
    return _box.get(id);
  }

  Future<void> saveSession(ChatSessionModel session) async {
    await _box.put(session.id, session);
  }

  Future<void> deleteSession(String id) async {
    await _box.delete(id);
  }
}
