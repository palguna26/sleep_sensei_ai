import 'package:flutter/material.dart';
import 'package:sleep_sensei_ai/screens/auth/onboarding_screen.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

import '../screens/dashboard/dashboard_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/winddown/winddown_screen.dart';
import '../screens/alarm/alarm_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/auth/permissions_screen.dart';
import '../screens/sleep_data_collection_screen.dart';
import '../screens/manual_sleep_log_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return _fade(const LoginScreen());
      case '/register':
        return _fade(const RegisterScreen());
      case '/dashboard':
        return _fade(const DashboardScreen());
      case '/chat':
        return _fade(const ChatScreen());
      case '/winddown':
        return _fade(const WindDownScreen());
      case '/alarm':
        return _fade(const AlarmScreen());
      case '/settings':
        return _fade(const SettingsScreen());
      case '/permissions':
        return _fade(const PermissionsScreen());
      case '/sleep_data_collection':
        return _fade(const SleepDataCollectionScreen());
      case '/manual_sleep_log':
        return _fade(const ManualSleepLogScreen());
      default:
        return _fade(const DashboardScreen());
    }
  }

  static PageRouteBuilder _fade(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
