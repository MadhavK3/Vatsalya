import 'package:hive/hive.dart';

part 'sleep_model.g.dart';

@HiveType(typeId: 2)
class SleepModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime startTime;

  @HiveField(2)
  final DateTime? endTime;

  @HiveField(3)
  final bool isActive;

  @HiveField(4)
  final String? notes;

  SleepModel({
    required this.id,
    required this.startTime,
    this.endTime,
    this.isActive = true,
    this.notes,
  });

  SleepModel copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    bool? isActive,
    String? notes,
  }) {
    return SleepModel(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }

  Duration get duration {
    if (endTime == null) {
      return DateTime.now().difference(startTime);
    }
    return endTime!.difference(startTime);
  }

  double get hours {
    return duration.inMinutes / 60;
  }
}
