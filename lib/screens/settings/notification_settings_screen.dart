import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_settings.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      if (auth.user != null) {
        provider.init(auth.user!.uid).then((_) {
          setState(() {
            _initialized = true;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final settings = provider.settings;
        if (!_initialized || settings == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(title: const Text("Notification Settings")),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SwitchListTile(
                  value: settings.dailyTipsEnabled,
                  onChanged: (val) {
                    provider.updateSettings(settings.copyWith(dailyTipsEnabled: val));
                  },
                  title: const Text("Daily AI Sleep Tips"),
                ),
                ListTile(
                  title: const Text("Tip Time"),
                  subtitle: Text(settings.dailyTipTime.format(context)),
                  onTap: () async {
                    final picked = await showTimePicker(context: context, initialTime: settings.dailyTipTime);
                    if (picked != null) {
                      provider.updateSettings(settings.copyWith(dailyTipTime: picked));
                    }
                  },
                ),
                SwitchListTile(
                  value: settings.circadianAlertsEnabled,
                  onChanged: (val) {
                    provider.updateSettings(settings.copyWith(circadianAlertsEnabled: val));
                  },
                  title: const Text("Circadian Energy Alerts"),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Save Settings"),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
