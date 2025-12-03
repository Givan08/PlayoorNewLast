
import 'package:equatable/equatable.dart';
import '../../model/audio_item.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();
  @override
  List<Object> get props => [];
}

class PlayerLoadRequested extends PlayerEvent {
  final List<AudioItem> items;
  final int start;
  const PlayerLoadRequested(this.items, {this.start = 0});
  @override
  List<Object> get props => [items, start];
}

class PlayerToggleRequested extends PlayerEvent {}
class PlayerNextRequested extends PlayerEvent {}
class PlayerPrevRequested extends PlayerEvent {}

class PlayerSetIndexRequested extends PlayerEvent {
  final int index;
  const PlayerSetIndexRequested(this.index);
  @override
  List<Object> get props => [index];
}

class PlayerSeekRequested extends PlayerEvent {
  final Duration position;
  const PlayerSeekRequested(this.position);
  @override
  List<Object> get props => [position];
}

class PlayerSetVolumeRequested extends PlayerEvent {
  final double volume;
  const PlayerSetVolumeRequested(this.volume);
  @override
  List<Object> get props => [volume];
}

class PlayerSetRateRequested extends PlayerEvent {
  final double rate;
  const PlayerSetRateRequested(this.rate);
  @override
  List<Object> get props => [rate];
}