import 'package:hive/hive.dart';

part 'milestone_model.g.dart';

@HiveType(typeId: 23)
class MilestoneModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String category; // motor, cognitive, social, language

  @HiveField(3)
  final int ageMonthsMin;

  @HiveField(4)
  final int ageMonthsMax;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  DateTime? completedDate;
  
  @HiveField(7)
  String? description;

  MilestoneModel({
    required this.id,
    required this.title,
    required this.category,
    required this.ageMonthsMin,
    required this.ageMonthsMax,
    this.isCompleted = false,
    this.completedDate,
    this.description,
  });
}
