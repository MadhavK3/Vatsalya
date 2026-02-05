import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:maternal_infant_care/core/constants/app_constants.dart';
import 'package:maternal_infant_care/data/models/iot_device_model.dart';
import 'package:maternal_infant_care/data/models/iot_alert_model.dart';
import 'package:maternal_infant_care/data/models/iot_reading_model.dart';
import 'dart:math';

class IoTRepository {
  late Box<IoTDeviceModel> _devicesBox;
  late Box<IoTAlertModel> _alertsBox;
  late Box<IoTReadingModel> _readingsBox;

  Future<void> init() async {
    _devicesBox = await Hive.openBox<IoTDeviceModel>(AppConstants.iotDevicesBox);
    _alertsBox = await Hive.openBox<IoTAlertModel>(AppConstants.iotAlertsBox);
    _readingsBox = await Hive.openBox<IoTReadingModel>(AppConstants.iotReadingsBox);
  }

  // --- Devices ---

  List<IoTDeviceModel> getDevices() {
    final devices = _devicesBox.values.toList();
    if (devices.isEmpty) {
      _seedDevices();
      return _devicesBox.values.toList();
    }
    return devices;
  }

  Future<void> addDevice(IoTDeviceModel device) async {
    await _devicesBox.put(device.id, device);
  }

  Future<void> toggleDeviceConnection(String id) async {
    final device = _devicesBox.get(id);
    if (device != null) {
      device.isConnected = !device.isConnected;
      await device.save();
    }
  }

  Future<void> updateSensorData(String id, Map<String, dynamic> data) async {
    final device = _devicesBox.get(id);
    if (device != null) {
      final updatedData = Map<String, dynamic>.from(device.sensorData)..addAll(data);
      final updatedDevice = device.copyWith(
        sensorData: updatedData, 
        lastSync: DateTime.now(),
        isConnected: true
      );
      await _devicesBox.put(id, updatedDevice);
    }
  }

  // --- Alerts ---

  List<IoTAlertModel> getAlerts() {
    final alerts = _alertsBox.values.toList();
    alerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return alerts;
  }

  Future<void> addAlert(IoTAlertModel alert) async {
    await _alertsBox.put(alert.id, alert);
  }

  Future<void> markAlertAsRead(String id) async {
    final alert = _alertsBox.get(id);
    if (alert != null) {
      alert.isRead = true;
      await alert.save();
    }
  }

  // --- Readings ---

  List<IoTReadingModel> getReadings(String deviceId) {
    return _readingsBox.values
        .where((r) => r.deviceId == deviceId)
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> addReading(IoTReadingModel reading) async {
    await _readingsBox.add(reading);
  }

  // --- Seeding ---

  void _seedDevices() {
    final now = DateTime.now();
    
    final devices = [
      IoTDeviceModel(
        id: 'cam_01',
        name: 'Nursery Cam',
        deviceType: 'monitor',
        isConnected: true,
        lastSync: now,
        sensorData: {'isCryDetected': false, 'temperature': 24.5},
      ),
      IoTDeviceModel(
        id: 'env_01',
        name: 'Room Sensor',
        deviceType: 'sensor',
        isConnected: true,
        lastSync: now,
        sensorData: {'temperature': 22.0, 'humidity': 45.0, 'aqi': 12},
      ),
      IoTDeviceModel(
        id: 'mat_01',
        name: 'Dream Mat',
        deviceType: 'mat',
        isConnected: true,
        lastSync: now,
        sensorData: {'status': 'Sleeping', 'breathingRate': 24},
      ),
      IoTDeviceModel(
        id: 'bottle_01',
        name: 'Smart Bottle',
        deviceType: 'bottle',
        isConnected: false,
        lastSync: now.subtract(const Duration(hours: 2)),
        sensorData: {'lastFeedVol': 120, 'temperature': 37.0},
      ),
       IoTDeviceModel(
        id: 'band_01',
        name: 'Baby Band',
        deviceType: 'wearable',
        isConnected: true,
        lastSync: now,
        sensorData: {'heartRate': 110, 'bodyTemp': 36.6, 'steps': 150},
      ),
      IoTDeviceModel(
        id: 'crib_01',
        name: 'Smart Crib',
        deviceType: 'crib_alarm',
        isConnected: true,
        lastSync: now,
        sensorData: {'position': 'Safe', 'proximity': 'In Crib'},
      ),
    ];

    for (var device in devices) {
      _devicesBox.put(device.id, device);
    }
  }
}
