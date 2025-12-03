
import 'dart:async';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'player_event.dart';
import 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  final ap.AudioPlayer _player = ap.AudioPlayer();
  StreamSubscription? _posSub, _durSub, _stSub;
  bool initialized = false;

  PlayerBloc() : super(const PlayerState()) {
    on<PlayerLoadRequested>(_onLoadRequested);
    on<PlayerToggleRequested>(_onToggleRequested);
    on<PlayerNextRequested>(_onNextRequested);
    on<PlayerPrevRequested>(_onPrevRequested);
    on<PlayerSeekRequested>(_onSeekRequested);
    on<PlayerSetIndexRequested>(_onSetIndexRequested);
    on<PlayerSetVolumeRequested>(_onSetVolumeRequested);
    on<PlayerSetRateRequested>(_onSetRateRequested);

    _posSub = _player.onPositionChanged.listen((d) => emit(state.copyWith(position: d)));
    _durSub = _player.onDurationChanged.listen((d) => emit(state.copyWith(duration: d)));
    _stSub = _player.onPlayerStateChanged.listen(
          (s) => emit(state.copyWith(isPlaying: s == ap.PlayerState.playing)),
    );
  }


  Future<void> _onLoadRequested(
      PlayerLoadRequested event, Emitter<PlayerState> emit) async {
    if (initialized) return;
    initialized = true;

    emit(state.copyWith(list: event.items, index: event.start, position: Duration.zero, duration: Duration.zero));
    if (event.items.isNotEmpty) {
      await _player.setSourceAsset(event.items[event.start].assetPath);
    }
  }

  Future<void> _onSetIndexRequested(
      PlayerSetIndexRequested event, Emitter<PlayerState> emit) async {
    if (state.list.isEmpty) return;
    final idx = event.index;

    emit(state.copyWith(index: idx, position: Duration.zero));
    await _player.stop();
    await _player.setSourceAsset(state.list[idx].assetPath);
    await _player.setPlaybackRate(state.rate);
    await _player.setVolume(state.volume);
    await _player.resume();
    emit(state.copyWith(isPlaying: true));
  }

  Future<void> _onToggleRequested(
      PlayerToggleRequested event, Emitter<PlayerState> emit) async {
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


  Future<void> _onNextRequested(
      PlayerNextRequested event, Emitter<PlayerState> emit) async {
    if (state.list.isEmpty) return;

    final nextIndex = (state.index + 1) % state.list.length;

    add(PlayerSetIndexRequested(nextIndex));
  }

  Future<void> _onPrevRequested(
      PlayerPrevRequested event, Emitter<PlayerState> emit) async {
    if (state.list.isEmpty) return;

    final prevIndex = (state.index - 1 + state.list.length) % state.list.length;

    add(PlayerSetIndexRequested(prevIndex));
  }

  Future<void> _onSeekRequested(
      PlayerSeekRequested event, Emitter<PlayerState> emit) async {
    await _player.seek(event.position);
    emit(state.copyWith(position: event.position));
  }

  Future<void> _onSetVolumeRequested(
      PlayerSetVolumeRequested event, Emitter<PlayerState> emit) async {
    await _player.setVolume(event.volume);
    emit(state.copyWith(volume: event.volume));
  }

  Future<void> _onSetRateRequested(
      PlayerSetRateRequested event, Emitter<PlayerState> emit) async {
    await _player.setPlaybackRate(event.rate);
    emit(state.copyWith(rate: event.rate));
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