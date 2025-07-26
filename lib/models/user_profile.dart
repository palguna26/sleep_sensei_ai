class UserProfile {
  final String uid;
  final String name;
  final String phone;
  final DateTime dob;
  final String occupation;
  final String? chronotype; // 'early_bird', 'night_owl', 'intermediate'
  // Initial sleep data
  final String? weekdaySleepTime;
  final String? weekdayWakeTime;
  final String? weekendSleepTime;
  final String? weekendWakeTime;
  final String? weekdayProductivity;
  final String? weekendProductivity;

  UserProfile({
    required this.uid,
    required this.name,
    required this.phone,
    required this.dob,
    required this.occupation,
    this.chronotype,
    this.weekdaySleepTime,
    this.weekdayWakeTime,
    this.weekendSleepTime,
    this.weekendWakeTime,
    this.weekdayProductivity,
    this.weekendProductivity,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'name': name,
    'phone': phone,
    'dob': dob.toIso8601String(),
    'occupation': occupation,
    if (chronotype != null) 'chronotype': chronotype,
    if (weekdaySleepTime != null) 'weekdaySleepTime': weekdaySleepTime,
    if (weekdayWakeTime != null) 'weekdayWakeTime': weekdayWakeTime,
    if (weekendSleepTime != null) 'weekendSleepTime': weekendSleepTime,
    if (weekendWakeTime != null) 'weekendWakeTime': weekendWakeTime,
    if (weekdayProductivity != null) 'weekdayProductivity': weekdayProductivity,
    if (weekendProductivity != null) 'weekendProductivity': weekendProductivity,
  };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
    uid: map['uid'],
    name: map['name'],
    phone: map['phone'],
    dob: DateTime.parse(map['dob']),
    occupation: map['occupation'],
    chronotype: map['chronotype'],
    weekdaySleepTime: map['weekdaySleepTime'],
    weekdayWakeTime: map['weekdayWakeTime'],
    weekendSleepTime: map['weekendSleepTime'],
    weekendWakeTime: map['weekendWakeTime'],
    weekdayProductivity: map['weekdayProductivity'],
    weekendProductivity: map['weekendProductivity'],
  );
}
