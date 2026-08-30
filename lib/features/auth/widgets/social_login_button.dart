import 'package:flutter/material.dart';

import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_pressable.dart';

class SocialLoginButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool loading;

  const SocialLoginButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null && !loading,
      label: 'Continue with $label',
      child: AppPressable(
        onTap: loading ? null : onPressed,
        pressedScale: 0.975,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedOpacity(
          duration: AppMotion.fast,
          opacity: onPressed == null ? 0.55 : 1,
          child: Container(
            height: 54,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.primary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon,
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
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

class SocialIconButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool loading;
  final double size;

  const SocialIconButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
    this.size = 54,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;

    return Semantics(
      button: true,
      enabled: enabled,
      label: 'Continue with $label',
      child: AppPressable(
        onTap: enabled ? onPressed : null,
        pressedScale: 0.94,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedOpacity(
          duration: AppMotion.fast,
          opacity: onPressed == null ? 0.52 : 1,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(size < 50 ? 14 : 16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2C224F).withValues(alpha: 0.035),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: AppColors.primary,
                    ),
                  )
                : icon,
          ),
        ),
      ),
    );
  }
}

class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 28,
      height: 28,
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontSize: 24,
            height: 1,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class FacebookMark extends StatelessWidget {
  const FacebookMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        'f',
        style: TextStyle(
          color: Colors.white,
          fontSize: 23,
          height: 1.12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class XMark extends StatelessWidget {
  const XMark({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'X',
      style: TextStyle(
        color: Color(0xFF111111),
        fontSize: 22,
        height: 1,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class MicrosoftMark extends StatelessWidget {
  const MicrosoftMark({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: Container(color: const Color(0xFFF25022))),
                const SizedBox(width: 2),
                Expanded(child: Container(color: const Color(0xFF7FBA00))),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: Container(color: const Color(0xFF00A4EF))),
                const SizedBox(width: 2),
                Expanded(child: Container(color: const Color(0xFFFFB900))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
