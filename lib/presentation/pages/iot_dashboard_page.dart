import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/presentation/viewmodels/iot_providers.dart';
import 'package:maternal_infant_care/presentation/widgets/environment_panel_widget.dart';
import 'package:maternal_infant_care/presentation/widgets/iot_device_card.dart';
import 'package:maternal_infant_care/presentation/widgets/iot_alert_tile.dart';
import 'package:maternal_infant_care/data/models/iot_device_model.dart';
import 'package:maternal_infant_care/data/models/iot_alert_model.dart';

class IoTDashboardPage extends ConsumerStatefulWidget {
  const IoTDashboardPage({super.key});

  @override
  ConsumerState<IoTDashboardPage> createState() => _IoTDashboardPageState();
}

class _IoTDashboardPageState extends ConsumerState<IoTDashboardPage> {
  @override
  Widget build(BuildContext context) {
    final devicesAsync = ref.watch(iotControllerProvider);
    final alertsAsync = ref.watch(iotAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Nursery'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Scanning for new devices...')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Environment Panel
            devicesAsync.when(
              data: (devices) {
                final sensor = devices.firstWhere(
                  (d) => d.deviceType == 'sensor',
                  orElse: () => IoTDeviceModel(
                      id: 'dummy',
                      name: 'dummy',
                      deviceType: 'sensor',
                      lastSync: DateTime.now(),
                      sensorData: {'temperature': 22.0, 'humidity': 45.0, 'aqi': 0}),
                );
                return EnvironmentPanelWidget(
                  temperature: (sensor.sensorData['temperature'] as num?)?.toDouble() ?? 0.0,
                  humidity: (sensor.sensorData['humidity'] as num?)?.toDouble() ?? 0.0,
                  aqi: (sensor.sensorData['aqi'] as num?)?.toInt() ?? 0,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 24),
            
            // 2. Devices Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Connected Devices',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    // Refresh
                    ref.read(iotControllerProvider.notifier).refresh();
                  }, 
                  child: const Text('Refresh')
                ),
              ],
            ),
            const SizedBox(height: 8),
            devicesAsync.when(
              data: (devices) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  return IoTDeviceCard(
                    device: devices[index],
                    onTap: () {
                       _showDeviceDetails(context, devices[index], ref);
                    },
                  );
                },
              ),
              loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
            
            const SizedBox(height: 32),
            
            // 3. Recent Alerts
            Text(
              'Recent Alerts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            alertsAsync.when(
              data: (alerts) {
                if (alerts.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: Text('No recent alerts')),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    return IoTAlertTile(
                      alert: alerts[index],
                      onTap: () {
                        // Mark as read
                        ref.read(iotRepositoryProvider).markAlertAsRead(alerts[index].id);
                        setState(() {}); 
                      },
                    );
                  },
                );
              },
               loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  void _showDeviceDetails(BuildContext context, IoTDeviceModel device, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    device.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Switch(
                    value: device.isConnected, 
                    onChanged: (val) {
                      Navigator.pop(context);
                      ref.read(iotControllerProvider.notifier).toggleConnection(device.id);
                    }
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Battery: ${device.batteryLevel}%'),
              const Divider(height: 32),
              Text('Sensor Data:', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...device.sensorData.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(e.value.toString()),
                  ],
                ),
              )),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
