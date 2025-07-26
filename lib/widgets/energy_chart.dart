import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class EnergyChart extends StatelessWidget {
  const EnergyChart({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final wakeTime = now.subtract(const Duration(hours: 6)); // example wake time

    List<FlSpot> energyCurve = List.generate(24, (hour) {
      double x = hour.toDouble();
      double y = 0.5 + 0.4 * sin((2 * pi * (x - wakeTime.hour)) / 24);
      y = double.parse(y.clamp(0, 1).toStringAsFixed(2));
      return FlSpot(x, y);
    });

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 1,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(),
            topTitles: AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, _) => Text('${val.toInt()}h'),
              ),
            ),
            rightTitles: AxisTitles(),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: energyCurve,
              isCurved: true,
              color: Theme.of(context).colorScheme.primary,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            )
          ],
          lineTouchData: LineTouchData(enabled: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }
}
