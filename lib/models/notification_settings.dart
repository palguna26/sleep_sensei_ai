import 'package:flutter/material.dart';

class NotificationSettingsModel {
  final bool dailyTipsEnabled;
  final TimeOfDay dailyTipTime;
  final bool circadianAlertsEnabled;

  NotificationSettingsModel({
    required this.dailyTipsEnabled,
    required this.dailyTipTime,
    required this.circadianAlertsEnabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'dailyTipsEnabled': dailyTipsEnabled,
      'dailyTipTime': '${dailyTipTime.hour}:${dailyTipTime.minute}',
      'circadianAlertsEnabled': circadianAlertsEnabled,
    };
  }

  factory NotificationSettingsModel.fromMap(Map<String, dynamic> map) {
    final parts = (map['dailyTipTime'] ?? '21:00').split(':');
    return NotificationSettingsModel(
      dailyTipsEnabled: map['dailyTipsEnabled'] ?? true,
      dailyTipTime: TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1])),
      circadianAlertsEnabled: map['circadianAlertsEnabled'] ?? true,
    );
  }

  NotificationSettingsModel copyWith({
    bool? dailyTipsEnabled,
    TimeOfDay? dailyTipTime,
    bool? circadianAlertsEnabled,
  }) {
    return NotificationSettingsModel(
      dailyTipsEnabled: dailyTipsEnabled ?? this.dailyTipsEnabled,
      dailyTipTime: dailyTipTime ?? this.dailyTipTime,
      circadianAlertsEnabled: circadianAlertsEnabled ?? this.circadianAlertsEnabled,
    );
  }
}
