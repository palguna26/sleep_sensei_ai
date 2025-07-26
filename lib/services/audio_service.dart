import 'package:just_audio/just_audio.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Future<void> play(String url) async {
    await _player.setUrl(url);
    await _player.play();
  }

  void pause() => _player.pause();
  void stop() => _player.stop();
  void seek(Duration pos) => _player.seek(pos);
}
