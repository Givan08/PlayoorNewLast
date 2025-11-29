import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/audio_repository.dart';
import 'audio_event.dart';
import 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioRepository repository;

  AudioBloc({required this.repository}) : super(AudioInitial()) {
    on<LoadAudioFromDatabase>(_onLoadAudio);
  }

  Future<void> _onLoadAudio(
      LoadAudioFromDatabase event, Emitter<AudioState> emit) async {
    emit(AudioLoading());
    try {

      final songs = await repository.getAllSongs();



      emit(AudioLoaded(songs));
    } catch (e) {
      emit(AudioError("Error al cargar canciones: $e"));
    }
  }
}