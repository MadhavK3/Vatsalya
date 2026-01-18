import 'package:hive/hive.dart';

part 'growth_model.g.dart';

@HiveType(typeId: 3)
class GrowthModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final double weight;

  @HiveField(3)
  final double height;

  @HiveField(4)
  final double headCircumference;

  @HiveField(5)
  final int ageInDays;

  @HiveField(6)
  final String? notes;

  GrowthModel({
    required this.id,
    required this.timestamp,
    required this.weight,
    required this.height,
    required this.headCircumference,
    required this.ageInDays,
    this.notes,
  });

  GrowthModel copyWith({
    String? id,
    DateTime? timestamp,
    double? weight,
    double? height,
    double? headCircumference,
    int? ageInDays,
    String? notes,
  }) {
    return GrowthModel(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      headCircumference: headCircumference ?? this.headCircumference,
      ageInDays: ageInDays ?? this.ageInDays,
      notes: notes ?? this.notes,
    );
  }
}
