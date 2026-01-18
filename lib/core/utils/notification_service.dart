import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    print('🔔 NOTIFICATION DEBUG: Starting Initialization...');
    try {
      // 1. Initialize Timezones
      tz_data.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
        print('🔔 NOTIFICATION DEBUG: Timezone set to Asia/Kolkata');
      } catch (e) {
        tz.setLocalLocation(tz.getLocation('UTC'));
        print('🔔 NOTIFICATION DEBUG: Timezone fallback to UTC. Error: $e');
      }
      
      // 2. Settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // 3. Initialize Plugin
      final result = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          print('🔔 NOTIFICATION DEBUG: Notification tapped. Payload: ${details.payload}');
        },
      );
      print('🔔 NOTIFICATION DEBUG: Plugin .initialize result: $result');

      // 4. Create Channel (Android Only)
      const androidChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'Urgent Alerts',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        print('🔔 NOTIFICATION DEBUG: Android Plugin found. Creating channel and checking permissions...');
        await androidPlugin.createNotificationChannel(androidChannel);
        
        // Check for Android 13+ permission specifically
        final isGranted = await androidPlugin.requestNotificationsPermission();
        print('🔔 NOTIFICATION DEBUG: Post-Android 13 notification permission: $isGranted');
        
        // Check for Exact Alarm permission (Android 12+)
        try {
          final exactAlarm = await androidPlugin.requestExactAlarmsPermission();
          print('🔔 NOTIFICATION DEBUG: Exact Alarm permission: $exactAlarm');
        } catch (e) {
          print('🔔 NOTIFICATION DEBUG: Exact Alarm check threw error (possibly older ANDROID): $e');
        }
      } else {
        print('🔔 NOTIFICATION DEBUG: Android Plugin was NULL (expected on non-Android platforms)');
      }
      
      print('🔔 NOTIFICATION DEBUG: Initialization Finished Successfully');
    } catch (e, stack) {
      print('❌ NOTIFICATION ERROR during Initialization: $e');
      print('❌ STACK TRACE: $stack');
    }
  }

  static Future<bool> requestPermission() async {
    print('🔔 NOTIFICATION DEBUG: Manually requesting permission...');
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        print('🔔 NOTIFICATION DEBUG: Manual permission result: $granted');
        return granted ?? false;
      }
    } catch (e) {
      print('❌ NOTIFICATION ERROR requesting permission: $e');
    }
    return true;
  }

  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? channelId,
  }) async {
    print('🔔 NOTIFICATION DEBUG: showInstantNotification called. ID: $id TITLE: $title');
    try {
      final androidDetails = AndroidNotificationDetails(
        channelId ?? 'high_importance_channel',
        'Urgent Alerts',
        channelDescription: 'Important alerts',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails();
      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _notifications.show(id, title, body, details);
      print('🔔 NOTIFICATION DEBUG: .show() command sent to system');
    } catch (e) {
      print('❌ NOTIFICATION ERROR during showInstant: $e');
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? channelId,
  }) async {
    print('🔔 NOTIFICATION DEBUG: scheduleNotification called. Date: $scheduledDate');
    try {
      if (scheduledDate.isBefore(DateTime.now())) {
        print('🔔 NOTIFICATION DEBUG: Date is in past, shifting 5 seconds forward');
        scheduledDate = DateTime.now().add(const Duration(seconds: 5));
      }

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId ?? 'high_importance_channel',
            'Urgent Alerts',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
      print('🔔 NOTIFICATION DEBUG: .zonedSchedule() command sent to system');
    } catch (e) {
      print('❌ NOTIFICATION ERROR during schedule: $e');
    }
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? channelId,
  }) async {
    await showInstantNotification(id: id, title: title, body: body, channelId: channelId);
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      print('❌ NOTIFICATION ERROR fetching pending: $e');
      return [];
    }
  }

  static Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (e) {
      print('❌ NOTIFICATION ERROR during cancel: $e');
    }
  }

  static Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      print('❌ NOTIFICATION ERROR during cancelAll: $e');
    }
  }
}
