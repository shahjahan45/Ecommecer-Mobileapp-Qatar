import 'package:flutter/material.dart';

import '../design_system/app_tokens.dart';
import '../theme/app_colors.dart';

class AppSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const AppSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.radius = AppRadius.md,
  });

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion && _controller.isAnimating) return;

    _reduceMotion = reduceMotion;
    if (_reduceMotion) {
      _controller
        ..stop()
        ..value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final skeleton = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
    );

    if (_reduceMotion) {
      return skeleton;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment(-1.5 + value * 3, 0),
              end: Alignment(-0.5 + value * 3, 0),
              colors: const [
                AppColors.surfaceMuted,
                Color(0xFFF9FAFD),
                AppColors.surfaceMuted,
              ],
            ).createShader(rect);
          },
          child: child,
        );
      },
      child: skeleton,
    );
  }
}
