import 'package:hive/hive.dart';

part 'pregnancy_model.g.dart';

@HiveType(typeId: 0)
class PregnancyModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime dueDate;

  @HiveField(2)
  final DateTime lastPeriodDate;

  @HiveField(3)
  final int currentMonth;

  @HiveField(4)
  final Map<int, bool> monthlyChecklists;

  @HiveField(5)
  final List<String> completedTests;

  @HiveField(6)
  final List<String> riskSymptoms;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  PregnancyModel({
    required this.id,
    required this.dueDate,
    required this.lastPeriodDate,
    required this.currentMonth,
    Map<int, bool>? monthlyChecklists,
    List<String>? completedTests,
    List<String>? riskSymptoms,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : monthlyChecklists = monthlyChecklists ?? {},
        completedTests = completedTests ?? [],
        riskSymptoms = riskSymptoms ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  PregnancyModel copyWith({
    String? id,
    DateTime? dueDate,
    DateTime? lastPeriodDate,
    int? currentMonth,
    Map<int, bool>? monthlyChecklists,
    List<String>? completedTests,
    List<String>? riskSymptoms,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PregnancyModel(
      id: id ?? this.id,
      dueDate: dueDate ?? this.dueDate,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      currentMonth: currentMonth ?? this.currentMonth,
      monthlyChecklists: monthlyChecklists ?? this.monthlyChecklists,
      completedTests: completedTests ?? this.completedTests,
      riskSymptoms: riskSymptoms ?? this.riskSymptoms,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  int get weeksPregnant {
    final now = DateTime.now();
    final difference = now.difference(lastPeriodDate).inDays;
    return (difference / 7).floor();
  }

  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }
}
