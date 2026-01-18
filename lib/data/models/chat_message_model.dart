import 'package:hive_flutter/hive_flutter.dart';

part 'chat_message_model.g.dart';

@HiveType(typeId: 30) // Using a new range for chat
class ChatMessageModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String text;
  
  @HiveField(2)
  final bool isUser;
  
  @HiveField(3)
  final DateTime timestamp;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
