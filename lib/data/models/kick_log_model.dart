import 'package:hive/hive.dart';

part 'kick_log_model.g.dart';

@HiveType(typeId: 21)
class KickLogModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime sessionStart;

  @HiveField(2)
  final DateTime sessionEnd;

  @HiveField(3)
  final int kickCount;

  @HiveField(4)
  final String? notes;

  KickLogModel({
    required this.id,
    required this.sessionStart,
    required this.sessionEnd,
    required this.kickCount,
    this.notes,
  });
}
