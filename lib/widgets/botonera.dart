import 'package:flutter/material.dart';

class Botonera extends StatelessWidget {
  final VoidCallback play, next, previous;
  final bool playing;
  final Duration position, duration;
  final double progressPorcent;
  final Color color;

  const Botonera({
    super.key,
    required this.play,
    required this.next,
    required this.previous,
    required this.playing,
    required this.position,
    required this.duration,
    required this.progressPorcent,
    required this.color,
  });

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Padding(
            padding: EdgeInsets.symmetric(horizontal: w * .06),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(position), style: const TextStyle(color: Colors.white70)),
                Text(_fmt(duration), style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous_rounded),
                onPressed: previous,
              ),
              Container(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: IconButton(
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow_rounded),
                  onPressed: play,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next_rounded),
                onPressed: next,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
