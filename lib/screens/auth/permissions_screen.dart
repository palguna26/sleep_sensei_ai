import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../theme/app_theme.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  static Future<bool> allGranted() async {
    final required = [
      Permission.microphone,
      Permission.notification,
      Permission.sensors,
      Permission.activityRecognition,
      Permission.storage,
    ];
    for (final p in required) {
      if (await p.isGranted == false && await p.isDenied == false) {
        return false;
      }
    }
    return true;
  }

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  bool _isLoading = false;
  final Map<Permission, PermissionStatus> _permissionStatuses = {};

  // We'll dynamically determine required permissions based on Android version
  final List<Permission> _requiredPermissions = [
    Permission.microphone,
    Permission.notification,
    // Sensors/activityRecognition will be added in initState
  ];
  final List<Permission> _optionalPermissions = [];
  bool _storageRelevant = true;

  @override
  void initState() {
    super.initState();
    _initPermissions();
  }

  Future<void> _initPermissions() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      // Sensors/activityRecognition
      if (sdkInt >= 29) {
        _requiredPermissions.add(Permission.activityRecognition);
      } else {
        _requiredPermissions.add(Permission.sensors);
      }
      // Storage
      if (sdkInt >= 30) {
        _storageRelevant = false;
      } else {
        _optionalPermissions.add(Permission.storage);
        _storageRelevant = true;
      }
    } else {
      // iOS: sensors and storage not required
      _requiredPermissions.add(Permission.sensors);
      _storageRelevant = false;
    }
    await _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isLoading = true;
    });
    try {
      for (var permission in _requiredPermissions) {
        _permissionStatuses[permission] = await permission.status;
      }
      for (var permission in _optionalPermissions) {
        _permissionStatuses[permission] = await permission.status;
      }
      // Only block if a required permission is not granted
      bool essentialGranted = true;
      for (var permission in _requiredPermissions) {
        if (!(_permissionStatuses[permission]?.isGranted ?? false)) {
          essentialGranted = false;
          break;
        }
      }
      if (essentialGranted) {
        _navigateToDashboard();
      }
    } catch (e) {
      debugPrint('Error checking permissions: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    setState(() {
      _isLoading = true;
    });
    try {
      for (var permission in _requiredPermissions) {
        _permissionStatuses[permission] = await permission.request();
      }
      for (var permission in _optionalPermissions) {
        _permissionStatuses[permission] = await permission.request();
      }
      bool essentialGranted = true;
      for (var permission in _requiredPermissions) {
        if (!(_permissionStatuses[permission]?.isGranted ?? false)) {
          essentialGranted = false;
          break;
        }
      }
      if (essentialGranted) {
        _navigateToDashboard();
      } else {
        if (mounted) {
          _showPermissionDialog();
        }
      }
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
      if (mounted) {
        _navigateToDashboard();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'Sleep Sensei AI needs these permissions to provide you with the best sleep tracking experience:\n\n'
          '• Storage: To save your sleep data and audio files\n'
          '• Microphone: For future voice features\n'
          '• Notifications: To send you sleep tips and alarms\n'
          '• Sensors: To detect your sleep patterns\n\n'
          'Please grant these permissions in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _navigateToDashboard() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo and Title
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.bedtime,
                      size: 80,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Welcome to Sleep Sensei AI',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkBlue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'To provide you with the best sleep tracking experience, we need a few permissions.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              
              const SizedBox(height: 48),
              
              // Permissions List
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Required Permissions',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPermissionItem(
                        Icons.mic,
                        'Microphone',
                        'For future voice features and sleep sounds',
                        Permission.microphone,
                        isRequired: true,
                      ),
                      _buildPermissionItem(
                        Icons.notifications,
                        'Notifications',
                        'Send you sleep tips and smart alarms',
                        Permission.notification,
                        isRequired: true,
                      ),
                      if (_permissionStatuses.containsKey(Permission.activityRecognition))
                        _buildPermissionItem(
                          Icons.directions_run,
                          'Physical Activity',
                          'Detect your sleep patterns and movement',
                          Permission.activityRecognition,
                          isRequired: true,
                        ),
                      if (_permissionStatuses.containsKey(Permission.sensors))
                        _buildPermissionItem(
                          Icons.sensors,
                          'Sensors',
                          'Detect your sleep patterns and movement',
                          Permission.sensors,
                          isRequired: true,
                        ),
                      if (_storageRelevant)
                        _buildPermissionItem(
                          Icons.folder,
                          'Storage',
                          'Save your sleep data and audio files',
                          Permission.storage,
                          isRequired: false,
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                )
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _requestPermissions,
                      child: const Text('Grant Essential Permissions'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _checkPermissions,
                            child: const Text('Refresh Status'),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: _navigateToDashboard,
                            child: const Text('Continue Anyway'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You can always grant permissions later in settings',
                      style: TextStyle(
                        color: AppTheme.mediumGray,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem(IconData icon, String title, String description, Permission permission, {bool isRequired = false}) {
    final status = _permissionStatuses[permission];
    final isGranted = status?.isGranted ?? false;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isGranted 
                  ? AppTheme.softGreen.withValues(alpha: 0.1)
                  : AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isGranted ? Icons.check : icon,
              color: isGranted ? AppTheme.softGreen : AppTheme.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkBlue,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.warmOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Required',
                          style: TextStyle(
                            color: AppTheme.warmOrange,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.mediumGray,
                    fontSize: 12,
                  ),
                ),
                if (status != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.limited:
        return 'Limited';
      case PermissionStatus.provisional:
        return 'Provisional';
    }
  }

  Color _getStatusColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return AppTheme.softGreen;
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
        return Colors.red;
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
        return AppTheme.warmOrange;
      case PermissionStatus.provisional:
        return AppTheme.secondaryBlue;
    }
  }
} 