import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sleep_session.dart';
import '../theme/app_theme.dart';

class SessionTile extends StatelessWidget {
  final SleepSession session;

  const SessionTile({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM d, h:mm a');
    final duration = session.end.difference(session.start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
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
                    '${formatter.format(session.start)} → ${formatter.format(session.end)}',
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
