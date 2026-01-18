import 'package:hive/hive.dart';

part 'medical_record_model.g.dart';

@HiveType(typeId: 5)
class MedicalRecordModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String type;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final String? doctorName;

  @HiveField(6)
  final String? location;

  @HiveField(7)
  final List<String> attachments;

  @HiveField(8)
  final String? notes;

  MedicalRecordModel({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
    required this.description,
    this.doctorName,
    this.location,
    List<String>? attachments,
    this.notes,
  }) : attachments = attachments ?? [];

  MedicalRecordModel copyWith({
    String? id,
    DateTime? date,
    String? type,
    String? title,
    String? description,
    String? doctorName,
    String? location,
    List<String>? attachments,
    String? notes,
  }) {
    return MedicalRecordModel(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      doctorName: doctorName ?? this.doctorName,
      location: location ?? this.location,
      attachments: attachments ?? this.attachments,
      notes: notes ?? this.notes,
    );
  }
}
