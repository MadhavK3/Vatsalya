import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    try {
      tz_data.initializeTimeZones();
      // Most reliable way to get a valid timezone location
      const String timeZoneName = 'Asia/Kolkata'; // Fallback to a known valid one
      try {
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (_) {
        tz.setLocalLocation(tz.getLocation('UTC'));
      }
    } catch (e) {
      print('Notification Service: Timezone initialization error: $e');
    }

    // Use the local icon we just created
    const androidSettings = AndroidInitializationSettings('notification_icon');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      final initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      print('Notification Service: Initialization result = $initialized');
      
      if (initialized == false) {
        print('Notification Service: Initialization failed (returned false)');
        return;
      }
    } catch (e) {
      print('Notification Service: Initialization Exception: $e');
      return;
    }

    try {
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
        'vatsalya_tips',
        'Daily Tips',
        description: 'Personalized health and parenting tips',
        importance: Importance.low,
      ));

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(const AndroidNotificationChannel(
        'vatsalya_alerts',
        'Vatsalya Alerts',
        description: 'Vital reminders for you and your baby',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      ));

      // Request permissions for Android 13+
      print('Notification Service: Requesting permissions...');
      final granted = await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      
      print('Notification Service: Permission granted = $granted');
    } catch (e) {
      print('Notification Service: Channel/Permission error = $e');
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {}

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String channelId = 'vatsalya_alerts',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == 'vatsalya_tips' ? 'Daily Tips' : 'Vatsalya Alerts',
      channelDescription: channelId == 'vatsalya_tips' 
          ? 'Personalized health and parenting tips' 
          : 'Vital reminders for you and your baby',
      importance: channelId == 'vatsalya_tips' ? Importance.low : Importance.max,
      priority: channelId == 'vatsalya_tips' ? Priority.low : Priority.high,
      icon: 'notification_icon',

    );

    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String channelId = 'vatsalya_alerts',
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == 'vatsalya_tips' ? 'Daily Tips' : 'Vatsalya Alerts',
      channelDescription: channelId == 'vatsalya_tips' 
          ? 'Personalized health and parenting tips' 
          : 'Vital reminders for you and your baby',
      importance: channelId == 'vatsalya_tips' ? Importance.low : Importance.max,
      priority: channelId == 'vatsalya_tips' ? Priority.low : Priority.high,
      icon: 'notification_icon',

    );

    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
