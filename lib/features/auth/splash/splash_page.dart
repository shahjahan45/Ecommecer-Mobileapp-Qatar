import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/launch_handoff_route.dart';
import '../onboarding/onboarding_page.dart';
import 'widgets/launch_backdrop.dart';
import 'widgets/launch_logo_reveal.dart';
import 'widgets/launch_progress_indicator.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  static const _launchDuration = Duration(milliseconds: 3000);
  static const _handoffDuration = Duration(milliseconds: 650);
  static const _navigationDelay = Duration(milliseconds: 3150);

  late final AnimationController _controller;
  late final AnimationController _handoffController;

  late final Animation<double> _sceneReveal;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<Offset> _logoOffset;
  late final Animation<double> _logoGlow;
  late final Animation<double> _copyOpacity;
  late final Animation<Offset> _copyOffset;
  late final Animation<double> _progress;
  late final Animation<double> _handoffOpacity;
  late final Animation<double> _handoffScale;
  late final Animation<Offset> _handoffOffset;

  Timer? _navigationTimer;
  bool _launchStarted = false;
  bool _handoffStarted = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _launchDuration,
    );

    _handoffController = AnimationController(
      vsync: this,
      duration: _handoffDuration,
    );

    // Exit is deliberately restrained. The background wave also retreats
    // during this controller, so the entire scene does not simply disappear.
    _handoffOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _handoffController,
        curve: const Interval(0.18, 1, curve: Curves.easeInOutCubic),
      ),
    );

    _handoffScale = Tween<double>(begin: 1, end: 1.018).animate(
      CurvedAnimation(
        parent: _handoffController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _handoffOffset = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.012),
    ).animate(
      CurvedAnimation(
        parent: _handoffController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // A three-second staged opening makes the motion readable without feeling
    // like an artificial loading delay. The handoff adds ~650 ms, giving the
    // requested 3-4 second premium opening sequence overall.
    _sceneReveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.56, curve: Curves.easeOutCubic),
    );

    // Keep the brand mark already visible on Flutter's very first frame so
    // Android's native splash can hand off to the same logo without a blank
    // flash. The small opacity lift is still perceptible but never drops the
    // logo out between the native and Flutter surfaces.
    _logoOpacity = Tween<double>(begin: 0.94, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.24, curve: Curves.easeOutCubic),
      ),
    );

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.87, end: 1.025).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 62,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.025, end: 1).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: 38,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.03, 0.46),
      ),
    );

    _logoOffset = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, 0.075),
          end: const Offset(0, -0.008),
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 72,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: const Offset(0, -0.008),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 28,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.02, 0.50),
      ),
    );

    _logoGlow = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 58,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.62).chain(
          CurveTween(curve: Curves.easeInOutCubic),
        ),
        weight: 42,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.06, 0.62),
      ),
    );

    _copyOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.50, curve: Curves.easeOutCubic),
    );

    _copyOffset = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.24, 0.53, curve: Curves.easeOutCubic),
      ),
    );

    _progress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.34, 0.93, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_launchStarted) return;
    _launchStarted = true;

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _controller.value = 1;
      _scheduleNavigation(const Duration(milliseconds: 360));
    } else {
      _controller.forward();
      _scheduleNavigation(_navigationDelay);
    }
  }

  void _scheduleNavigation(Duration delay) {
    _navigationTimer?.cancel();
    _navigationTimer = Timer(delay, _openOnboarding);
  }

  void _openOnboarding() {
    if (!mounted || _handoffStarted) return;
    _handoffStarted = true;

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (!reduceMotion) {
      _handoffController.forward();
    }

    Navigator.of(context).pushReplacement(
      LaunchHandoffRoute(
        page: const OnboardingPage(),
        reduceMotion: reduceMotion,
        duration: _handoffDuration,
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    _handoffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 360 || size.height < 650;
    final veryCompact = size.height < 590;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: FadeTransition(
        key: const Key('launch-handoff-transition'),
        opacity: _handoffOpacity,
        alwaysIncludeSemantics: true,
        child: SlideTransition(
          position: _handoffOffset,
          child: ScaleTransition(
            scale: _handoffScale,
            alignment: Alignment.center,
            child: Scaffold(
              backgroundColor: const Color(0xFFF7F7FC),
              body: LaunchBackdrop(
                reveal: _sceneReveal,
                motion: _controller,
                handoff: _handoffController,
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Align(
                            alignment:
                                Alignment(0, veryCompact ? -0.22 : -0.18),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 22 : 30,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  LaunchLogoReveal(
                                    opacity: _logoOpacity,
                                    scale: _logoScale,
                                    offset: _logoOffset,
                                    glow: _logoGlow,
                                  ),
                                  SizedBox(height: compact ? 8 : 12),
                                  FadeTransition(
                                    opacity: _copyOpacity,
                                    alwaysIncludeSemantics: true,
                                    child: SlideTransition(
                                      position: _copyOffset,
                                      child: _LaunchCopy(compact: compact),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment(0, veryCompact ? 0.78 : 0.80),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                24,
                                0,
                                24,
                                compact ? 12 : 20,
                              ),
                              child: FadeTransition(
                                opacity: _copyOpacity,
                                alwaysIncludeSemantics: true,
                                child: LaunchProgressIndicator(
                                  progress: _progress,
                                  compact: compact,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LaunchCopy extends StatelessWidget {
  final bool compact;

  const _LaunchCopy({required this.compact});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontSize: compact ? 26 : 32,
          height: 1.05,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          color: const Color(0xFF08183C),
        );

    return Semantics(
      label: 'Smart Shopping. Better. Faster. Smarter.',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: 'Smart ', style: titleStyle),
                  TextSpan(
                    text: 'Shopping',
                    style: titleStyle?.copyWith(
                      color: const Color(0xFFFF7A00),
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: compact ? 8 : 10),
            Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: compact ? 14.5 : 16,
                      color: const Color(0xFF34405D),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.05,
                    ),
                children: const [
                  TextSpan(text: 'Better'),
                  TextSpan(
                    text: '  •  ',
                    style: TextStyle(color: Color(0xFFFF7A00)),
                  ),
                  TextSpan(text: 'Faster'),
                  TextSpan(
                    text: '  •  ',
                    style: TextStyle(color: Color(0xFFFF7A00)),
                  ),
                  TextSpan(text: 'Smarter'),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
