import 'package:health/health.dart';
import 'package:flutter/foundation.dart';

class HealthService {
  // Use Health() to get an instance
  final Health _health = Health();

  Future<bool> requestPermissions() async {
    final types = [HealthDataType.SLEEP_ASLEEP];
    // Permissions are now defined directly as HealthDataAccess enums
    final permissions = [HealthDataAccess.READ];

    // hasPermissions is now a static method on Health()
    bool? hasPermissions = await Health().hasPermissions(types, permissions: permissions);

    // It's good practice to handle the null case explicitly
    if (hasPermissions == null || !hasPermissions) {
      // requestAuthorization is called on the instance
      return await _health.requestAuthorization(types, permissions: permissions);
    }
    return true;
  }

  Future<List<HealthDataPoint>> fetchSleepData(DateTime start, DateTime end) async {
    final types = [HealthDataType.SLEEP_ASLEEP];

    try {
      // getHealthDataFromTypes is called on the instance with named parameters
      List<HealthDataPoint> data = await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: types,
      );

      // removeDuplicates is also a static method on Health()
      return Health().removeDuplicates(data);
    } catch (e) {
      debugPrint("Error fetching sleep data: $e");
      return [];
    }
  }
}
