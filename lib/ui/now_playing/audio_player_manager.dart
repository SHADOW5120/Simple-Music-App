import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

// 2-	Create a singleton instance of audio_player_manager,
// when playing a song, you can control the playing state
// (what playing song?, playing?, pausing?, …)
class DurationState {
  final Duration progress;
  final Duration buffered;
  final Duration? total;

  DurationState({
    required this.progress,
    required this.buffered,
    this.total,
  });
}

class AudioPlayerManager {
  // create singleton here
  AudioPlayerManager._internal();
  static final AudioPlayerManager _intance = AudioPlayerManager._internal();
  factory AudioPlayerManager() => _intance;

  Stream<DurationState>? durationState;
  // String songUrl;
  // create a new one
  String songUrl = "";
  final player = AudioPlayer();

  // create a singleton here -> no need to have this nomal contructor
  // AudioPlayerManager({required this.songUrl});

  void init() {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
      player.positionStream,
      player.playbackEventStream,
      (position, playbackEvent) => DurationState(
        progress: position,
        buffered: playbackEvent.bufferedPosition,
        total: playbackEvent.duration,
      ),
    );
    player.setUrl(songUrl);
  }

  void dispose() {
    player.dispose();
  }

  // update song after next, prev
  void updateSongUrl(String url) {
    songUrl = url;
    init();
  }

  // play the song again when pushing on it
  void prepare({bool isNewSong = false}) {
    durationState = Rx.combineLatest2<Duration, PlaybackEvent, DurationState>(
      player.positionStream,
      player.playbackEventStream,
      (position, playbackEvent) => DurationState(
        progress: position,
        buffered: playbackEvent.bufferedPosition,
        total: playbackEvent.duration,
      ),
    );
  }
}
