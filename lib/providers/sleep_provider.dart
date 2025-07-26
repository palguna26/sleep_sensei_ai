import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/sleep_session.dart';
import '../models/energy_model.dart';
import '../providers/auth_provider.dart';
import '../ml/energy_predictor.dart';
import '../ml/sleep_stager.dart';

class SleepProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<SleepSession> _sessions = [];
  bool _isSleeping = false;
  String? _uid;
  DateTime? _lastMovement;
  Timer? _pollingTimer;
  final Duration _inactivityThreshold = const Duration(minutes: 20);
  DateTime? _sleepStart;
  final EnergyModel _energyModel = EnergyModel();
  final EnergyPredictor _energyPredictor = EnergyPredictor();
  final SleepStager _sleepStager = SleepStager();
  bool _mlReady = false;

  List<SleepSession> get sessions => _sessions;
  bool get isSleeping => _isSleeping;
  Duration get sleepDebt => _calculateSleepDebt();
  Duration get idealSleep => const Duration(hours: 8);
  /// Returns a 24-hour predicted energy curve using sleep debt and circadian model
  List<FlSpot> get predictedEnergyCurve {
    final last7Days = _sessions.take(7).map((s) => s.duration.inHours.toDouble()).toList();
    final sleepDebt = _energyModel.calculateSleepDebt(last7Days);
    double phaseShift = 0;
    try {
      final profile = AuthProvider().profile;
      if (profile != null) {
        if (profile.chronotype == 'early_bird') { phaseShift = -2; }
        else if (profile.chronotype == 'night_owl') { phaseShift = 2; }
      }
    } catch (_) {}
    // ML-based prediction if available
    if (_mlReady) {
      return List.generate(24, (i) {
        final hour = i.toDouble();
        // Example: [sleepDebt, hour, chronotypeIndex]
        int chronotypeIdx = 1; // 0: early, 1: intermediate, 2: night
        try {
          final profile = AuthProvider().profile;
          if (profile != null) {
            if (profile.chronotype == 'early_bird') { chronotypeIdx = 0; }
            else if (profile.chronotype == 'night_owl') { chronotypeIdx = 2; }
          }
        } catch (_) {}
        final input = [sleepDebt, hour, chronotypeIdx.toDouble()];
        double y = _energyPredictor.predict(input).clamp(0.0, 1.0);
        y = double.parse(y.toStringAsFixed(2));
        return FlSpot(hour, y);
      });
    }
    // Fallback: rule-based
    return _energyModel.generateEnergyCurve(sleepDebt, phaseShift: phaseShift)
      .map((spot) => FlSpot(spot.x, double.parse(spot.y.toStringAsFixed(2)))).toList();
  }
  // Circadian energy calculation based on user sleep/wake times and ML model
  List<FlSpot> get circadianEnergyCurve => _generateCircadianEnergyCurve();

  void init(String uid) {
    _uid = uid;
    _startSensorListener();
    _fetchSessions();
  }

  void _startSensorListener() {
    accelerometerEventStream().listen((event) {
      _lastMovement = DateTime.now();
    });

    _pollingTimer = Timer.periodic(const Duration(minutes: 1), (_) => _checkInactivity());
  }

  Future<void> _checkInactivity() async {
    if (_lastMovement == null || _uid == null) return;

    final now = DateTime.now();
    final inactive = now.difference(_lastMovement!);

    if (!_isSleeping && inactive > _inactivityThreshold) {
      _isSleeping = true;
      _sleepStart = now.subtract(_inactivityThreshold);
      notifyListeners();
    } else if (_isSleeping && inactive < const Duration(minutes: 2)) {
      _isSleeping = false;
      if (_sleepStart != null) {
        await _logSession(_uid!, _sleepStart!, now);
        await _fetchSessions();
      }
      notifyListeners();
    }
  }

  Future<void> _fetchSessions() async {
    if (_uid == null) return;
    
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(_uid)
          .collection('sessions')
          .orderBy('start', descending: true)
          .limit(30)
          .get();

      _sessions = querySnapshot.docs
          .map((doc) => SleepSession.fromMap(doc.data()))
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching sleep sessions: $e');
    }
  }

  Future<void> _logSession(String uid, DateTime start, DateTime end) async {
    try {
      final session = SleepSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        start: start,
        end: end,
        source: 'sensor',
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('sessions')
          .doc(session.id)
          .set(session.toMap());
    } catch (e) {
      debugPrint('Error logging sleep session: $e');
    }
  }

  Future<void> fetchSleepSessions() async {
    await _fetchSessions();
  }

  Duration _calculateSleepDebt() {
    if (_sessions.isEmpty) return Duration.zero;
    
    final totalSleep = _sessions.fold<Duration>(
      Duration.zero,
      (total, session) => total + session.end.difference(session.start),
    );
    
    final idealTotal = idealSleep * _sessions.length;
    return totalSleep - idealTotal;
  }

  List<FlSpot> _generateCircadianEnergyCurve() {
    // Use ML model if available, otherwise fallback to rule-based
    if (_mlReady && _sessions.isNotEmpty) {
      // Calculate average sleep/wake times from recent sessions
      final recentSessions = _sessions.take(7).toList();
      if (recentSessions.isNotEmpty) {
        final avgSleepHour = recentSessions
            .map((s) => s.start.hour.toDouble())
            .reduce((a, b) => a + b) / recentSessions.length;
        final avgWakeHour = recentSessions
            .map((s) => s.end.hour.toDouble())
            .reduce((a, b) => a + b) / recentSessions.length;
        
        // Use ML model for circadian prediction
        final last7Days = _sessions.take(7).map((s) => s.duration.inHours.toDouble()).toList();
        final sleepDebt = _energyModel.calculateSleepDebt(last7Days);
        
        return List.generate(24, (i) {
          final hour = i.toDouble();
          int chronotypeIdx = 1; // 0: early, 1: intermediate, 2: night
          try {
            final profile = AuthProvider().profile;
            if (profile != null) {
              if (profile.chronotype == 'early_bird') { chronotypeIdx = 0; }
              else if (profile.chronotype == 'night_owl') { chronotypeIdx = 2; }
            }
          } catch (_) {}
          
          // ML-based circadian prediction
          final input = [sleepDebt, hour, chronotypeIdx.toDouble(), avgSleepHour, avgWakeHour];
          double y = _energyPredictor.predict(input).clamp(0.0, 1.0);
          y = double.parse(y.toStringAsFixed(2));
          return FlSpot(hour, y);
        });
      }
    }
    
    // Fallback: rule-based circadian rhythm
    int sleepHour = 23;
    int wakeHour = 7;
    
    // Try to get from user profile if available
    try {
      final profile = AuthProvider().profile;
      if (profile != null) {
        // Use user's typical sleep/wake times if available
        // This would need to be stored in user profile
      }
    } catch (_) {}
    
    final List<FlSpot> spots = [];
    for (int i = 0; i < 24; i++) {
      double hour = i.toDouble();
      double energy;
      if (i >= sleepHour || i < wakeHour) {
        energy = 0.1; // Deep sleep
      } else if (i == wakeHour) {
        energy = 0.7; // Wake up boost
      } else if (i >= wakeHour && i < 12) {
        energy = 0.9; // Morning peak
      } else if (i >= 12 && i < 15) {
        energy = 0.6; // Afternoon dip
      } else if (i >= 15 && i < 19) {
        energy = 0.8; // Second wind
      } else {
        energy = 0.4; // Evening wind-down
      }
      spots.add(FlSpot(hour, energy));
    }
    return spots;
  }

  Future<void> manualLog(DateTime start, DateTime end) async {
    if (_uid == null) return;
    
    try {
      final session = SleepSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        start: start,
        end: end,
        source: 'manual',
      );

      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('sessions')
          .doc(session.id)
          .set(session.toMap());

      await _fetchSessions();
    } catch (e) {
      debugPrint('Error logging manual session: $e');
      throw Exception('Failed to log sleep session: $e');
    }
  }

  Future<void> addManualSession(SleepSession session) async {
    if (_uid == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('sessions')
          .doc(session.id)
          .set(session.toMap());

      await _fetchSessions();
    } catch (e) {
      debugPrint('Error adding manual session: $e');
      throw Exception('Failed to add sleep session: $e');
    }
  }

  Future<void> deleteSession(String sessionId) async {
    if (_uid == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(_uid)
          .collection('sessions')
          .doc(sessionId)
          .delete();

      await _fetchSessions();
    } catch (e) {
      debugPrint('Error deleting session: $e');
      throw Exception('Failed to delete sleep session: $e');
    }
  }

  Future<void> loadMLModels() async {
    try {
      await _energyPredictor.loadModel();
      await _sleepStager.loadModel();
      _mlReady = true;
    } catch (e) {
      debugPrint('ML model load failed: $e');
      _mlReady = false;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

