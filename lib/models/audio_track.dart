class AudioTrack {
  final String id;
  final String title;
  final String url;
  final String? localAsset;

  AudioTrack({
    required this.id,
    required this.title,
    required this.url,
    this.localAsset,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'url': url,
    'localAsset': localAsset,
  };

  factory AudioTrack.fromMap(Map<String, dynamic> map) => AudioTrack(
    id: map['id'],
    title: map['title'],
    url: map['url'],
    localAsset: map['localAsset'],
  );
}
