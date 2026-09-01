import 'dart:math' as math;

import 'package:flutter/material.dart';

class LaunchProgressIndicator extends StatelessWidget {
  final Animation<double> progress;
  final bool compact;

  const LaunchProgressIndicator({
    super.key,
    required this.progress,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final value = progress.value.clamp(0.0, 1.0).toDouble();
        return Semantics(
          label: 'Opening DCX Online Store',
          value: '${(value * 100).round()} percent',
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: compact ? 34 : 40,
                  height: compact ? 34 : 40,
                  child: CustomPaint(
                    painter: _LaunchRingPainter(value),
                  ),
                ),
                SizedBox(height: compact ? 10 : 12),
                Text(
                  'Loading your experience…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.90),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.05,
                      ),
                ),
                SizedBox(height: compact ? 12 : 16),
                SizedBox(
                  width: compact ? 210 : 258,
                  height: 7,
                  child: CustomPaint(
                    painter: _LaunchTrackPainter(value),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LaunchRingPainter extends CustomPainter {
  final double value;

  const _LaunchRingPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide / 2) - 3;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF8DA0CA).withValues(alpha: 0.34);
    canvas.drawCircle(center, radius, track);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [Color(0xFFFFB35C), Color(0xFFFF7A00)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      math.pi * 2 * value,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LaunchRingPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

class _LaunchTrackPainter extends CustomPainter {
  final double value;

  const _LaunchTrackPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = Radius.circular(size.height / 2);
    final trackRect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, radius),
      Paint()..color = const Color(0xFF8DA0CA).withValues(alpha: 0.34),
    );

    if (value <= 0) return;

    final progressRect = Rect.fromLTWH(0, 0, size.width * value, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(progressRect, radius),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFC27A), Color(0xFFFF8A2A)],
        ).createShader(trackRect),
    );
  }

  @override
  bool shouldRepaint(covariant _LaunchTrackPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
