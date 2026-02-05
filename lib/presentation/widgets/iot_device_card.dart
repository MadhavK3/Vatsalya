import 'package:flutter/material.dart';
import 'package:maternal_infant_care/data/models/iot_device_model.dart';

class IoTDeviceCard extends StatelessWidget {
  final IoTDeviceModel device;
  final VoidCallback onTap;

  const IoTDeviceCard({
    super.key,
    required this.device,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOnline = device.isConnected;
    
    // Determine icon and color based on device type
    IconData icon;
    Color color;
    
    switch (device.deviceType) {
      case 'monitor':
        icon = Icons.videocam;
        color = Colors.blue;
        break;
      case 'sensor':
        icon = Icons.thermostat;
        color = Colors.orange;
        break;
      case 'mat':
        icon = Icons.bed;
        color = Colors.purple;
        break;
      case 'bottle':
        icon = Icons.local_drink;
        color = Colors.teal;
        break;
      case 'wearable':
        icon = Icons.watch;
        color = Colors.pink;
        break;
      case 'crib_alarm':
        icon = Icons.crib;
        color = Colors.indigo;
        break;
      default:
        icon = Icons.devices_other;
        color = Colors.grey;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isOnline ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: isOnline ? color : Colors.grey, size: 24),
                  ),
                  if (isOnline)
                    Icon(
                      device.batteryLevel > 20 ? Icons.battery_full : Icons.battery_alert,
                      size: 16,
                      color: device.batteryLevel > 20 ? Colors.green : Colors.red,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    device.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isOnline ? Colors.green : Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOnline ? 'Active' : 'Offline',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (isOnline && device.sensorData.isNotEmpty) ...[
                const Divider(height: 12),
                _buildQuickStat(context, device),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(BuildContext context, IoTDeviceModel device) {
    String text = '';
    
    if (device.deviceType == 'sensor') {
      text = '${device.sensorData['temperature']}°C';
    } else if (device.deviceType == 'monitor') {
      text = device.sensorData['isCryDetected'] == true ? 'Cry Detected!' : 'Quiet';
    } else if (device.deviceType == 'wearable') {
      text = '${device.sensorData['heartRate']} BPM';
    } else if (device.deviceType == 'bottle') {
      text = '${device.sensorData['lastFeedVol']}ml';
    } else {
      text = 'View Data';
    }

    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
