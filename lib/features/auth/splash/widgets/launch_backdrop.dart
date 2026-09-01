import 'dart:math' as math;

import 'package:flutter/material.dart';

class LaunchBackdrop extends StatelessWidget {
  final Widget child;
  final Animation<double> reveal;
  final Animation<double> motion;
  final Animation<double> handoff;

  const LaunchBackdrop({
    super.key,
    required this.child,
    required this.reveal,
    required this.motion,
    required this.handoff,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF7F7FC),
      child: CustomPaint(
        painter: _PremiumLaunchBackdropPainter(
          reveal: reveal,
          motion: motion,
          handoff: handoff,
        ),
        child: child,
      ),
    );
  }
}

class _PremiumLaunchBackdropPainter extends CustomPainter {
  final Animation<double> reveal;
  final Animation<double> motion;
  final Animation<double> handoff;

  _PremiumLaunchBackdropPainter({
    required this.reveal,
    required this.motion,
    required this.handoff,
  }) : super(repaint: Listenable.merge([reveal, motion, handoff]));

  static const _navy = Color(0xFF071A47);
  static const _navyDeep = Color(0xFF031338);
  static const _orange = Color(0xFFFF8A2A);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final revealT = Curves.easeOutCubic.transform(
      reveal.value.clamp(0.0, 1.0),
    );
    final motionT = motion.value.clamp(0.0, 1.0);
    final exitT = Curves.easeInOutCubic.transform(
      handoff.value.clamp(0.0, 1.0),
    );

    final lightPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFF7F9FF),
          Color(0xFFFCFBFF),
          Color(0xFFF5F0FB),
        ],
        stops: [0, 0.48, 1],
      ).createShader(rect);
    canvas.drawRect(rect, lightPaint);

    _drawSoftTopLayers(canvas, size, revealT, motionT, exitT);

    // Once the scene has settled, only a few pixels of slow wave drift remain.
    // During handoff the navy layer gently retreats downward, revealing the
    // same light surface used by onboarding underneath.
    final settledMotion = ((motionT - 0.48) / 0.52).clamp(0.0, 1.0);
    final ambientDrift = math.sin(settledMotion * math.pi * 1.35) * 3.2;
    final startY = size.height *
            (1.02 - (0.36 * revealT) + (0.17 * exitT)) +
        ambientDrift;

    final wavePath = Path()
      ..moveTo(0, startY - (size.height * 0.035 * revealT))
      ..cubicTo(
        size.width * 0.18,
        startY + (size.height * 0.045 * revealT),
        size.width * 0.48,
        startY + (size.height * 0.035 * revealT),
        size.width * 0.68,
        startY - (size.height * 0.045 * revealT),
      )
      ..cubicTo(
        size.width * 0.82,
        startY - (size.height * 0.105 * revealT),
        size.width * 0.93,
        startY - (size.height * 0.135 * revealT),
        size.width,
        startY - (size.height * 0.10 * revealT),
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final navyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(_navy, const Color(0xFF0A2257), settledMotion * 0.20)!,
          _navyDeep,
        ],
        stops: const [0, 1],
      ).createShader(rect);
    canvas.drawPath(wavePath, navyPaint);

    if (revealT > 0.02 && exitT < 0.995) {
      final accentPath = Path()
        ..moveTo(0, startY - (size.height * 0.035 * revealT))
        ..cubicTo(
          size.width * 0.18,
          startY + (size.height * 0.045 * revealT),
          size.width * 0.48,
          startY + (size.height * 0.035 * revealT),
          size.width * 0.68,
          startY - (size.height * 0.045 * revealT),
        )
        ..cubicTo(
          size.width * 0.82,
          startY - (size.height * 0.105 * revealT),
          size.width * 0.93,
          startY - (size.height * 0.135 * revealT),
          size.width,
          startY - (size.height * 0.10 * revealT),
        );

      final visible = revealT * (1 - exitT);
      final glowPulse = 0.84 + (0.16 * math.sin(motionT * math.pi * 2.2));

      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
        ..color = _orange.withValues(
          alpha: 0.30 * visible * glowPulse,
        );
      canvas.drawPath(accentPath, glowPaint);

      final accentPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7
        ..shader = LinearGradient(
          colors: [
            const Color(0x00FF8A2A),
            const Color(0xFFFFA251).withValues(alpha: visible),
            const Color(0xFFFF7A00).withValues(alpha: visible),
            const Color(0x00FF8A2A),
          ],
          stops: const [0.08, 0.46, 0.78, 1],
        ).createShader(rect);
      canvas.drawPath(accentPath, accentPaint);

      _drawLowerDotField(canvas, size, visible);
    }
  }

  void _drawSoftTopLayers(
    Canvas canvas,
    Size size,
    double revealT,
    double motionT,
    double exitT,
  ) {
    final visible = revealT * (1 - (exitT * 0.55));
    final drift = math.sin(motionT * math.pi) * 4.0;

    final layerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.72 * visible);

    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..color = const Color(0xFF8EA2C5).withValues(alpha: 0.11 * visible);

    final path = Path()
      ..moveTo(-size.width * 0.08, size.height * 0.22 + drift)
      ..cubicTo(
        size.width * 0.06,
        size.height * 0.05 + drift,
        size.width * 0.30,
        -size.height * 0.02 + drift,
        size.width * 0.55,
        size.height * 0.02 + drift,
      );
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, layerPaint);

    final secondary = Path()
      ..moveTo(-size.width * 0.10, size.height * 0.36 + drift)
      ..cubicTo(
        size.width * 0.15,
        size.height * 0.18 + drift,
        size.width * 0.18,
        size.height * 0.02 + drift,
        size.width * 0.42,
        -size.height * 0.03 + drift,
      );
    canvas.drawPath(secondary, layerPaint);

    final glowRect = Rect.fromCircle(
      center: Offset(size.width * 0.62, size.height * 0.38),
      radius: math.max(size.width, size.height) * 0.26,
    );
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF8A2A).withValues(alpha: 0.075 * visible),
          const Color(0xFF6847F5).withValues(alpha: 0.035 * visible),
          Colors.transparent,
        ],
        stops: const [0, 0.48, 1],
      ).createShader(glowRect);
    canvas.drawCircle(glowRect.center, glowRect.width / 2, glowPaint);
  }

  void _drawLowerDotField(Canvas canvas, Size size, double visible) {
    final paint = Paint();
    final startX = size.width * 0.72;
    final startY = size.height * 0.74;
    final maxRows = size.height < 700 ? 9 : 12;

    for (var row = 0; row < maxRows; row++) {
      for (var column = 0; column < 8; column++) {
        final strength = ((column + row) / (maxRows + 8)).clamp(0.0, 1.0);
        paint.color = Color.lerp(
          const Color(0xFF536DA9),
          const Color(0xFFFF7B31),
          strength,
        )!
            .withValues(
          alpha: (0.06 + (0.18 * strength)) * visible,
        );
        canvas.drawCircle(
          Offset(startX + (column * 12), startY + (row * 12)),
          1.25,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumLaunchBackdropPainter oldDelegate) {
    return oldDelegate.reveal != reveal ||
        oldDelegate.motion != motion ||
        oldDelegate.handoff != handoff;
  }
}
