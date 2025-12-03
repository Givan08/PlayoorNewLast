
import 'package:equatable/equatable.dart';
import '../../model/audio_item.dart';

class PlayerState extends Equatable {
  final List<AudioItem> list;
  final int index;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double volume;
  final double rate;

  const PlayerState({
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

  PlayerState copyWith({
    List<AudioItem>? list,
    int? index,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? volume,
    double? rate,
  }) {
    return PlayerState(
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