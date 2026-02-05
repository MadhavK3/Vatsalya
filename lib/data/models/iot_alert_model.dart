import 'package:hive/hive.dart';

part 'iot_alert_model.g.dart';

@HiveType(typeId: 41)
class IoTAlertModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String deviceId;

  @HiveField(2)
  final String alertType; // 'info', 'warning', 'critical'

  @HiveField(3)
  final String message;

  @HiveField(4)
  final DateTime timestamp;

  @HiveField(5)
  bool isRead;

  IoTAlertModel({
    required this.id,
    required this.deviceId,
    required this.alertType,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}
