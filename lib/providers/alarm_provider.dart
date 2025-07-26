import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alarm_settings.dart';
import '../services/alarm_service.dart';

class AlarmProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _service = AlarmService();

  AlarmSettings? alarmSettings;
  String? _uid;

  Future<void> init(String uid) async {
    _uid = uid;
    await loadAlarm();
  }

  Future<void> loadAlarm() async {
    final doc = await _firestore.doc('users/$_uid/settings/alarm').get();
    alarmSettings = doc.exists
        ? AlarmSettings.fromMap(doc.data()!)
        : AlarmSettings(start: const TimeOfDay(hour: 7, minute: 0), end: const TimeOfDay(hour: 7, minute: 30), enabled: false);

    if (alarmSettings!.enabled) {
      await _service.scheduleAlarm(alarmSettings!.start, alarmSettings!.end);
    }

    notifyListeners();
  }

  Future<void> updateAlarm(AlarmSettings newSettings) async {
    alarmSettings = newSettings;
    notifyListeners();

    await _firestore.doc('users/$_uid/settings/alarm').set(newSettings.toMap());

    if (newSettings.enabled) {
      await _service.scheduleAlarm(newSettings.start, newSettings.end);
    } else {
      await _service.cancelAlarm();
    }
  }
}
