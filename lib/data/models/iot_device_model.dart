import 'package:hive/hive.dart';

part 'iot_device_model.g.dart';

@HiveType(typeId: 40)
class IoTDeviceModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String deviceType; // 'monitor', 'sensor', 'mat', 'bottle', 'wearable'

  @HiveField(3)
  bool isConnected;

  @HiveField(4)
  int batteryLevel;

  @HiveField(5)
  DateTime lastSync;

  @HiveField(6)
  Map<String, dynamic> sensorData;

  @HiveField(7)
  bool isOnline;

  IoTDeviceModel({
    required this.id,
    required this.name,
    required this.deviceType,
    this.isConnected = false,
    this.batteryLevel = 100,
    required this.lastSync,
    this.sensorData = const {},
    this.isOnline = true,
  });

  IoTDeviceModel copyWith({
    String? id,
    String? name,
    String? deviceType,
    bool? isConnected,
    int? batteryLevel,
    DateTime? lastSync,
    Map<String, dynamic>? sensorData,
    bool? isOnline,
  }) {
    return IoTDeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceType: deviceType ?? this.deviceType,
      isConnected: isConnected ?? this.isConnected,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      lastSync: lastSync ?? this.lastSync,
      sensorData: sensorData ?? this.sensorData,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
