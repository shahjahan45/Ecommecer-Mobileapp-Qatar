import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PremiumAuthBackground extends StatelessWidget {
  final Widget child;

  const PremiumAuthBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: CustomPaint(
        painter: const _PremiumAuthBackgroundPainter(),
        child: child,
      ),
    );
  }
}

class _PremiumAuthBackgroundPainter extends CustomPainter {
  const _PremiumAuthBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final longestSide = math.max(size.width, size.height);

    final topRightRect = Rect.fromCircle(
      center: Offset(size.width * 0.97, size.height * 0.035),
      radius: longestSide * 0.34,
    );
    final topRightPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0x347B5CFF),
          Color(0x187B5CFF),
          Color(0x087B5CFF),
          Color(0x007B5CFF),
        ],
        stops: [0, 0.46, 0.72, 1],
      ).createShader(topRightRect);
    canvas.drawCircle(
      topRightRect.center,
      topRightRect.width / 2,
      topRightPaint,
    );

    final leftGlowRect = Rect.fromCircle(
      center: Offset(-size.width * 0.16, size.height * 0.67),
      radius: longestSide * 0.22,
    );
    final leftGlowPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0x166847F5),
          Color(0x086847F5),
          Color(0x006847F5),
        ],
      ).createShader(leftGlowRect);
    canvas.drawCircle(
      leftGlowRect.center,
      leftGlowRect.width / 2,
      leftGlowPaint,
    );

    final outerArc = Path()
      ..moveTo(size.width * 0.52, -28)
      ..cubicTo(
        size.width * 0.53,
        size.height * 0.14,
        size.width * 0.64,
        size.height * 0.19,
        size.width * 0.77,
        size.height * 0.22,
      )
      ..cubicTo(
        size.width * 0.92,
        size.height * 0.26,
        size.width * 1.02,
        size.height * 0.28,
        size.width * 1.10,
        size.height * 0.34,
      );

    canvas.drawPath(
      outerArc,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.34),
    );

    final innerArc = Path()
      ..moveTo(size.width * 0.61, -25)
      ..cubicTo(
        size.width * 0.62,
        size.height * 0.12,
        size.width * 0.72,
        size.height * 0.16,
        size.width * 0.83,
        size.height * 0.19,
      )
      ..cubicTo(
        size.width * 0.95,
        size.height * 0.22,
        size.width * 1.04,
        size.height * 0.25,
        size.width * 1.11,
        size.height * 0.29,
      );

    canvas.drawPath(
      innerArc,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round
        ..color = AppColors.primary.withValues(alpha: 0.09),
    );

    final dotPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.11);
    const columns = 4;
    const rows = 5;
    final startX = size.width * 0.84;
    final startY = size.height * 0.145;

    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        canvas.drawCircle(
          Offset(startX + (column * 14), startY + (row * 14)),
          2.25,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
