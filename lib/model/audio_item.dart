// PODO
class AudioItem {
  final int? id;
  final String assetPath;
  final String title;
  final String artist;
  final String imagePath;

  AudioItem({
    this.id,
    required this.assetPath,
    required this.title,
    required this.artist,
    required this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assetPath': assetPath,
      'title': title,
      'artist': artist,
      'imagePath': imagePath,
    };
  }

  factory AudioItem.fromMap(Map<String, dynamic> map) {
    return AudioItem(
      id: map['id'],
      assetPath: map['assetPath'],
      title: map['title'],
      artist: map['artist'],
      imagePath: map['imagePath'],
    );
  }
}
