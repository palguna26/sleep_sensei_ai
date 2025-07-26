import 'dart:math';
import 'package:fl_chart/fl_chart.dart';

/// EnergyModel encapsulates logic for predicting user energy levels
/// based on sleep debt and circadian rhythm.
class EnergyModel {
  final double idealSleepHours;
  final double maxDebt;

  /// [idealSleepHours] is the target sleep per night (default 8h)
  /// [maxDebt] is the maximum sleep debt considered (default 16h)
  EnergyModel({this.idealSleepHours = 8.0, this.maxDebt = 16.0});

  /// Calculates total sleep debt over the last 7 days
  double calculateSleepDebt(List<double> last7DaysSleep) {
    double debt = 0;
    for (final hours in last7DaysSleep) {
      debt += (idealSleepHours - hours);
    }
    return debt.clamp(0, maxDebt);
  }

  /// Circadian energy curve (sinusoidal, peak at 10am, dip at 3pm)
  double circadianEnergyLevel(DateTime time, {double phaseShift = 0}) {
    double hour = time.hour + time.minute / 60.0;
    // phaseShift allows for chronotype adjustment
    return 0.5 * sin((hour - 10 + phaseShift) * pi / 12) + 0.5;
  }

  /// Combines circadian and sleep debt for final energy prediction
  double predictedEnergy(DateTime time, double sleepDebt, {double phaseShift = 0}) {
    double circadian = circadianEnergyLevel(time, phaseShift: phaseShift);
    double debtFactor = max(0, 1 - (sleepDebt / maxDebt));
    return circadian * debtFactor;
  }

  /// Generates a 24-hour energy curve for charting
  List<FlSpot> generateEnergyCurve(double sleepDebt, {double phaseShift = 0}) {
    return List.generate(24, (i) {
      DateTime t = DateTime.now().copyWith(hour: i, minute: 0);
      return FlSpot(i.toDouble(), predictedEnergy(t, sleepDebt, phaseShift: phaseShift));
    });
  }
} 