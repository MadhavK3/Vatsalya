import 'package:hive/hive.dart';

part 'feeding_model.g.dart';

@HiveType(typeId: 1)
class FeedingModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final double quantity;

  @HiveField(4)
  final String unit;

  @HiveField(5)
  final int durationMinutes;

  @HiveField(6)
  final String? notes;

  FeedingModel({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.quantity,
    this.unit = 'ml',
    this.durationMinutes = 0,
    this.notes,
  });

  FeedingModel copyWith({
    String? id,
    DateTime? timestamp,
    String? type,
    double? quantity,
    String? unit,
    int? durationMinutes,
    String? notes,
  }) {
    return FeedingModel(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      notes: notes ?? this.notes,
    );
  }
}
