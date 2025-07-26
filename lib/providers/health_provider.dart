import 'package:flutter/material.dart';

class HealthProvider extends ChangeNotifier {
  bool isFetching = false;

  Future<void> importSleepData() async {
    isFetching = true;
    notifyListeners();

    // Simulate importing health data
    await Future.delayed(const Duration(seconds: 2));

    isFetching = false;
    notifyListeners();
  }
}
