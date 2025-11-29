import 'package:equatable/equatable.dart';
import '../model/audio_item.dart';

abstract class AudioState extends Equatable {
  const AudioState();

  @override
  List<Object?> get props => [];
}

class AudioInitial extends AudioState {}

class AudioLoading extends AudioState {}

class AudioLoaded extends AudioState {
  final List<AudioItem> audioList;

  const AudioLoaded(this.audioList);

  @override
  List<Object?> get props => [audioList];
}

class AudioError extends AudioState {
  final String message;

  const AudioError(this.message);

  @override
  List<Object?> get props => [message];
}
