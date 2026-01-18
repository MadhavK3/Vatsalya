import 'package:hive/hive.dart';

part 'diaper_model.g.dart';

@HiveType(typeId: 7)
class DiaperModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String status; // 'Dry', 'Wet', 'Dirty', 'Both'

  @HiveField(3)
  final String? notes;

  DiaperModel({
    required this.id,
    required this.timestamp,
    required this.status,
    this.notes,
  });

  DiaperModel copyWith({
    String? id,
    DateTime? timestamp,
    String? status,
    String? notes,
  }) {
    return DiaperModel(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}
