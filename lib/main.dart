import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'bloc/audio_bloc.dart';
import 'bloc/audio_event.dart';
import 'repository/audio_repository.dart';
import 'widgets/app.dart';
import 'bloc/player/player_bloc.dart';
import 'model/audio_item.dart';

final List<AudioItem> initialSongs = [
  AudioItem(assetPath: "allthat.mp3", title: "All that", artist: "Mayelo", imagePath: "assets/allthat_colored.jpg"),
  AudioItem(assetPath: "love.mp3", title: "Love", artist: "Diego", imagePath: "assets/love_colored.jpg"),
  AudioItem(assetPath: "thejazzpiano.mp3", title: "Jazz Piano", artist: "Jazira", imagePath: "assets/thejazzpiano_colored.jpg"),
  AudioItem(assetPath: "Abunai-BarbaraAllen.mp3", title: "Chill Vibes",artist:  "Barbara", imagePath: "assets/istockphoto-1190892627-612x612.jpg"),
  AudioItem(assetPath: "HereComesABigBlackCloud-Scrilla.mp3",title:  "Night Walk",artist:  "Luca", imagePath: "assets/lathe-2357305_640.jpg"),
  AudioItem(assetPath: "MatteBlack-CTRL.mp3", title: "Dreams", artist: "Sofi", imagePath: "assets/natural-scenery-8589165_1280.jpg"),
  AudioItem(assetPath: "Rod-InnerRhythm.mp3", title: "Pulse", artist: "Neo",imagePath:  "assets/struzne-ploscice-2.jpg"),
  AudioItem(assetPath: "Rod-TheRiverOfTheDream.mp3", title: "Sunset", artist: "Kai", imagePath: "assets/vibora-aspid-vipera-aspis-pirineos-2019-03-2048x1303.jpg"),
];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final AudioRepository repository = AudioRepository();


  await repository.insertInitialSongs(initialSongs);

  runApp(
    RepositoryProvider.value(
      value: repository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AudioBloc(repository: repository)
              ..add(LoadAudioFromDatabase()),
          ),
          BlocProvider(
            create: (_) => PlayerBloc(),
          ),
        ],
        child: const App(),
      ),
    ),
  );
}

