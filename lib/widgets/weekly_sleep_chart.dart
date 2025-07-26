import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class WeeklySleepChart extends StatelessWidget {
  final List<double> sleepHours;
  final List<String> dayLabels;

  const WeeklySleepChart({
    super.key,
    required this.sleepHours,
    required this.dayLabels,
  });

  @override
  Widget build(BuildContext context) {
    final maxSleep = sleepHours.isEmpty ? 10.0 : sleepHours.reduce((a, b) => a > b ? a : b).clamp(8.0, 12.0);
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxSleep,
        minY: 0,
        barTouchData: BarTouchData(
          enabled: true,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < dayLabels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dayLabels[value.toInt()],
                      style: TextStyle(
                        color: AppTheme.mediumGray,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 2,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}h',
                  style: TextStyle(
                    color: AppTheme.mediumGray,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppTheme.lightGray),
        ),
        barGroups: List.generate(
          sleepHours.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: sleepHours[index],
                color: _getBarColor(sleepHours[index]),
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppTheme.lightGray.withValues(alpha: 0.3),
              strokeWidth: 1,
            );
          },
        ),
      ),
    );
  }

  Color _getBarColor(double sleepHours) {
    if (sleepHours >= 7.0 && sleepHours <= 9.0) {
      return Colors.green; // Optimal sleep
    } else if (sleepHours >= 6.0 && sleepHours < 7.0) {
      return Colors.orange; // Moderate sleep
    } else if (sleepHours >= 9.0 && sleepHours <= 10.0) {
      return Colors.blue; // Long sleep
    } else {
      return Colors.red; // Too little or too much sleep
    }
  }
} 