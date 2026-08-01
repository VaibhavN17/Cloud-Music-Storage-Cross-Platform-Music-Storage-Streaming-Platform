/// Audio player state and provider.
///
/// Manages playback queue, active track, playback controls, repeat/shuffle,
/// position stream, and background audio service integration.
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../shared/models/track_model.dart';
import '../../../../core/constants/app_constants.dart';

enum RepeatState { off, one, all }

class PlayerState {
  const PlayerState({
    this.currentTrack,
    this.queue = const [],
    this.currentIndex = -1,
    this.isPlaying = false,
    this.isBuffering = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedPosition = Duration.zero,
    this.speed = AppConstants.defaultPlaybackSpeed,
    this.repeatState = RepeatState.off,
    this.isShuffleEnabled = false,
    this.sleepTimerDuration,
    this.errorMessage,
  });

  final TrackModel? currentTrack;
  final List<TrackModel> queue;
  final int currentIndex;
  final bool isPlaying;
  final bool isBuffering;
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final double speed;
  final RepeatState repeatState;
  final bool isShuffleEnabled;
  final Duration? sleepTimerDuration;
  final String? errorMessage;

  bool get hasTrack => currentTrack != null;
  bool get hasNext => currentIndex < queue.length - 1 || repeatState == RepeatState.all;
  bool get hasPrevious => currentIndex > 0 || position.inSeconds > 3;

  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  PlayerState copyWith({
    TrackModel? currentTrack,
    List<TrackModel>? queue,
    int? currentIndex,
    bool? isPlaying,
    bool? isBuffering,
    Duration? position,
    Duration? duration,
    Duration? bufferedPosition,
    double? speed,
    RepeatState? repeatState,
    bool? isShuffleEnabled,
    Duration? sleepTimerDuration,
    String? errorMessage,
  }) {
    return PlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isBuffering: isBuffering ?? this.isBuffering,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bufferedPosition: bufferedPosition ?? this.bufferedPosition,
      speed: speed ?? this.speed,
      repeatState: repeatState ?? this.repeatState,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      sleepTimerDuration: sleepTimerDuration ?? this.sleepTimerDuration,
      errorMessage: errorMessage,
    );
  }
}

final playerProvider = StateNotifierProvider<PlayerNotifier, PlayerState>((ref) {
  return PlayerNotifier();
});

class PlayerNotifier extends StateNotifier<PlayerState> {
  PlayerNotifier() : super(const PlayerState()) {
    _initAudioPlayer();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _bufferedSub;
  StreamSubscription? _playerStateSub;

  void _initAudioPlayer() {
    _positionSub = _audioPlayer.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    _durationSub = _audioPlayer.durationStream.listen((dur) {
      if (dur != null) {
        state = state.copyWith(duration: dur);
      }
    });

    _bufferedSub = _audioPlayer.bufferedPositionStream.listen((buf) {
      state = state.copyWith(bufferedPosition: buf);
    });

    _playerStateSub = _audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;

      final isBuffering = processingState == ProcessingState.buffering ||
          processingState == ProcessingState.loading;

      state = state.copyWith(
        isPlaying: isPlaying,
        isBuffering: isBuffering,
      );

      if (processingState == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });
  }

  Future<void> playTrack(TrackModel track, {List<TrackModel>? queue, int? index}) async {
    final newQueue = queue ?? [track];
    final newIndex = index ?? newQueue.indexWhere((t) => t.id == track.id);

    state = state.copyWith(
      currentTrack: track,
      queue: newQueue,
      currentIndex: newIndex >= 0 ? newIndex : 0,
      isBuffering: true,
    );

    try {
      // Use localPath if downloaded, streamUrl if available, or mock asset
      final source = track.localPath != null
          ? AudioSource.uri(Uri.file(track.localPath!))
          : track.streamUrl != null
              ? AudioSource.uri(Uri.parse(track.streamUrl!))
              : null;

      if (source != null) {
        await _audioPlayer.setAudioSource(source);
        await _audioPlayer.play();
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to play track: ${e.toString()}',
        isBuffering: false,
      );
    }
  }

  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      if (state.currentTrack != null) {
        await _audioPlayer.play();
      }
    }
  }

  Future<void> play() async => _audioPlayer.play();
  Future<void> pause() async => _audioPlayer.pause();

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> next() async {
    if (state.queue.isEmpty) return;
    if (state.currentIndex < state.queue.length - 1) {
      final nextIndex = state.currentIndex + 1;
      await playTrack(state.queue[nextIndex], queue: state.queue, index: nextIndex);
    } else if (state.repeatState == RepeatState.all) {
      await playTrack(state.queue.first, queue: state.queue, index: 0);
    }
  }

  Future<void> previous() async {
    if (state.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }
    if (state.currentIndex > 0) {
      final prevIndex = state.currentIndex - 1;
      await playTrack(state.queue[prevIndex], queue: state.queue, index: prevIndex);
    }
  }

  void toggleRepeat() {
    final nextState = switch (state.repeatState) {
      RepeatState.off => RepeatState.all,
      RepeatState.all => RepeatState.one,
      RepeatState.one => RepeatState.off,
    };
    state = state.copyWith(repeatState: nextState);

    switch (nextState) {
      case RepeatState.off:
        _audioPlayer.setLoopMode(LoopMode.off);
      case RepeatState.one:
        _audioPlayer.setLoopMode(LoopMode.one);
      case RepeatState.all:
        _audioPlayer.setLoopMode(LoopMode.all);
    }
  }

  void toggleShuffle() {
    final newShuffle = !state.isShuffleEnabled;
    state = state.copyWith(isShuffleEnabled: newShuffle);
    _audioPlayer.setShuffleModeEnabled(newShuffle);
  }

  Future<void> setSpeed(double speed) async {
    state = state.copyWith(speed: speed);
    await _audioPlayer.setSpeed(speed);
  }

  void _onTrackCompleted() {
    if (state.repeatState == RepeatState.one) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();
    } else if (state.hasNext) {
      next();
    }
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _bufferedSub?.cancel();
    _playerStateSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
