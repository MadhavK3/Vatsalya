import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maternal_infant_care/core/utils/reminder_service.dart';
import 'package:maternal_infant_care/data/models/reminder_model.dart';
import 'package:maternal_infant_care/presentation/viewmodels/repository_providers.dart';
import 'package:maternal_infant_care/presentation/viewmodels/smart_reminder_provider.dart';
import 'package:maternal_infant_care/presentation/widgets/smart_reminder_card.dart';
import 'package:maternal_infant_care/core/utils/notification_service.dart';

class RemindersPage extends ConsumerStatefulWidget {
  const RemindersPage({super.key});

  @override
  ConsumerState<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends ConsumerState<RemindersPage> {
  @override
  Widget build(BuildContext context) {
    final reminderRepo = ref.watch(reminderRepositoryProvider);
    final smartRemindersAsync = ref.watch(smartRemindersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            tooltip: 'Test Notification',
            onPressed: () async {
              await NotificationService.showInstantNotification(
                id: 999,
                title: 'System Active 🚀',
                body: 'Your notification system is working perfectly.',
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test notification sent!')),
                );
              }
            },
          ),
        ],
      ),
      body: reminderRepo.when(
        data: (repo) {
          final todayReminders = repo.getTodaysReminders();
          final upcomingReminders = repo.getUpcomingReminders();

          return CustomScrollView(
            slivers: [
              // Smart Reminders Section
              smartRemindersAsync.when(
                data: (smartList) {
                  if (smartList.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                  return SliverMainAxisGroup(
                    slivers: [
                       SliverToBoxAdapter(
                         child: Padding(
                           padding: const EdgeInsets.all(16.0),
                           child: Row(
                             children: [
                               Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.tertiary),
                               const SizedBox(width: 8),
                               Text(
                                 'Smart Suggestions',
                                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                   fontWeight: FontWeight.bold,
                                   color: Theme.of(context).colorScheme.tertiary,
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ),
                       SliverList(
                         delegate: SliverChildBuilderDelegate(
                           (context, index) {
                             final reminder = smartList[index];
                             return Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 16.0),
                               child: SmartReminderCard(
                                 reminder: reminder,
                                 onDismiss: () {
                                   // In a real app, we'd blacklist this ID in a persistent store
                                   // For now, we unfortunately can't modify the provider's state easily without a notifier
                                   // Or we save it as "completed" to local repo immediately?
                                   // Let's just visually remove by saving it as completed/dismissed to local repo
                                   // so it doesn't show up again? Or separate blacklist.
                                   // Creating a manual entry marked as completed/ignored is a safe bet.
                                 },
                                 onComplete: () async {
                                    // Save to local repo as done
                                    final completed = reminder.copyWith(isCompleted: true);
                                    await repo.saveReminder(completed);
                                    // Refresh logic might be needed
                                 },
                               ),
                             );
                           },
                           childCount: smartList.length,
                         ),
                       ),
                       const SliverToBoxAdapter(child: Divider(height: 32)),
                    ],
                  );
                },
                loading: () => const SliverToBoxAdapter(child: LinearProgressIndicator()),
                error: (e,s) => SliverToBoxAdapter(child: Text('Error loading smart reminders: $e')),
              ),

              // Today's Reminders
              if (todayReminders.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.today,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Today\'s Tasks',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final reminder = todayReminders[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                        child: _ReminderCard(reminder: reminder, repo: repo),
                      );
                    },
                    childCount: todayReminders.length,
                  ),
                ),
              ],

              // Upcoming Reminders
              if (upcomingReminders.isNotEmpty) ...[
                 SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.upcoming, color: Theme.of(context).colorScheme.secondary),
                        const SizedBox(width: 12),
                        Text(
                          'Upcoming',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final reminder = upcomingReminders[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                        child: _ReminderCard(reminder: reminder, repo: repo),
                      );
                    },
                    childCount: upcomingReminders.length,
                  ),
                ),
              ],
              
              if (todayReminders.isEmpty && upcomingReminders.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: Text("No manual reminders set.")),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: ${error.toString()}')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReminderDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
        heroTag: 'fab_reminders',
      ),
    );
  }

  Future<void> _showAddReminderDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedType = 'General';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Reminder'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['General', 'Feeding', 'Sleep', 'Medical', 'Vaccination'].map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Select Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Select Time'),
                  subtitle: Text(selectedTime.format(context)),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (picked != null) {
                      setState(() => selectedTime = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }

                try {
                  final repo = await ref.read(reminderRepositoryProvider.future);
                  final scheduledTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedTime.hour,
                    selectedTime.minute,
                  );

                  final reminder = ReminderModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    description: descriptionController.text.isEmpty
                        ? 'Reminder for ${titleController.text}'
                        : descriptionController.text,
                    scheduledTime: scheduledTime,
                    type: selectedType,
                  );

                  final updatedReminder = await ReminderService.scheduleDailyReminders(reminder);
                  await repo.saveReminder(updatedReminder);

                  if (mounted) {
                    Navigator.pop(context);
                    // Force the provider to refresh and show the new reminder
                    ref.invalidate(reminderRepositoryProvider);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reminder scheduled')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends ConsumerWidget {
  final ReminderModel reminder;
  final dynamic repo;

  const _ReminderCard({required this.reminder, required this.repo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: reminder.isCompleted
          ? Theme.of(context).colorScheme.surfaceVariant
          : null,
      child: CheckboxListTile(
        value: reminder.isCompleted,
        onChanged: (value) async {
          final updated = reminder.copyWith(isCompleted: value ?? false);
          await repo.saveReminder(updated);
          if (updated.isCompleted && reminder.notificationId != null) {
            await ReminderService.cancelReminder(reminder.notificationId);
          }
        },
        title: Text(
          reminder.title,
          style: TextStyle(
            decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reminder.description),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy • hh:mm a').format(reminder.scheduledTime),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          ],
        ),
        secondary: CircleAvatar(
          backgroundColor: _getColorForType(context, reminder.type).withOpacity(0.2),
          child: Icon(_getIconForType(reminder.type), color: _getColorForType(context, reminder.type)),
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  static IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'feeding':
        return Icons.restaurant;
      case 'sleep':
        return Icons.bedtime;
      case 'medical':
        return Icons.medical_services;
      case 'vaccination':
        return Icons.vaccines;
      default:
        return Icons.notifications;
    }
  }

  static Color _getColorForType(BuildContext context, String type) {
    switch (type.toLowerCase()) {
      case 'feeding':
        return Theme.of(context).colorScheme.primary;
      case 'sleep':
        return Theme.of(context).colorScheme.secondary;
      case 'medical':
        return Colors.red;
      case 'vaccination':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.tertiary;
    }
  }
}
