import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../providers/sleep_provider.dart';

class SleepInsightsCard extends StatelessWidget {
  final SleepProvider sleepProvider;

  const SleepInsightsCard({super.key, required this.sleepProvider});

  @override
  Widget build(BuildContext context) {
    final sleepDebt = sleepProvider.sleepDebt;
    final debtHours = sleepDebt.inHours.abs();
    final isInDebt = sleepDebt.isNegative;
    final sessions = sleepProvider.sessions;
    
    // Calculate average sleep duration for the last 7 days
    final recentSessions = sessions.take(7).toList();
    final avgSleepHours = recentSessions.isEmpty 
        ? 0.0 
        : recentSessions.map((s) => s.duration.inHours.toDouble()).reduce((a, b) => a + b) / recentSessions.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Sleep Insights',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Sleep Debt Status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isInDebt ? Colors.orange.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isInDebt ? Colors.orange.shade200 : Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isInDebt ? Icons.warning : Icons.check_circle,
                    color: isInDebt ? Colors.orange.shade700 : Colors.green.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sleep Debt: ${debtHours}h',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isInDebt ? Colors.orange.shade800 : Colors.green.shade800,
                          ),
                        ),
                        Text(
                          isInDebt 
                            ? 'You need more sleep to catch up'
                            : 'Great! You\'re well-rested',
                          style: TextStyle(
                            fontSize: 14,
                            color: isInDebt ? Colors.orange.shade700 : Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Average Sleep Duration
            Row(
              children: [
                Expanded(
                  child: _buildInsightItem(
                    'Avg Sleep',
                    '${avgSleepHours.toStringAsFixed(1)}h',
                    Icons.bedtime,
                    avgSleepHours >= 7.0 ? Colors.green : Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInsightItem(
                    'Sessions',
                    '${recentSessions.length}',
                    Icons.history,
                    AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Energy Prediction Summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Today\'s Energy Prediction',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getEnergyPredictionText(sleepProvider.predictedEnergyCurve),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Recommendations
            if (isInDebt || avgSleepHours < 7.0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Recommendations',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getRecommendations(isInDebt, avgSleepHours),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _getEnergyPredictionText(List<FlSpot> energyCurve) {
    if (energyCurve.isEmpty) return 'No energy data available';
    
    // Find peak energy time
    final peakIndex = energyCurve.indexWhere((spot) => 
      spot.y == energyCurve.map((s) => s.y).reduce((a, b) => a > b ? a : b)
    );
    
    if (peakIndex != -1) {
      final peakHour = energyCurve[peakIndex].x.toInt();
      final peakEnergy = (energyCurve[peakIndex].y * 100).toInt();
      
      return 'Peak energy at ${peakHour}:00 (${peakEnergy}%). Best time for important tasks.';
    }
    
    return 'Energy levels calculated based on your sleep patterns.';
  }

  String _getRecommendations(bool isInDebt, double avgSleepHours) {
    final recommendations = <String>[];
    
    if (isInDebt) {
      recommendations.add('• Try to get extra sleep tonight');
      recommendations.add('• Consider a short nap (20-30 min)');
    }
    
    if (avgSleepHours < 7.0) {
      recommendations.add('• Aim for 7-9 hours of sleep');
      recommendations.add('• Establish a consistent bedtime');
    }
    
    if (recommendations.isEmpty) {
      return 'Great sleep habits! Keep it up.';
    }
    
    return recommendations.join('\n');
  }
} 