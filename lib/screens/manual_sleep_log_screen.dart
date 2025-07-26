import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sleep_provider.dart';
import '../providers/auth_provider.dart';
import '../models/sleep_session.dart';

class ManualSleepLogScreen extends StatefulWidget {
  const ManualSleepLogScreen({super.key});

  @override
  State<ManualSleepLogScreen> createState() => _ManualSleepLogScreenState();
}

class _ManualSleepLogScreenState extends State<ManualSleepLogScreen> {
  DateTime _sleepDate = DateTime.now();
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Sleep Log'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Log Your Sleep Session',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the details of your sleep session to track your sleep patterns.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Sleep Date
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Sleep Date'),
                subtitle: Text(
                  '${_sleepDate.day}/${_sleepDate.month}/${_sleepDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _selectDate(context),
              ),
            ),
            const SizedBox(height: 16),
            
            // Sleep Time
            Card(
              child: ListTile(
                leading: const Icon(Icons.bedtime),
                title: const Text('Sleep Time'),
                subtitle: Text(
                  _sleepTime.format(context),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _selectTime(context, true),
              ),
            ),
            const SizedBox(height: 16),
            
            // Wake Time
            Card(
              child: ListTile(
                leading: const Icon(Icons.wb_sunny),
                title: const Text('Wake Time'),
                subtitle: Text(
                  _wakeTime.format(context),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () => _selectTime(context, false),
              ),
            ),
            const SizedBox(height: 24),
            
            // Duration Display
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Sleep Duration',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _calculateDuration(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Log Button
            ElevatedButton(
              onPressed: _isLoading ? null : _logSleepSession,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Log Sleep Session',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            
            // Quick Log Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => _quickLog(7),
                    icon: const Icon(Icons.bed),
                    label: const Text('7h'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => _quickLog(8),
                    icon: const Icon(Icons.bed),
                    label: const Text('8h'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => _quickLog(9),
                    icon: const Icon(Icons.bed),
                    label: const Text('9h'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _sleepDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _sleepDate) {
      setState(() {
        _sleepDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isSleepTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isSleepTime ? _sleepTime : _wakeTime,
    );
    if (picked != null) {
      setState(() {
        if (isSleepTime) {
          _sleepTime = picked;
        } else {
          _wakeTime = picked;
        }
      });
    }
  }

  String _calculateDuration() {
    final sleepDateTime = DateTime(
      _sleepDate.year,
      _sleepDate.month,
      _sleepDate.day,
      _sleepTime.hour,
      _sleepTime.minute,
    );
    
    // If wake time is before sleep time, assume it's the next day
    DateTime wakeDateTime = DateTime(
      _sleepDate.year,
      _sleepDate.month,
      _sleepDate.day,
      _wakeTime.hour,
      _wakeTime.minute,
    );
    
    if (wakeDateTime.isBefore(sleepDateTime)) {
      wakeDateTime = wakeDateTime.add(const Duration(days: 1));
    }
    
    final duration = wakeDateTime.difference(sleepDateTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    return '${hours}h ${minutes}m';
  }

  void _quickLog(int hours) {
    final now = DateTime.now();
    setState(() {
      _sleepDate = now.subtract(Duration(hours: hours + 1));
      _sleepTime = TimeOfDay(hour: now.hour - hours - 1, minute: 0);
      _wakeTime = TimeOfDay(hour: now.hour - 1, minute: 0);
    });
  }

  Future<void> _logSleepSession() async {
    // Validate times
    final sleepDateTime = DateTime(
      _sleepDate.year,
      _sleepDate.month,
      _sleepDate.day,
      _sleepTime.hour,
      _sleepTime.minute,
    );
    
    DateTime wakeDateTime = DateTime(
      _sleepDate.year,
      _sleepDate.month,
      _sleepDate.day,
      _wakeTime.hour,
      _wakeTime.minute,
    );
    
    if (wakeDateTime.isBefore(sleepDateTime)) {
      wakeDateTime = wakeDateTime.add(const Duration(days: 1));
    }
    
    // Validate duration (between 1 hour and 24 hours)
    final duration = wakeDateTime.difference(sleepDateTime);
    if (duration.inHours < 1 || duration.inHours > 24) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid sleep duration (1-24 hours)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Validate that sleep time is not in the future
    if (sleepDateTime.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sleep time cannot be in the future'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final sleepProvider = Provider.of<SleepProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      if (authProvider.user == null) {
        throw Exception('User not authenticated');
      }

      // Create sleep session
      final session = SleepSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        start: sleepDateTime,
        end: wakeDateTime,
        source: 'manual',
      );

      // Add to Firestore
      await sleepProvider.addManualSession(session);
      
      // Refresh sessions and recalculate metrics
      await sleepProvider.fetchSleepSessions();
      
      // Load ML models for predictions
      await sleepProvider.loadMLModels();

      if (mounted) {
        // Show success message with sleep insights
        _showSleepInsights(sleepProvider, duration);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging sleep session: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSleepInsights(SleepProvider sleepProvider, Duration sleepDuration) {
    final sleepDebt = sleepProvider.sleepDebt;
    final debtHours = sleepDebt.inHours.abs();
    final isInDebt = sleepDebt.isNegative;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              ),
              const SizedBox(width: 8),
              const Text('Sleep Logged!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sleep Duration: ${sleepDuration.inHours}h ${sleepDuration.inMinutes % 60}m',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isInDebt ? Colors.orange.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isInDebt ? Colors.orange.shade200 : Colors.green.shade200,
                  ),
                ),
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
              const SizedBox(height: 12),
              const Text(
                'Your energy predictions have been updated based on this sleep session.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to settings
              },
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pushReplacementNamed('/dashboard'); // Go to dashboard
              },
              child: const Text('View Dashboard'),
            ),
          ],
        );
      },
    );
  }
} 