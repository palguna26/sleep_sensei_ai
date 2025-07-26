import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/sleep_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/alarm_provider.dart';
import '../../widgets/session_tile.dart';
import '../../widgets/sleep_chart.dart';
import '../../widgets/sleep_insights_card.dart';
import '../../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      Provider.of<SleepProvider>(context, listen: false).init(auth.user!.uid);
      Provider.of<AlarmProvider>(context, listen: false).init(auth.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sleepProvider = Provider.of<SleepProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
              backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.bedtime, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            const Text('Sleep Sensei AI'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.alarm, color: AppTheme.primaryBlue),
            onPressed: () => Navigator.pushNamed(context, '/alarm'),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.primaryBlue),
            onPressed: () => Navigator.pushNamed(context, '/chat'),
          ),
          IconButton(
            icon: const Icon(Icons.music_note, color: AppTheme.primaryBlue),
            onPressed: () => Navigator.pushNamed(context, '/winddown'),
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.primaryBlue),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: sleepProvider.fetchSleepSessions,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildWelcomeCard(context),
            const SizedBox(height: 20),
            _buildSectionTitle(context, 'Sleep Insights'),
            SleepInsightsCard(sleepProvider: sleepProvider),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Sleep Status'),
            _buildStatusCard(sleepProvider),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Energy Curve'),
            SleepChart(energyCurve: sleepProvider.predictedEnergyCurve),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Recent Sleep Sessions'),
            ...sleepProvider.sessions.take(5).map((s) => SessionTile(session: s)),
            if (sleepProvider.sessions.length > 5)
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () {
                    // TODO: Navigate to detailed sessions view
                  },
                  child: Text('View All Sessions (${sleepProvider.sessions.length})'),
                ),
              ),
          ],
        ),
      ),

    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'How\'s your sleep journey today?',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.darkBlue,
        ),
      ),
    );
  }

  Widget _buildStatusCard(SleepProvider sleepProvider) {
    final isSleeping = sleepProvider.isSleeping;
    final sleepDebt = sleepProvider.sleepDebt;
    final debtHours = sleepDebt.inHours.abs();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSleeping ? AppTheme.softGreen : AppTheme.warmOrange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSleeping ? Icons.bedtime : Icons.wb_sunny,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSleeping ? 'Currently Sleeping' : 'Awake',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                      Text(
                        isSleeping ? 'Rest well! 💤' : 'Stay active! 😴',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mediumGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    'Sleep Debt',
                    '${debtHours}h',
                    debtHours > 2 ? AppTheme.warmOrange : AppTheme.softGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusItem(
                    'Ideal Sleep',
                    '${sleepProvider.idealSleep.inHours}h',
                    AppTheme.secondaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.mediumGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
