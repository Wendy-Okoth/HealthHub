import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  tz.initializeTimeZones();

  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();

  const settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(settings);
}

Future<void> scheduleSleepReminder() async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Time to wind down 💤',
    'Log in your time and get ready to sleep',
    _next10PM(),
    NotificationDetails(
      android: AndroidNotificationDetails('sleep_channel', 'Sleep Reminders'),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

tz.TZDateTime _next10PM() {
  final now = tz.TZDateTime.now(tz.local);
  final scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 22);
  return scheduled.isBefore(now)
      ? scheduled.add(const Duration(days: 1))
      : scheduled;
}

