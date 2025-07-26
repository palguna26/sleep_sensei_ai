import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/audio_provider.dart';

class WindDownScreen extends StatelessWidget {
  const WindDownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Wind‑Down")),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Relax and prepare for restful sleep",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: audioProvider.availableTracks.length,
              itemBuilder: (_, i) {
                final track = audioProvider.availableTracks[i];
                final selected = audioProvider.currentTrack?.id == track.id;
                return ListTile(
                  title: Text(track.title, style: const TextStyle(color: Colors.white)),
                  trailing: selected && audioProvider.isPlaying
                      ? const Icon(Icons.pause, color: Colors.white70)
                      : const Icon(Icons.play_arrow, color: Colors.white70),
                  onTap: () async {
                    if (selected && audioProvider.isPlaying) {
                      await audioProvider.pause();
                    } else {
                      await audioProvider.playTrack(track);
                    }
                  },
                );
              },
            ),
          ),
          if (audioProvider.currentTrack != null)
            Column(
              children: [
                Slider(
                  min: 0,
                  max: audioProvider.duration.inSeconds.toDouble(),
                  value: audioProvider.position.inSeconds.toDouble().clamp(0.0, audioProvider.duration.inSeconds.toDouble()),
                  onChanged: (value) {
                    audioProvider.seek(Duration(seconds: value.toInt()));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.stop, color: Colors.white70),
                      onPressed: () async => await audioProvider.stop(),
                    ),
                    IconButton(
                      icon: Icon(
                        audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white70,
                      ),
                      onPressed: () async {
                        if (audioProvider.isPlaying) {
                          await audioProvider.pause();
                        } else if (audioProvider.currentTrack != null) {
                          await audioProvider.playTrack(audioProvider.currentTrack!);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}
