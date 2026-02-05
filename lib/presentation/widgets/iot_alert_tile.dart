import 'package:flutter/material.dart';
import 'package:maternal_infant_care/data/models/iot_alert_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class IoTAlertTile extends StatelessWidget {
  final IoTAlertModel alert;
  final VoidCallback onTap;

  const IoTAlertTile({
    super.key,
    required this.alert,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (alert.alertType) {
      case 'critical':
        color = Colors.red;
        icon = Icons.warning;
        break;
      case 'warning':
        color = Colors.orange;
        icon = Icons.error_outline;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info_outline;
    }

    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        alert.message,
        style: TextStyle(
          fontWeight: alert.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(
        timeago.format(alert.timestamp),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: !alert.isRead 
          ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle))
          : null,
    );
  }
}
