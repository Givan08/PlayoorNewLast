import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:playoor/widgets/progress_slider.dart';
import 'package:playoor/widgets/swiper.dart';

import '../model/audio_item.dart';
import 'artist.dart';
import 'botonera.dart';
import 'player_cubit.dart';
import '../bloc/audio_bloc.dart';
import '../bloc/audio_event.dart';
import '../bloc/audio_state.dart';


class Player extends StatefulWidget {
  const Player({super.key});

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final _pageController = PageController(viewportFraction: .8);
  final _accent = const Color(0xffda1cd2);

  static const int _virtualCount = 10000;

  bool _isPageControllerInitialized = false;


  @override
  void initState() {
    super.initState();
    context.read<AudioBloc>().add(LoadAudioFromDatabase());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PlayerCubit, PlayerStateX>(
        listenWhen: (prev, curr) => prev.index != curr.index,
        listener: (_, s) {
          final audioState = context.read<AudioBloc>().state;

          if (audioState is! AudioLoaded) return;

          final realLength = audioState.audioList.length;
          if (realLength == 0) return;

          final int virtualOffset = (_virtualCount ~/ 2) - ((_virtualCount ~/ 2) % realLength);
          final targetVirtualPage = virtualOffset + s.index;

          _pageController.animateToPage(
            targetVirtualPage,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        },
        child: BlocBuilder<PlayerCubit, PlayerStateX>(
          builder: (context, s) {
            final title = s.current?.title ?? '';
            final artist = s.current?.artist ?? '';

            return Scaffold(
              appBar: AppBar(
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => _openSettings(context, s),
                  ),
                ],
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      BlocBuilder<AudioBloc, AudioState>(
                        builder: (context, audioState) {
                          if (audioState is AudioLoading) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (audioState is AudioLoaded) {
                            final audioList = audioState.audioList;

                            context.read<PlayerCubit>().load(audioList, start: 0);

                            if (!_isPageControllerInitialized && audioList.isNotEmpty) {
                              final realLength = audioList.length;

                              final int initialVirtualOffset = (_virtualCount ~/ 2) - ((_virtualCount ~/ 2) % realLength);
                              final initialVirtualPage = initialVirtualOffset + s.index;

                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (_pageController.hasClients) {
                                  _pageController.jumpToPage(initialVirtualPage);
                                  setState(() {
                                    _isPageControllerInitialized = true;
                                  });
                                }
                              });
                            }

                            return Swiper(
                              pageController: _pageController,
                              audioList: audioList,
                              currentIndex: s.index,
                              onpageChange: (i) => context.read<PlayerCubit>().setIndex(i),
                              color: _accent,
                            );
                          } else if (audioState is AudioError) {
                            return Center(child: Text(audioState.message));
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                      Artist(artist: artist, name: title),
                      ProgressSlider(
                        position: s.position,
                        duration: s.duration,
                        seek: (d) => context.read<PlayerCubit>().seek(d),
                        color: _accent,
                      ),
                      Botonera(
                        play: () => context.read<PlayerCubit>().toggle(),
                        next: () => context.read<PlayerCubit>().next(),
                        previous: () => context.read<PlayerCubit>().prev(),
                        playing: s.isPlaying,
                        position: s.position,
                        duration: s.duration,
                        progressPorcent: s.progress,
                        color: _accent,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }

  void _openSettings(BuildContext context, PlayerStateX s) {
    final audioList = context.read<AudioBloc>().state is AudioLoaded
        ? (context.read<AudioBloc>().state as AudioLoaded).audioList
        : <AudioItem>[];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xff1e1e2c),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        double vol = s.volume;
        double rate = s.rate;
        return StatefulBuilder(builder: (ctx, setModal) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ModalControls(audioList: audioList),

                const Divider(color: Colors.white54),

                const Text('Configuración de Audio',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Volumen'),
                Slider(
                  value: vol,
                  min: 0, max: 1,
                  onChanged: (v) {
                    setModal(() => vol = v);
                    context.read<PlayerCubit>().setVolume(v);
                  },
                ),
                const SizedBox(height: 8),
                const Text('Velocidad (pitch)'),
                Slider(
                  value: rate,
                  min: 0.5, max: 2.0, divisions: 15,
                  label: '${rate.toStringAsFixed(2)}x',
                  onChanged: (r) {
                    setModal(() => rate = r);
                    context.read<PlayerCubit>().setRate(r);
                  },
                ),
                const SizedBox(height: 12),
                _Info(s: s),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}


class _ModalControls extends StatelessWidget {
  final List<AudioItem> audioList;
  const _ModalControls({required this.audioList});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerStateX>(
      builder: (context, state) {
        final playerCubit = context.read<PlayerCubit>();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 40, color: Colors.white70),
                onPressed: audioList.isEmpty ? null : () => playerCubit.prev(),
              ),
              IconButton(
                icon: Icon(
                  state.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 60,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: audioList.isEmpty ? null : () => playerCubit.toggle(),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 40, color: Colors.white70),
                onPressed: audioList.isEmpty ? null : () => playerCubit.next(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Info extends StatelessWidget {
  final PlayerStateX s;
  const _Info({required this.s});

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s2 = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s2';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          Text('Estado: ${s.isPlaying ? "Reproduciendo" : "Pausado"}'),
          Text('Duración: ${_fmt(s.duration)}'),
          Text('Posición: ${_fmt(s.position)}'),
        ],
      ),
    );
  }
}