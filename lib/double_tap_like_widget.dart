import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

part 'animated_translated_widget.dart';

part 'like_widget.dart';

class DoubleTapLikeWidget extends StatefulWidget {
  const DoubleTapLikeWidget({
    super.key,
    required this.onLike,
    required this.child,
    required this.likeWidget,
    this.translateDuration = const Duration(milliseconds: 2400),
    this.animationDuration = const Duration(milliseconds: 900),
    this.resetDuration = const Duration(milliseconds: 1500),
    this.curve = Curves.easeInOutCubic,
    this.likeWidth = 200,
    this.likeHeight = 200,
    this.likeCenterPosition = false,
  });

  final ValueChanged<int> onLike;
  final Widget child;
  final Widget likeWidget;
  final Duration translateDuration;
  final Duration animationDuration;
  final Duration resetDuration;
  final Curve curve;
  final double likeWidth;
  final double likeHeight;
  final bool likeCenterPosition;

  @override
  State createState() => _DoubleTapLikeWidgetState();
}

class _DoubleTapLikeWidgetState extends State<DoubleTapLikeWidget> {
  List<HeartInfo> hearts = [];

  int likeCount = 0;

  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: widget.child,
        ),
        ...hearts.map(
          (e) {
            double startPosition;
            double topPosition;

            if (widget.likeCenterPosition) {
              var size = MediaQuery.of(context).size;
              startPosition = (size.width / 2) - widget.likeWidth / 2;
              topPosition = (size.height / 2) - widget.likeHeight / 1.3;
            } else {
              startPosition = e.x - widget.likeWidth / 2;
              topPosition = e.y - widget.likeHeight / 1.3;
            }
            return PositionedDirectional(
              key: ValueKey(e),
              start: startPosition,
              top: topPosition,
              child: _AnimatedTranslateWidget(
                translateDuration: widget.translateDuration,
                curve: widget.curve,
                child: _LikeWidget(
                  animationDuration: widget.animationDuration,
                  width: widget.likeWidth,
                  height: widget.likeHeight,
                  likeCenterPosition: widget.likeCenterPosition,
                  child: widget.likeWidget,
                ),
                onDispose: () {
                  setState(() {
                    hearts.remove(e);
                  });
                },
              ),
            );
          },
        ),
        GestureDetector(
          onDoubleTap: () {
            likeCount++;
            widget.onLike(likeCount);

            timer?.cancel();
            timer = Timer(
              widget.resetDuration,
              () => likeCount = 0,
            );
          },
          onDoubleTapDown: (tapDownDetails) {
            setState(() {
              hearts.add(
                HeartInfo(
                  tapDownDetails.localPosition.dx,
                  tapDownDetails.localPosition.dy,
                ),
              );
            });
          },
          // child: widget.child,
        )
      ],
    );
  }
}

class HeartInfo {
  double x;
  double y;

  HeartInfo(this.x, this.y);
}
