import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:my_music/data/model/song.dart';
import 'package:my_music/ui/now_playing/audio_player_manager.dart';

class NowPlaying extends StatelessWidget {
  final Song playingSong;
  final List<Song> songs;

  const NowPlaying({
    super.key,
    required this.playingSong,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(
      songs: songs,
      playingSong: playingSong,
    );
  }
}

class NowPlayingPage extends StatefulWidget {
  final Song playingSong;
  final List<Song> songs;

  const NowPlayingPage({
    super.key,
    required this.playingSong,
    required this.songs,
  });

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  // create a controller for image
  late AnimationController _imageAnimController;
  // add controller for image
  late AudioPlayerManager _audioPlayerManager;
  // function for next button
  late int _selectedItemIndex;
  // playing song
  late Song _song;
  // anim for rotated image
  // late double _currentAnimationPosition;
  // animation with song state
  double _currentAnimationPosition = 0.0;
  // add shuffle button
  bool _isShuffle = false;
  // add loop button
  late LoopMode _loopMode;

  @override
  void initState() {
    super.initState();
    // init playing song
    _song = widget.playingSong;
    // init anim for rotated image
    _currentAnimationPosition = 0.0;
    // add init controller for rotated image
    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    _audioPlayerManager = AudioPlayerManager(); // (songUrl: _song.source);
    // init update (a part in playing song when go out of the screen)
    // after, do it with prepare below, not here
    // _audioPlayerManager.updateSongUrl(_song.source);
    _audioPlayerManager.init();
    // init next button
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
    // int loop
    _loopMode = LoopMode.off;
    // init prepare here (the final part)
    if (_audioPlayerManager.songUrl.compareTo(_song.source) != 0) {
      _audioPlayerManager.updateSongUrl(_song.source);
      _audioPlayerManager.prepare(isNewSong: true);
    } else {
      _audioPlayerManager.prepare(isNewSong: false);
    }
  }

