import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maternal_infant_care/data/models/reminder_model.dart';

class SmartReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback onDismiss;
  final VoidCallback onComplete;

  const SmartReminderCard({
    super.key,
    required this.reminder,
    required this.onDismiss,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.primaryContainer.withOpacity(0.3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                     decoration: BoxDecoration(
                       color: colorScheme.primary,
                       borderRadius: BorderRadius.circular(8),
                     ),
                     child: const Row(
                       children: [
                         Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                         SizedBox(width: 4),
                         Text(
                           'SMART',
                           style: TextStyle(
                             color: Colors.white,
                             fontSize: 10,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                       ],
                     ),
                   ),
                   const Spacer(),
                   if (reminder.sourceType != null)
                      Text(
                        _getSourceLabel(reminder.sourceType!),
                        style: TextStyle(
                          fontSize: 10,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: _getColorForType(context, reminder.type).withOpacity(0.2),
                    foregroundColor: _getColorForType(context, reminder.type),
                    child: Icon(_getIconForType(reminder.type)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reminder.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 14, color: colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('hh:mm a').format(reminder.scheduledTime),
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: onDismiss,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurfaceVariant,
                      side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Dismiss'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Done'),
                    style: FilledButton.styleFrom(
                       visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSourceLabel(String source) {
    switch (source) {
      case 'kick_monitor': return 'Based on Pregnancy Week';
      case 'feeding_schedule': return 'Based on Routine';
      case 'general_wellness': return 'Wellness Tip';
      default: return 'Smart Suggestion';
    }
  }

  static IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'feeding': return Icons.restaurant;
      case 'sleep': return Icons.bedtime;
      case 'medical': return Icons.medical_services;
      case 'vaccination': return Icons.vaccines;
      default: return Icons.notifications_active;
    }
  }

  static Color _getColorForType(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'feeding': return Colors.green;
      case 'sleep': return Colors.indigo;
      case 'medical': return Colors.red;
      case 'vaccination': return Colors.orange;
      default: return Theme.of(context).colorScheme.primary;
    }
  }
}
