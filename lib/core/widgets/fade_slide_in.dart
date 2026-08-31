import 'package:flutter/material.dart';

class FadeSlideIn extends StatelessWidget {
  final Widget child;
  final int delayMilliseconds;
  final Offset beginOffset;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delayMilliseconds = 0,
    this.beginOffset = const Offset(0, 0.06),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delayMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, animatedChild) {
        final delayedValue = delayMilliseconds == 0
            ? value
            : ((value * (420 + delayMilliseconds) - delayMilliseconds) / 420)
                .clamp(0.0, 1.0).toDouble();

        return Opacity(
          opacity: delayedValue,
          child: Transform.translate(
            offset: Offset(
              beginOffset.dx * (1 - delayedValue) * 100,
              beginOffset.dy * (1 - delayedValue) * 100,
            ),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}
