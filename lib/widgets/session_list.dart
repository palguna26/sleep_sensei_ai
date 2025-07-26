import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class SessionList extends StatelessWidget {
  const SessionList({super.key});

  @override
  Widget build(BuildContext context) {
    final sessions = Provider.of<SleepProvider>(context).sessions;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "Last 7 Sessions",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.darkBlue,
            ),
          ),
        ),
        ...sessions.take(7).map((session) {
          final df = DateFormat('MMM d, h:mm a');
          final hours = session.duration.inHours;
          final minutes = session.duration.inMinutes % 60;
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.bedtime,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${df.format(session.start)} → ${df.format(session.end)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Duration: ${hours}h ${minutes}m',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.mediumGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getQualityColor(hours).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getQualityText(hours),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getQualityColor(hours),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Color _getQualityColor(int hours) {
    if (hours >= 7 && hours <= 9) return AppTheme.softGreen;
    if (hours >= 6 && hours <= 10) return AppTheme.warmOrange;
    return AppTheme.accentPurple;
  }

  String _getQualityText(int hours) {
    if (hours >= 7 && hours <= 9) return 'Optimal';
    if (hours >= 6 && hours <= 10) return 'Good';
    return 'Short';
  }
}
