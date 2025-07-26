import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/alarm_settings.dart';
import '../../providers/alarm_provider.dart';

class AlarmScreen extends StatefulWidget {
  const AlarmScreen({super.key});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  late TimeOfDay from;
  late TimeOfDay to;
  late bool enabled;

  @override
  void initState() {
    super.initState();
    final alarm = Provider.of<AlarmProvider>(context, listen: false).alarmSettings!;
    from = alarm.start;
    to = alarm.end;
    enabled = alarm.enabled;
  }

  void _save() {
    final provider = Provider.of<AlarmProvider>(context, listen: false);
    provider.updateAlarm(AlarmSettings(start: from, end: to, enabled: enabled));
    Navigator.pop(context);
  }

  Future<void> _pickTime(bool isFrom) async {
    final picked = await showTimePicker(context: context, initialTime: isFrom ? from : to);
    if (picked != null) {
      setState(() {
        if (isFrom) {
          from = picked;
        } else {
          to = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Alarm')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              value: enabled,
              onChanged: (val) => setState(() => enabled = val),
              title: const Text("Enable Smart Alarm"),
            ),
            ListTile(
              title: const Text("Wake Window Start"),
              subtitle: Text(from.format(context)),
              onTap: () => _pickTime(true),
            ),
            ListTile(
              title: const Text("Wake Window End"),
              subtitle: Text(to.format(context)),
              onTap: () => _pickTime(false),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Save Alarm"),
              onPressed: _save,
            )
          ],
        ),
      ),
    );
  }
}
