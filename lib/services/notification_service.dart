import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);
  }

  static Future<void> scheduleDeadlineReminder({
    required int id,
    required String company,
    required String role,
    required DateTime deadline,
  }) async {
    final scheduledDate = tz.TZDateTime.from(
      deadline.subtract(const Duration(days: 1)),
      tz.local,
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notifications.zonedSchedule(
      id,
      'Follow-up Reminder',
      'Follow up with $company for $role tomorrow!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'deadline_channel',
          'Deadline Reminders',
          channelDescription: 'Reminders for job application deadlines',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
