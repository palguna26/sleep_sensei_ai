import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'routes/app_routes.dart';

import 'providers/auth_provider.dart';
import 'providers/sleep_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/health_provider.dart';
import 'providers/alarm_provider.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/permissions_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/sleep_data_collection_screen.dart';
import 'screens/auth/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // If .env file doesn't exist, continue without it
    debugPrint("No .env file found, using default configuration");
  }
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SleepSenseiApp());
}

class SleepSenseiApp extends StatelessWidget {
  const SleepSenseiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SleepProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => AlarmProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sleep Sensei AI',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        onGenerateRoute: AppRoutes.generateRoute,
        home: const RootRouter(),
      ),
    );
  }
}

/// Handles initial auth state routing
class RootRouter extends StatelessWidget {
  const RootRouter({super.key});

  bool _hasSleepData(userProfile) {
    return userProfile?.weekdaySleepTime != null &&
           userProfile?.weekdayWakeTime != null &&
           userProfile?.weekendSleepTime != null &&
           userProfile?.weekendWakeTime != null &&
           userProfile?.weekdayProductivity != null &&
           userProfile?.weekendProductivity != null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (auth.user == null) {
      return const LoginScreen();
    }

    // If profile missing, show onboarding
    if (auth.profile == null) {
      return const OnboardingScreen();
    }

    // If sleep data missing, show sleep data collection
    if (!_hasSleepData(auth.profile)) {
      return const SleepDataCollectionScreen();
    }

    // Check permissions before dashboard
    return FutureBuilder<bool>(
      future: PermissionsScreen.allGranted(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.data!) {
          return const PermissionsScreen();
        }
        return const DashboardScreen();
      },
    );
  }
}
