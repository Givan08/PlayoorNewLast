import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slider_drawer/flutter_slider_drawer.dart';

import '../bloc/player/player_event.dart';
import '../bloc/player/player_state.dart';
import 'player.dart';
import '../bloc/player/player_bloc.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Biblioteca')),
    body: const Center(child: Text('Aquí iría tu biblioteca')),
  );
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Favoritos')),
    body: const Center(child: Text('Aquí irían tus favoritos')),
  );
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ajustes')),
    body: const Center(child: Text('Ajustes generales de la app')),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlayerBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Playoor",
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xff21176e),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xff1616ac),
            surface: Color(0xff1e1e2c),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xff21176e),
            elevation: 0,
            centerTitle: true,
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontFamily: "DMSerif",
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: SliderDrawer(
           appBar: SliderAppBar(
            config: SliderAppBarConfig(
              backgroundColor: const Color(0xff21176e),
              drawerIconColor: Colors.white,
              title: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Reproductor Moderno",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: "DMSerif",
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
          slider: const _MenuLateral(),
          child: const Player(),
        ),
      ),
    );
  }
}

class _MenuLateral extends StatelessWidget {
  const _MenuLateral();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xff1e1e2c),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundImage: AssetImage('assets/allthat_colored.jpg'),
            ),
            const SizedBox(height: 16),

            BlocBuilder<PlayerBloc, PlayerState>(
              builder: (context, state) {
                final playerBloc = context.read<PlayerBloc>();


                final audioList = state.list;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous, size: 30, color: Colors.white70),
                        onPressed: audioList.isEmpty ? null : () => playerBloc.add(PlayerPrevRequested()),                      ),
                      IconButton(
                        icon: Icon(
                          state.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          size: 50,
                          color: const Color(0xffda1cd2),
                        ),
                        onPressed: audioList.isEmpty ? null : () => playerBloc.add(PlayerToggleRequested()),                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, size: 30, color: Colors.white70),
                        onPressed: audioList.isEmpty ? null : () => playerBloc.add(PlayerNextRequested()),                      ),
                    ],
                  ),
                );
              },
            ),
            const Divider(color: Colors.white54),

            const ListTile(
              leading: Icon(Icons.library_music),
              title: Text('Biblioteca'),
            ),
            const ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Favoritos'),
            ),
            const ListTile(
              leading: Icon(Icons.settings),
              title: Text('Ajustes'),
            ),
          ],
        ),
      ),
    );
  }
}
