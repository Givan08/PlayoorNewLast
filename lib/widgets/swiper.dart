import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../model/audio_item.dart';

class Swiper extends StatefulWidget {
  final PageController pageController;
  final List<AudioItem> audioList;
  final int currentIndex;
  final Function(int) onpageChange;
  final Color color;

  const Swiper({
    super.key,
    required this.pageController,
    required this.audioList,
    required this.currentIndex,
    required this.onpageChange,
    required this.color,
  });

  @override
  State<Swiper> createState() => _SwiperState();
}

class _SwiperState extends State<Swiper> {
  static const int _virtualCount = 10000;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioList.isEmpty) return const SizedBox.shrink();

    final realLength = widget.audioList.length;

    return Column(
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * .3,
          child: PageView.builder(
            controller: widget.pageController,
            itemCount: _virtualCount,

            onPageChanged: (virtualIndex) {
              final realIndex = virtualIndex % realLength;
              widget.onpageChange(realIndex);
            },

            itemBuilder: (context, virtualIndex) {
              final realIndex = virtualIndex % realLength;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    widget.audioList[realIndex].imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 15),
        SmoothPageIndicator(
          controller: widget.pageController,
          count: realLength,
          axisDirection: Axis.horizontal,
          effect: SlideEffect(
            spacing: 8.0,
            radius: 4.0,
            dotWidth: 24.0,
            dotHeight: 16.0,
            paintStyle: PaintingStyle.stroke,
            strokeWidth: 1.5,
            dotColor: Colors.grey,
            activeDotColor: widget.color,
          ),
        ),
      ],
    );
  }
}