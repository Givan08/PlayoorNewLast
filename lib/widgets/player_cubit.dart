import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/audio_item.dart';

class PlayerStateX extends Equatable {
  final List<AudioItem> list;
  final int index;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double volume; // 0..1
  final double rate;

  const PlayerStateX({
    this.list = const [],
    this.index = 0,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.rate = 1.0,
  });

  double get progress => duration.inMilliseconds == 0
      ? 0
      : (position.inMilliseconds / duration.inMilliseconds).clamp(0, 1);

  AudioItem? get current => list.isEmpty ? null : list[index];

  PlayerStateX copyWith({
    List<AudioItem>? list,
    int? index,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? volume,
    double? rate,
  }) {
    return PlayerStateX(
      list: list ?? this.list,
      index: index ?? this.index,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      rate: rate ?? this.rate,
    );
  }

  @override
  List<Object?> get props => [list, index, isPlaying, position, duration, volume, rate];
}

class PlayerCubit extends Cubit<PlayerStateX> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription? _posSub, _durSub, _stSub;
  bool initialized = false;


  PlayerCubit() : super(const PlayerStateX()) {
    _posSub = _player.onPositionChanged.listen((d) => emit(state.copyWith(position: d)));
    _durSub = _player.onDurationChanged.listen((d) => emit(state.copyWith(duration: d)));
    _stSub = _player.onPlayerStateChanged.listen(
          (s) => emit(state.copyWith(isPlaying: s == PlayerState.playing)),
    );
  }

  Future<void> load(List<AudioItem> items, {int start = 0}) async {
    if (initialized) return;
    initialized = true;

    emit(state.copyWith(list: items, index: start, position: Duration.zero, duration: Duration.zero));
    if (items.isNotEmpty) {
      await _player.setSourceAsset(items[start].assetPath);
    }
  }

  Future<void> setIndex(int i) async {
    if (state.list.isEmpty) return;
    final idx = i.clamp(0, state.list.length - 1);
    emit(state.copyWith(index: idx, position: Duration.zero));
    await _player.stop();
    await _player.setSourceAsset(state.list[idx].assetPath);
    await _player.setPlaybackRate(state.rate);
    await _player.setVolume(state.volume);
    await _player.resume();
    emit(state.copyWith(isPlaying: true));
  }

  Future<void> toggle() async {
    if (state.isPlaying) {
      await _player.pause();
      emit(state.copyWith(isPlaying: false));
    } else {
      if (state.position >= state.duration && state.duration != Duration.zero) {
        await _player.seek(Duration.zero);
      }
      await _player.resume();
      emit(state.copyWith(isPlaying: true));
    }
  }

  Future<void> next() async {
    if (state.list.isEmpty) return;
    final i = (state.index + 1) % state.list.length;
    await setIndex(i);
  }

  Future<void> prev() async {
    if (state.list.isEmpty) return;
    final i = (state.index - 1 + state.list.length) % state.list.length;
    await setIndex(i);
  }

  Future<void> seek(Duration d) async {
    await _player.seek(d);
    emit(state.copyWith(position: d));
  }

  Future<void> setVolume(double v) async {
    await _player.setVolume(v);
    emit(state.copyWith(volume: v));
  }

  Future<void> setRate(double r) async {
    await _player.setPlaybackRate(r);
    emit(state.copyWith(rate: r));
  }

  @override
  Future<void> close() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stSub?.cancel();
    _player.dispose();
    return super.close();
  }
}
