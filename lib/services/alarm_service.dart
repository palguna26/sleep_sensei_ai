import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:math';

class AlarmService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  AlarmService() {
    _init();
  }

  Future<void> _init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notifications.initialize(const InitializationSettings(android: android));
    tz.initializeTimeZones();
  }

  Future<void> scheduleAlarm(TimeOfDay from, TimeOfDay to) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, from.hour, from.minute);
    final end = DateTime(now.year, now.month, now.day, to.hour, to.minute);

    final window = end.difference(start).inMinutes;
    final offset = Random().nextInt(window); // simulate lightest sleep
    final triggerTime = tz.TZDateTime.from(start.add(Duration(minutes: offset)), tz.local);

    const android = AndroidNotificationDetails(
      'alarm_channel', 'Smart Alarm',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('stop', 'Stop'),
        AndroidNotificationAction('snooze', 'Snooze'),
      ],
    );

    await _notifications.zonedSchedule(
      5,
      'Wake Up!',
      'Rise and shine 🌅',
      triggerTime,
      const NotificationDetails(android: android),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAlarm() async {
    await _notifications.cancel(5);
  }
}
