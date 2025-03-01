class Song {
  String id;
  String title;
  String album;
  String artist;
  String source;
  String image;
  int duration;
  bool favorite;
  int counter;
  int replay;

  Song({
    required this.id,
    required this.album,
    required this.artist,
    required this.counter,
    required this.duration,
    required this.favorite,
    required this.image,
    required this.replay,
    required this.source,
    required this.title,
  });

  factory Song.fromJson(Map<String, dynamic> map) {
    return Song(
      id: map['id'],
      album: map['title'],
      artist: map['artist'],
      counter: map['counter'],
      duration: map['duration'],
      favorite: map['favorite'],
      image: map['image'],
      replay: map['replay'],
      source: map['source'],
      title: map['title'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
