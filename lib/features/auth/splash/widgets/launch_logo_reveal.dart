import 'package:flutter/material.dart';

import '../../widgets/brand_mark.dart';

class LaunchLogoReveal extends StatelessWidget {
  final Animation<double> opacity;
  final Animation<double> scale;
  final Animation<Offset> offset;
  final Animation<double> glow;

  const LaunchLogoReveal({
    super.key,
    required this.opacity,
    required this.scale,
    required this.offset,
    required this.glow,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 360 || size.height < 650;
    final logoHeight = compact ? 158.0 : 202.0;
    final logoWidth = compact ? 212.0 : 272.0;

    return FadeTransition(
      key: const Key('launch-logo-first-frame'),
      opacity: opacity,
      alwaysIncludeSemantics: true,
      child: SlideTransition(
        position: offset,
        child: ScaleTransition(
          scale: scale,
          child: SizedBox(
            width: logoWidth + 48,
            height: logoHeight + 42,
            child: Stack(
              alignment: Alignment.center,
              children: [
                IgnorePointer(
                  child: AnimatedBuilder(
                    animation: glow,
                    builder: (context, child) {
                      final value = glow.value.clamp(0.0, 1.0);
                      return Opacity(
                        opacity: value,
                        child: Container(
                          width: logoWidth * 0.90,
                          height: logoHeight * 0.78,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFFFA14A)
                                    .withValues(alpha: 0.13 * value),
                                const Color(0xFF6C4DF6)
                                    .withValues(alpha: 0.07 * value),
                                Colors.transparent,
                              ],
                              stops: const [0, 0.48, 1],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                RepaintBoundary(
                  child: BrandMark(
                    height: logoHeight,
                    maxWidth: logoWidth,
                    alignment: Alignment.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
