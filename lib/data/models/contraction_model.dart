import 'package:hive/hive.dart';

part 'contraction_model.g.dart';

@HiveType(typeId: 22)
class ContractionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  final DateTime endTime;

  @HiveField(3)
  final int durationSeconds;

  @HiveField(4)
  final int intervalSeconds; // Time since previous contraction started

  ContractionModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.intervalSeconds,
  });
  
  Duration get duration => Duration(seconds: durationSeconds);
  Duration get interval => Duration(seconds: intervalSeconds);
}
