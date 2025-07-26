import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);

    await _plugin.initialize(initSettings);
    tz.initializeTimeZones();
  }

  Future<void> showNow(String title, String body) async {
    const android = AndroidNotificationDetails('default_channel', 'General');
    const details = NotificationDetails(android: android);
    await _plugin.show(0, title, body, details);
  }

  Future<void> scheduleDailyTip(TimeOfDay time) async {
    final tzTime = tz.TZDateTime.local(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      time.hour,
      time.minute,
    ).add(const Duration(days: 1));

    await _plugin.zonedSchedule(
      1,
      'Sleep Tip',
      'Time to wind down 💤',
      tzTime,
      const NotificationDetails(
        android: AndroidNotificationDetails('tips_channel', 'Daily Tips'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
