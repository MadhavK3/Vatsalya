import 'package:hive_flutter/hive_flutter.dart';
import 'package:maternal_infant_care/core/constants/app_constants.dart';
import 'package:maternal_infant_care/data/models/reminder_model.dart';

class ReminderRepository {
  late Box<ReminderModel> _box;

  Future<void> init() async {
    _box = await Hive.openBox<ReminderModel>(AppConstants.reminderBox);
  }

  Future<void> saveReminder(ReminderModel reminder) async {
    await _box.put(reminder.id, reminder);
  }

  List<ReminderModel> getAllReminders() {
    return _box.values.toList()..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  List<ReminderModel> getUpcomingReminders() {
    final now = DateTime.now();
    return _box.values
        .where((r) => !r.isCompleted && r.scheduledTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  List<ReminderModel> getTodaysReminders() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _box.values
        .where((r) =>
            !r.isCompleted &&
            r.scheduledTime.isAfter(startOfDay) &&
            r.scheduledTime.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  List<ReminderModel> getRemindersByType(String type) {
    return _box.values
        .where((r) => r.type.toLowerCase() == type.toLowerCase() && !r.isCompleted)
        .toList()
      ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  Future<void> deleteReminder(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
