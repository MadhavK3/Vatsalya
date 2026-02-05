import 'package:hive/hive.dart';

part 'iot_reading_model.g.dart';

@HiveType(typeId: 42)
class IoTReadingModel extends HiveObject {
  @HiveField(0)
  final String deviceId;

  @HiveField(1)
  final String readingType; // 'temperature', 'humidity', 'heart_rate', 'sleep_quality'

  @HiveField(2)
  final double value;

  @HiveField(3)
  final String unit;

  @HiveField(4)
  final DateTime timestamp;

  IoTReadingModel({
    required this.deviceId,
    required this.readingType,
    required this.value,
    required this.unit,
    required this.timestamp,
  });
}
