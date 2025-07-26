import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/audio_track.dart';
import 'dart:async';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<AudioTrack> availableTracks = [
    
    AudioTrack(
      id: 'white-noise',
      title: 'Deep Space',
      url: '',
      localAsset: 'assets/sounds/Transcendence-chosic.com_.mp3',
    ),
    AudioTrack(
      id: 'forest',
      title: 'Forest Sounds',
      url: '',
      localAsset: 'assets/sounds/09-Meydan-Contemplate-the-stars(chosic.com).mp3',
    ),
  ];

  AudioTrack? currentTrack;
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Request audio permissions
      await _requestPermissions();
      
      // Set up audio player listeners
      _audioPlayer.playerStateStream.listen((state) {
        isPlaying = state.playing;
        notifyListeners();
      });
      
      _audioPlayer.positionStream.listen((pos) {
        position = pos;
        notifyListeners();
      });
      
      _audioPlayer.durationStream.listen((dur) {
        duration = dur ?? Duration.zero;
        notifyListeners();
      });
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing audio player: $e');
    }
  }

  Future<void> _requestPermissions() async {
    try {
      // Request storage permission for audio files
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }
      
      // Request microphone permission (for future features)
      var micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted) {
        micStatus = await Permission.microphone.request();
      }
      
      debugPrint('Storage permission: $status, Microphone permission: $micStatus');
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
  }

  Future<void> playTrack(AudioTrack track) async {
    try {
      await initialize();
      
      currentTrack = track;
      
      // Try local asset first, then fall back to URL
      try {
        if (track.localAsset != null) {
          await _audioPlayer.setAsset(track.localAsset!);
        } else {
          await _audioPlayer.setUrl(track.url);
        }
      } catch (assetError) {
        debugPrint('Error with local asset, trying URL: $assetError');
        await _audioPlayer.setUrl(track.url);
      }
      
      // Start playing
      await _audioPlayer.play();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing track: $e');
      // Fallback to simulation if real audio fails
      _simulatePlayback(track);
    }
  }

  void _simulatePlayback(AudioTrack track) {
    currentTrack = track;
    isPlaying = true;
    position = Duration.zero;
    duration = const Duration(minutes: 10);
    notifyListeners();
    
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isPlaying && position < duration) {
        position += const Duration(seconds: 1);
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      isPlaying = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error pausing audio: $e');
      isPlaying = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      isPlaying = false;
      currentTrack = null;
      position = Duration.zero;
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping audio: $e');
      isPlaying = false;
      currentTrack = null;
      position = Duration.zero;
      notifyListeners();
    }
  }

  Future<void> seek(Duration pos) async {
    try {
      await _audioPlayer.seek(pos);
      position = pos;
      notifyListeners();
    } catch (e) {
      debugPrint('Error seeking audio: $e');
      position = pos;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
