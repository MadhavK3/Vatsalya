import 'package:hive_flutter/hive_flutter.dart';
import 'chat_message_model.dart';

part 'chat_session_model.g.dart';

@HiveType(typeId: 31)
class ChatSessionModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime lastUpdated;

  @HiveField(3)
  final List<ChatMessageModel> messages;

  ChatSessionModel({
    required this.id,
    required this.title,
    required this.lastUpdated,
    required this.messages,
  });
}
