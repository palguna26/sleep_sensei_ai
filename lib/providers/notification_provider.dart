import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_settings.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  final _service = NotificationService();

  NotificationSettingsModel? settings;
  String? _uid;

  Future<void> init(String uid) async {
    _uid = uid;
    await _service.init();
    await loadSettings();
  }

  Future<void> loadSettings() async {
    final doc = await _firestore.doc('users/$_uid/settings/notifications').get();
    settings = doc.exists
        ? NotificationSettingsModel.fromMap(doc.data()!)
        : NotificationSettingsModel(
      dailyTipsEnabled: true,
      dailyTipTime: const TimeOfDay(hour: 21, minute: 0),
      circadianAlertsEnabled: true,
    );

    if (settings!.dailyTipsEnabled) {
      await _service.scheduleDailyTip(settings!.dailyTipTime);
    }

    notifyListeners();
  }

  Future<void> updateSettings(NotificationSettingsModel newSettings) async {
    settings = newSettings;
    notifyListeners();

    await _firestore.doc('users/$_uid/settings/notifications').set(settings!.toMap());
    await _service.cancelAll();

    if (settings!.dailyTipsEnabled) {
      await _service.scheduleDailyTip(settings!.dailyTipTime);
    }
  }
}
