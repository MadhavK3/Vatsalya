import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/data/repositories/iot_repository.dart';
import 'package:maternal_infant_care/data/models/iot_device_model.dart';
import 'package:maternal_infant_care/data/models/iot_alert_model.dart';
import 'package:maternal_infant_care/core/utils/notification_service.dart';

final iotRepositoryProvider = Provider<IoTRepository>((ref) {
  return IoTRepository();
});

final iotDevicesProvider = FutureProvider<List<IoTDeviceModel>>((ref) async {
  final repo = ref.watch(iotRepositoryProvider);
  await repo.init();
  return repo.getDevices();
});

final iotAlertsProvider = FutureProvider<List<IoTAlertModel>>((ref) async {
  final repo = ref.watch(iotRepositoryProvider);
  // Ensure init is called via devices provider or check initialization
  // For simplicity assuming repo is initialized when accessing via UI that uses devices
  return repo.getAlerts();
});

// Stream or StateNotifier for real-time updates could be added here
// For now, we will use a StateNotifier to simulate updates

class IoTDeviceNotifier extends StateNotifier<AsyncValue<List<IoTDeviceModel>>> {
  final IoTRepository _repo;

  IoTDeviceNotifier(this._repo) : super(const AsyncValue.loading()) {
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    state = const AsyncValue.loading();
    try {
      await _repo.init();
      final devices = _repo.getDevices();
      state = AsyncValue.data(devices);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    final devices = _repo.getDevices();
    state = AsyncValue.data(devices);
  }

  Future<void> toggleConnection(String id) async {
    await _repo.toggleDeviceConnection(id);
    await refresh();
  }

  Future<void> updateSensorData(String id, Map<String, dynamic> data) async {
    await _repo.updateSensorData(id, data);
    await refresh();
  }
}

final iotControllerProvider = StateNotifierProvider<IoTDeviceNotifier, AsyncValue<List<IoTDeviceModel>>>((ref) {
  final repo = ref.watch(iotRepositoryProvider);
  return IoTDeviceNotifier(repo);
});
