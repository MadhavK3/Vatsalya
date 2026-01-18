import 'package:intl/intl.dart';
import 'package:maternal_infant_care/core/constants/app_constants.dart';
import 'package:maternal_infant_care/core/utils/notification_service.dart';
import 'package:maternal_infant_care/data/models/reminder_model.dart';
import 'package:maternal_infant_care/data/models/vaccination_model.dart';
import 'package:maternal_infant_care/data/models/pregnancy_model.dart';

class ReminderService {
  static int _notificationIdCounter = 1000;

  static int _getNextNotificationId() {
    _notificationIdCounter++;
    if (_notificationIdCounter > AppConstants.maxNotificationId) {
      _notificationIdCounter = 1000;
    }
    return _notificationIdCounter;
  }

  static Future<ReminderModel> schedulePregnancyReminder(
    PregnancyModel pregnancy,
    ReminderModel reminder,
  ) async {
    final notificationId = _getNextNotificationId();
    final updatedReminder = reminder.copyWith(notificationId: notificationId);

    await NotificationService.scheduleNotification(
      id: notificationId,
      title: reminder.title,
      body: reminder.description,
      scheduledDate: reminder.scheduledTime,
    );

    return updatedReminder;
  }

  static Future<void> scheduleVaccinationReminder(
    VaccinationModel vaccination,
  ) async {
    if (vaccination.isCompleted) return;

    final daysUntilDue = vaccination.daysUntilDue;
    final reminderDates = <DateTime>[];

    if (daysUntilDue >= 7) {
      reminderDates.add(vaccination.scheduledDate.subtract(const Duration(days: 7)));
    }
    if (daysUntilDue >= 5) {
      reminderDates.add(vaccination.scheduledDate.subtract(const Duration(days: 5)));
    }
    if (daysUntilDue >= 3) {
      reminderDates.add(vaccination.scheduledDate.subtract(const Duration(days: 3)));
    }
    if (daysUntilDue >= 1) {
      reminderDates.add(vaccination.scheduledDate.subtract(const Duration(days: 1)));
    }
    reminderDates.add(vaccination.scheduledDate);

    for (var date in reminderDates) {
      // Create a date at 9 AM for the reminder
      final reminderTime = DateTime(date.year, date.month, date.day, 9, 0);
      
      if (reminderTime.isAfter(DateTime.now())) {
        final notificationId = _getNextNotificationId();
        final daysLeft = vaccination.scheduledDate.difference(reminderTime).inDays + 1;
        
        String bodyText;
        if (daysLeft == 0) {
          bodyText = 'Your vaccine ${vaccination.name} is due TODAY!';
        } else if (daysLeft == 1) {
          bodyText = 'Your vaccination ${vaccination.name} is due in next day';
        } else {
          bodyText = '${vaccination.name} is due in $daysLeft days (${DateFormat('dd/MM/yyyy').format(vaccination.scheduledDate)})';
        }

        await NotificationService.scheduleNotification(
          id: notificationId,
          title: 'Vaccination Reminder',
          body: bodyText,
          scheduledDate: reminderTime,
        );
      }
    }
  }

  static Future<void> scheduleFeedingReminder({
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now();
    var reminderTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (reminderTime.isBefore(now)) {
      reminderTime = reminderTime.add(const Duration(days: 1));
    }

    final notificationId = _getNextNotificationId();
    await NotificationService.scheduleNotification(
      id: notificationId,
      title: 'Feeding Reminder',
      body: 'Time for feeding',
      scheduledDate: reminderTime,
    );
  }

  static Future<void> scheduleSleepReminder({
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now();
    var reminderTime = DateTime(now.year, now.month, now.day, hour, minute);

    if (reminderTime.isBefore(now)) {
      reminderTime = reminderTime.add(const Duration(days: 1));
    }

    final notificationId = _getNextNotificationId();
    await NotificationService.scheduleNotification(
      id: notificationId,
      title: 'Sleep Time Reminder',
      body: 'Time for bedtime routine',
      scheduledDate: reminderTime,
    );
  }

  static Future<ReminderModel> scheduleDailyReminders(ReminderModel reminder) async {
    final now = DateTime.now();
    var reminderTime = DateTime(
      now.year,
      now.month,
      now.day,
      reminder.scheduledTime.hour,
      reminder.scheduledTime.minute,
    );

    if (reminderTime.isBefore(now)) {
      reminderTime = reminderTime.add(const Duration(days: 1));
    }

    final notificationId = _getNextNotificationId();
    final updatedReminder = reminder.copyWith(notificationId: notificationId);

    await NotificationService.scheduleNotification(
      id: notificationId,
      title: reminder.title,
      body: reminder.description,
      scheduledDate: reminderTime,
    );

    return updatedReminder;
  }

  static Future<void> cancelReminder(int? notificationId) async {
    if (notificationId != null) {
      await NotificationService.cancelNotification(notificationId);
    }
  }
}
