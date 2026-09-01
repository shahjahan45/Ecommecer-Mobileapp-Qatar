import 'package:flutter/material.dart';

/// Dedicated splash-to-onboarding handoff.
///
/// The incoming page is already the same light surface as the splash. A soft
/// fade-through, tiny upward settle and near-imperceptible scale make it feel
/// like the onboarding experience is emerging from the launch scene rather
/// than replacing it.
class LaunchHandoffRoute<T> extends PageRouteBuilder<T> {
  LaunchHandoffRoute({
    required Widget page,
    required bool reduceMotion,
    Duration duration = const Duration(milliseconds: 650),
  }) : super(
          opaque: false,
          barrierColor: Colors.transparent,
          transitionDuration: reduceMotion ? Duration.zero : duration,
          reverseTransitionDuration:
              reduceMotion ? Duration.zero : const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
          ) {
            if (reduceMotion || MediaQuery.disableAnimationsOf(context)) {
              return child;
            }

            final fade = CurvedAnimation(
              parent: animation,
              curve: const Interval(0.04, 0.90, curve: Curves.easeOutCubic),
              reverseCurve: Curves.easeInCubic,
            );
            final spatial = CurvedAnimation(
              parent: animation,
              curve: const Interval(0, 1, curve: Curves.easeOutCubic),
              reverseCurve: Curves.easeInCubic,
            );

            return FadeTransition(
              opacity: fade,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.018),
                  end: Offset.zero,
                ).animate(spatial),
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.992, end: 1).animate(spatial),
                  alignment: Alignment.center,
                  child: child,
                ),
              ),
            );
          },
        );
}
