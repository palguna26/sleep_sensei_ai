import 'package:flutter/material.dart';

class AlarmSettings {
  final TimeOfDay start;
  final TimeOfDay end;
  final bool enabled;

  AlarmSettings({
    required this.start,
    required this.end,
    required this.enabled,
  });

  Map<String, dynamic> toMap() {
    return {
      'start': '${start.hour}:${start.minute}',
      'end': '${end.hour}:${end.minute}',
      'enabled': enabled,
    };
  }

  factory AlarmSettings.fromMap(Map<String, dynamic> map) {
    TimeOfDay parseTime(String str) {
      final parts = str.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    return AlarmSettings(
      start: parseTime(map['start'] ?? '07:00'),
      end: parseTime(map['end'] ?? '07:30'),
      enabled: map['enabled'] ?? false,
    );
  }
}
