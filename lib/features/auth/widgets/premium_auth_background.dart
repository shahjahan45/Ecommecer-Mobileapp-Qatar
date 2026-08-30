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
    final topRightRect = Rect.fromCircle(
      center: Offset(size.width * 0.96, size.height * 0.04),
      radius: math.max(size.width, size.height) * 0.34,
    );

    final topRightPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0x337B5CFF),
          Color(0x147B5CFF),
          Color(0x007B5CFF),
        ],
        stops: [0, 0.52, 1],
      ).createShader(topRightRect);
    canvas.drawCircle(
      topRightRect.center,
      topRightRect.width / 2,
      topRightPaint,
    );

    final bottomLeftRect = Rect.fromCircle(
      center: Offset(-size.width * 0.10, size.height * 0.78),
      radius: math.max(size.width, size.height) * 0.27,
    );
    final bottomLeftPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0x246847F5),
          Color(0x0D6847F5),
          Color(0x006847F5),
        ],
      ).createShader(bottomLeftRect);
    canvas.drawCircle(
      bottomLeftRect.center,
      bottomLeftRect.width / 2,
      bottomLeftPaint,
    );

    final peachRect = Rect.fromCircle(
      center: Offset(size.width * 1.03, size.height * 0.91),
      radius: math.max(size.width, size.height) * 0.19,
    );
    final peachPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0x20FF9F72),
          Color(0x08FF9F72),
          Color(0x00FF9F72),
        ],
      ).createShader(peachRect);
    canvas.drawCircle(
      peachRect.center,
      peachRect.width / 2,
      peachPaint,
    );

    final ribbonPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25
      ..color = AppColors.primary.withValues(alpha: 0.10);

    final ribbon = Path()
      ..moveTo(size.width * 0.58, -20)
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.13,
        size.width * 0.73,
        size.height * 0.17,
        size.width * 0.78,
        size.height * 0.26,
      )
      ..cubicTo(
        size.width * 0.86,
        size.height * 0.38,
        size.width * 0.95,
        size.height * 0.39,
        size.width * 1.04,
        size.height * 0.45,
      );
    canvas.drawPath(ribbon, ribbonPaint);

    final ribbon2 = Path()
      ..moveTo(size.width * 0.64, -30)
      ..cubicTo(
        size.width * 0.64,
        size.height * 0.12,
        size.width * 0.78,
        size.height * 0.16,
        size.width * 0.83,
        size.height * 0.25,
      )
      ..cubicTo(
        size.width * 0.90,
        size.height * 0.35,
        size.width * 0.99,
        size.height * 0.37,
        size.width * 1.08,
        size.height * 0.42,
      );
    canvas.drawPath(
      ribbon2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.32),
    );

    final dotPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.11);
    const columns = 4;
    const rows = 5;
    final startX = size.width * 0.85;
    final startY = size.height * 0.16;
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        canvas.drawCircle(
          Offset(startX + (column * 14), startY + (row * 14)),
          2.3,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
