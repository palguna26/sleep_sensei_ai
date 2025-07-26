class SleepSession {
  final String id;
  final DateTime start;
  final DateTime end;
  final String source; // local or google_fit

  SleepSession({
    required this.id,
    required this.start,
    required this.end,
    required this.source,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'source': source,
  };

  factory SleepSession.fromMap(Map<String, dynamic> map) => SleepSession(
    id: map['id'],
    start: DateTime.parse(map['start']),
    end: DateTime.parse(map['end']),
    source: map['source'] ?? 'local',
  );

  Duration get duration => end.difference(start);
}
