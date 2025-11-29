import 'package:flutter/material.dart';

class ProgressSlider extends StatelessWidget {
  final Duration position, duration;
  final Function(Duration) seek;
  final Color color;

  const ProgressSlider({
    super.key,
    required this.position,
    required this.duration,
    required this.seek,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final max = duration.inSeconds == 0 ? 1.0 : duration.inSeconds.toDouble();
    final value = position.inSeconds.clamp(0, duration.inSeconds).toDouble();
    return SizedBox(
      width: MediaQuery.of(context).size.width * .75,
      child: SliderTheme(
        data: SliderThemeData(
          thumbColor: color,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          activeTrackColor: color,
          inactiveTrackColor: Colors.grey[200],
          overlayColor: Colors.transparent,
        ),
        child: Slider(
          value: value,
          max: max,
          min: 0,
          onChanged: (v) => seek(Duration(seconds: v.toInt())),
        ),
      ),
    );
  }
}
