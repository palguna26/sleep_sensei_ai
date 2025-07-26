import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user_profile.dart';

class SleepDataCollectionScreen extends StatefulWidget {
  const SleepDataCollectionScreen({super.key});

  @override
  State<SleepDataCollectionScreen> createState() => _SleepDataCollectionScreenState();
}

class _SleepDataCollectionScreenState extends State<SleepDataCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay? weekdaySleepTime;
  TimeOfDay? weekdayWakeTime;
  TimeOfDay? weekendSleepTime;
  TimeOfDay? weekendWakeTime;
  String? weekdayProductivity;
  String? weekendProductivity;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final profile = auth.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Sleep Data Collection'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Tell us about your typical sleep habits', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildTimePicker('Weekday Sleep Time', weekdaySleepTime, (val) => setState(() => weekdaySleepTime = val)),
              _buildTimePicker('Weekday Wake Time', weekdayWakeTime, (val) => setState(() => weekdayWakeTime = val)),
              _buildDropdown('Weekday Productivity', (val) => setState(() => weekdayProductivity = val)),
              const SizedBox(height: 16),
              _buildTimePicker('Weekend Sleep Time', weekendSleepTime, (val) => setState(() => weekendSleepTime = val)),
              _buildTimePicker('Weekend Wake Time', weekendWakeTime, (val) => setState(() => weekendWakeTime = val)),
              _buildDropdown('Weekend Productivity', (val) => setState(() => weekendProductivity = val)),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading ? const CircularProgressIndicator() : const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? value, void Function(TimeOfDay) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final picked = await showTimePicker(context: context, initialTime: value ?? TimeOfDay(hour: 23, minute: 0));
          if (picked != null) onChanged(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(labelText: label),
          child: Text(value != null ? value.format(context) : 'Select time', style: TextStyle(color: value != null ? null : Colors.grey)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, void Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label),
        items: const [
          DropdownMenuItem(value: 'Low', child: Text('Low')),
          DropdownMenuItem(value: 'Medium', child: Text('Medium')),
          DropdownMenuItem(value: 'High', child: Text('High')),
        ],
        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        onChanged: onChanged,
      ),
    );
  }

  void _submit() async {
    if (weekdaySleepTime == null || weekdayWakeTime == null || weekendSleepTime == null || weekendWakeTime == null || weekdayProductivity == null || weekendProductivity == null) {
      setState(() { _errorMessage = 'Please fill all fields.'; });
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final oldProfile = auth.profile;
      if (oldProfile == null) throw Exception('Profile not found');
      final updated = UserProfile(
        uid: oldProfile.uid,
        name: oldProfile.name,
        phone: oldProfile.phone,
        dob: oldProfile.dob,
        occupation: oldProfile.occupation,
        chronotype: oldProfile.chronotype,
        weekdaySleepTime: weekdaySleepTime!.format(context),
        weekdayWakeTime: weekdayWakeTime!.format(context),
        weekendSleepTime: weekendSleepTime!.format(context),
        weekendWakeTime: weekendWakeTime!.format(context),
        weekdayProductivity: weekdayProductivity,
        weekendProductivity: weekendProductivity,
      );
      await auth.saveProfile(updated);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/permissions');
      }
    } catch (e) {
      setState(() { _errorMessage = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
  }
} 