import 'package:hive/hive.dart';

part 'vaccination_model.g.dart';

@HiveType(typeId: 4)
class VaccinationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime scheduledDate;

  @HiveField(3)
  final DateTime? administeredDate;

  @HiveField(4)
  final bool isCompleted;

  @HiveField(5)
  final String? batchNumber;

  @HiveField(6)
  final String? doctorName;

  @HiveField(7)
  final String? location;

  @HiveField(8)
  final int ageInDays;

  @HiveField(9)
  final String? notes;

  VaccinationModel({
    required this.id,
    required this.name,
    required this.scheduledDate,
    this.administeredDate,
    this.isCompleted = false,
    this.batchNumber,
    this.doctorName,
    this.location,
    required this.ageInDays,
    this.notes,
  });

  VaccinationModel copyWith({
    String? id,
    String? name,
    DateTime? scheduledDate,
    DateTime? administeredDate,
    bool? isCompleted,
    String? batchNumber,
    String? doctorName,
    String? location,
    int? ageInDays,
    String? notes,
  }) {
    return VaccinationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      administeredDate: administeredDate ?? this.administeredDate,
      isCompleted: isCompleted ?? this.isCompleted,
      batchNumber: batchNumber ?? this.batchNumber,
      doctorName: doctorName ?? this.doctorName,
      location: location ?? this.location,
      ageInDays: ageInDays ?? this.ageInDays,
      notes: notes ?? this.notes,
    );
  }

  int get daysUntilDue {
    if (isCompleted) return 0;
    
    // Normalize both dates to midnight to get accurate day difference
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final due = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
    
    return due.difference(today).inDays;
  }
}
