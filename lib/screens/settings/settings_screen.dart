import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../models/user_profile.dart';
import '../../models/sleep_session.dart';
import '../settings/notification_settings_screen.dart';
import '../../widgets/sleep_chart.dart';
import '../../widgets/weekly_sleep_chart.dart';
import '../../theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _occupationController;
  late String? _chronotype;
  late DateTime? _dob;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<AuthProvider>(context, listen: false).profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _occupationController = TextEditingController(text: profile?.occupation ?? '');
    _chronotype = profile?.chronotype;
    _dob = profile?.dob;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;
    if (user == null) return;
    final profile = UserProfile(
      uid: user.uid,
      name: _nameController.text,
      phone: _phoneController.text,
      dob: _dob!,
      occupation: _occupationController.text,
      chronotype: _chronotype,
    );
    await auth.saveProfile(profile);
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!')));
  }

  void _logout() async {
    await Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<AuthProvider>(context).profile;
    final sleepProvider = Provider.of<SleepProvider>(context);
    final sessions = sleepProvider.sessions;
    
    // Prepare weekly sleep data with proper date labels
    final now = DateTime.now();
    final week = List.generate(7, (i) => now.subtract(Duration(days: 6 - i))); // Last 7 days, oldest to newest
    
    // Create day labels (Mon, Tue, etc.)
    final dayLabels = week.map((date) {
      final weekday = date.weekday;
      switch (weekday) {
        case 1: return 'Mon';
        case 2: return 'Tue';
        case 3: return 'Wed';
        case 4: return 'Thu';
        case 5: return 'Fri';
        case 6: return 'Sat';
        case 7: return 'Sun';
        default: return 'Mon';
      }
    }).toList();
    
    // Get sleep hours for each day
    final sleepHours = week.map((date) {
      // Find sessions that started on this date
      final daySessions = sessions.where((session) {
        final sessionDate = DateTime(session.start.year, session.start.month, session.start.day);
        final targetDate = DateTime(date.year, date.month, date.day);
        return sessionDate.isAtSameMomentAs(targetDate);
      }).toList();
      
      if (daySessions.isEmpty) {
        return 0.0; // No sleep logged for this day
      }
      
      // Sum up all sleep sessions for this day
      final totalSleepMinutes = daySessions.fold<int>(
        0, 
        (total, session) => total + session.duration.inMinutes
      );
      
      return totalSleepMinutes / 60.0; // Convert to hours
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(_editing ? Icons.check : Icons.edit),
                        onPressed: () {
                          if (_editing) _saveProfile();
                          setState(() => _editing = !_editing);
                        },
                      ),
                    ],
                  ),
                  TextField(
                    controller: _nameController,
                    enabled: _editing,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: _phoneController,
                    enabled: _editing,
                    decoration: const InputDecoration(labelText: 'Phone'),
                  ),
                  TextField(
                    controller: _occupationController,
                    enabled: _editing,
                    decoration: const InputDecoration(labelText: 'Occupation'),
                  ),
                  ListTile(
                    title: const Text('Date of Birth'),
                    subtitle: Text(_dob != null ? _dob!.toLocal().toString().split(' ')[0] : 'Not set'),
                    onTap: _editing
                        ? () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _dob ?? DateTime(2000),
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) setState(() => _dob = picked);
                          }
                        : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _chronotype,
                    items: const [
                      DropdownMenuItem(value: 'early_bird', child: Text('Early Bird')),
                      DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                      DropdownMenuItem(value: 'night_owl', child: Text('Night Owl')),
                    ],
                    onChanged: _editing ? (val) => setState(() => _chronotype = val) : null,
                    decoration: const InputDecoration(labelText: 'Chronotype'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Weekly Sleep Data Bar Graph
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart, color: AppTheme.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      const Text('Sleep This Week', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hours of sleep per day',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.mediumGray,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: WeeklySleepChart(
                      sleepHours: sleepHours,
                      dayLabels: dayLabels,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem('Optimal', Colors.green),
                      _buildLegendItem('Moderate', Colors.orange),
                      _buildLegendItem('Long', Colors.blue),
                      _buildLegendItem('Poor', Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Notification Settings
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
            ),
          ),
          const SizedBox(height: 16),
          // Manual Sleep Log
          ListTile(
            leading: const Icon(Icons.bedtime),
            title: const Text('Manual Sleep Log'),
            subtitle: const Text('Log sleep sessions manually'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, '/manual_sleep_log'),
          ),
          const SizedBox(height: 24),
          // Logout
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.mediumGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
} 