  @override
  void dispose() {
    // no need _audioPlayerManager.dispose(); now
    // _audioPlayerManager.dispose();
    _imageAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return const Scaffold(
    //   body: Center(
    //     child: Text('Now Playing'),
    //   ),
    // );
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64;
    final radius = (screenWidth - delta) / 2;
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Now Playing'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz),
        ),
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_song.album),
              const SizedBox(
                height: 16,
              ),
              const Text('_ ___ _'),
              const SizedBox(
                height: 48,
              ),
              // make the image rotated
              RotationTransition(
                turns:
                    Tween(begin: 0.0, end: 1.0).animate(_imageAnimController),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/itunes_256.png',
                    image: _song.image,
                    width: screenWidth - delta,
                    height: screenWidth - delta,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/itunes_256.png',
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                      );
                    },
                  ),
                ),
              ),
              // add name and artist
              Padding(
                padding: const EdgeInsets.only(top: 64, bottom: 16),
                child: SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      Column(
                        children: [
                          Text(
                            _song.title,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color),
                          ),
                          // bodyMedium must be null (!) here to access color property
                          const SizedBox(height: 8),
                          Text(
                            _song.artist,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .color),
                          )
                        ],
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_outline),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
              // add progress bar here
              Padding(
                padding: const EdgeInsets.only(
                  top: 32,
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                child: _progressBar(),
              ),
              // add media button
              Padding(
                padding: const EdgeInsets.only(
                  top: 0,
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                child: _mediaButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // progess bar
  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
      stream: _audioPlayerManager.durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;
        return ProgressBar(
          progress: progress,
          total: total,
          // add more new function to progress bar
          buffered: buffered,
          onSeek: _audioPlayerManager.player.seek,
          barHeight: 5.0,
          barCapShape: BarCapShape.round,
          baseBarColor: Colors.grey.withOpacity(0.3),
          progressBarColor: Colors.green,
          bufferedBarColor: Colors.grey.withOpacity(0.3),
          thumbColor: Colors.deepPurple,
          thumbGlowColor: Colors.green.withOpacity(0.3),
          thumbRadius: 10.0,
        );
      },
    );
  }

  // create media button
  Widget _mediaButton() {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MediaButtonControl(
              icon: Icons.shuffle,
              color: _getShuffleColor(),
              size: 24,
              function: _setShuffle),
          MediaButtonControl(
              icon: Icons.skip_previous,
              color: Colors.deepPurple,
              size: 36,
              function: _setPrevSong),
          // play, pause button here
          _playButton(),
          //
          MediaButtonControl(
              icon: Icons.skip_next,
              color: Colors.deepPurple,
              size: 36,
              function: _setNextSong),
          MediaButtonControl(
              icon: _repeatingIcon(),
              color: _getRepeatingIconColor(),
              size: 24,
              function: _setupRepeatingOption),
        ],
      ),
    );
  }

  // add play and pause button
  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder(
      stream: _audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final processingState = playState?.processingState;
        final playing = playState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          // todo: pause animation
          _pauseRotationAnim();
          return Container(
            margin: const EdgeInsets.all(8),
            width: 48,
            height: 48,
            child: const CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return MediaButtonControl(
            icon: Icons.play_arrow,
            color: null,
            size: 48,
            function: () {
              // todo: start or rusume animation
              _audioPlayerManager.player.play();
              _imageAnimController.forward(from: _currentAnimationPosition);
              _imageAnimController.repeat();
            },
          );
        } else if (processingState != ProcessingState.completed) {
          // todo: play animation
          _playRotationAnim();
          return MediaButtonControl(
            icon: Icons.pause,
            color: null,
            size: 48,
            function: () {
              // todo: pause animation, save current position value for resume
              _audioPlayerManager.player.pause();
              _pauseRotationAnim();
            },
          );
        } else {
          // todo: if song completed -> stop and reset animation
          if (processingState == ProcessingState.completed) {
            _stopRotationAnim();
            _resetRotationAnim();
          }
          return MediaButtonControl(
            icon: Icons.replay,
            color: null,
            size: 48,
            function: () {
              // todo: start animation
              // _imageAnimController.forward(from: _currentAnimationPosition);
              // _imageAnimController.repeat();
              // todo: reset and start animation
              _audioPlayerManager.player.seek(Duration.zero);
              _resetRotationAnim();
              _playRotationAnim();
            },
          );
        }
      },
    );
  }

  // next and prev button here
  void _setNextSong() {
    // check _isShuffle to next song
    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else if (_selectedItemIndex < widget.songs.length - 1) {
      ++_selectedItemIndex;
    } else if (_loopMode == LoopMode.all &&
        _selectedItemIndex == widget.songs.length - 1) {
      _selectedItemIndex = 0;
      // this is the new logic function when the app has loop mode
    }
    if (_selectedItemIndex >= widget.songs.length) {
      _selectedItemIndex = _selectedItemIndex % widget.songs.length;
    }
    // ++_selectedItemIndex;
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    // todo: reset animation
    _resetRotationAnim();
    setState(() {
      _song = nextSong;
    });
  }

  void _setPrevSong() {
    // check _isShuffle to prev song
    if (_isShuffle) {
      var random = Random();
      _selectedItemIndex = random.nextInt(widget.songs.length);
    } else if (_selectedItemIndex > 0) {
      --_selectedItemIndex;
    } else if (_loopMode == LoopMode.all && _selectedItemIndex == 0) {
      _selectedItemIndex = widget.songs.length - 1;
      // this is the new logic function when the app has loop mode
    }
    if (_selectedItemIndex < 0) {
      _selectedItemIndex = (-1 * _selectedItemIndex) % widget.songs.length;
    }
    // --_selectedItemIndex;
    final nextSong = widget.songs[_selectedItemIndex];
    _audioPlayerManager.updateSongUrl(nextSong.source);
    // todo: reset animation
    _resetRotationAnim();
    setState(() {
      _song = nextSong;
    });
  }

  void _playRotationAnim() {
    _imageAnimController.forward(from: _currentAnimationPosition);
    _imageAnimController.repeat();
  }

  void _pauseRotationAnim() {
    _stopRotationAnim();
    _currentAnimationPosition = _imageAnimController.value;
  }

  void _stopRotationAnim() {
    _imageAnimController.stop();
  }

  void _resetRotationAnim() {
    _currentAnimationPosition = 0.0;
    _imageAnimController.value = _currentAnimationPosition;
  }

  // create shuffle function and shuffle color
  void _setShuffle() {
    setState(() {
      _isShuffle = !_isShuffle;
    });
  }

  Color? _getShuffleColor() {
    return _isShuffle ? Colors.deepPurple : Colors.grey;
  }

  // create loop icon, color and function
  IconData _repeatingIcon() {
    return switch (_loopMode) {
      LoopMode.one => Icons.repeat_one,
      LoopMode.all => Icons.repeat_on,
      _ => Icons.repeat,
    };
  }

  Color? _getRepeatingIconColor() {
    return _loopMode == LoopMode.off ? Colors.grey : Colors.deepPurple;
  }

  void _setupRepeatingOption() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.off;
    } else {
      _loopMode = LoopMode.off;
    }

    setState(() {
      _audioPlayerManager.player.setLoopMode(_loopMode);
    });
  }
}

class MediaButtonControl extends StatefulWidget {
  final void Function()? function;
  final IconData icon;
  final double? size;
  final Color? color;

  const MediaButtonControl({
    super.key,
    this.function,
    required this.icon,
    this.size,
    this.color,
  });

  @override
  State<MediaButtonControl> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon),
      iconSize: widget.size,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
    );
  }
}
