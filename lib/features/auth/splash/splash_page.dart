import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_colors.dart';
import '../onboarding/onboarding_page.dart';
import '../widgets/brand_mark.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _scale = Tween<double>(begin: 0.86, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.7, curve: Curves.easeOut),
    );

    _controller.forward();

    _timer = Timer(const Duration(milliseconds: 1850), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        AppPageRoute(page: const OnboardingPage()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F6FF), Color(0xFFF2EEFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -75,
              child: _bubble(240, 0.10),
            ),
            Positioned(
              bottom: -100,
              left: -90,
              child: _bubble(280, 0.08),
            ),
            Center(
              child: FadeTransition(
                opacity: _fade,
                alwaysIncludeSemantics: true,
                child: ScaleTransition(
                  scale: _scale,
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BrandMark(),
                      SizedBox(height: 14),
                      Text(
                        'Shop smarter. Live better.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 42,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: opacity),
      ),
    );
  }
}
