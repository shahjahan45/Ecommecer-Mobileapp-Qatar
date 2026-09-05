import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/design_system/app_tokens.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/network/api_environment.dart';
import '../../../core/network/session_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/login/login_page.dart';
import '../../auth/services/auth_service.dart';

class AccountSignOutCard extends StatefulWidget {
  const AccountSignOutCard({super.key});

  @override
  State<AccountSignOutCard> createState() => _AccountSignOutCardState();
}

class _AccountSignOutCardState extends State<AccountSignOutCard> {
  bool _signingOut = false;

  Future<void> _handleAction() async {
    final session = SessionController.instance;
    if (!session.isAuthenticated) {
      _openLogin();
      return;
    }

    final confirmed = await _confirmSignOut();
    if (confirmed != true || !mounted) return;

    HapticFeedback.mediumImpact();
    setState(() => _signingOut = true);

    try {
      await AuthServiceFactory.create().logout();
    } catch (_) {
      // Remote token revocation is best-effort. AuthService always clears the
      // local session in a finally block so the user is never left signed in.
    }

    if (!mounted) return;
    _openLogin();
  }

  void _openLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      AppPageRoute(page: const LoginPage()),
      (route) => false,
    );
  }

  Future<bool?> _confirmSignOut() {
    final scheme = Theme.of(context).colorScheme;
    final session = SessionController.instance;
    final email = session.email?.trim();

    return showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          key: const Key('profile-sign-out-sheet'),
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: scheme.outlineVariant),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .12),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.dangerSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.danger,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sign out of DCX?',
                textAlign: TextAlign.center,
                style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                email == null || email.isEmpty
                    ? 'You will need to sign in again to access your account and sync orders.'
                    : 'You are signed in as $email. You will need to sign in again to access your account and sync orders.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 15,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      ApiEnvironment.isRemoteConfigured && !session.isDemoSession
                          ? 'Your server access token will be revoked securely.'
                          : 'Your local authenticated session will be cleared securely.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('profile-sign-out-cancel'),
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Stay signed in',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('profile-sign-out-confirm'),
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Sign out'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final session = SessionController.instance;
    final authenticated = session.isAuthenticated;
    final email = session.email?.trim();

    return Container(
      key: const Key('profile-sign-out-card'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: authenticated ? AppColors.dangerSoft : AppColors.primarySoft,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              authenticated ? Icons.logout_rounded : Icons.login_rounded,
              color: authenticated ? AppColors.danger : AppColors.primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authenticated ? 'Sign out securely' : 'Sign in to your account',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authenticated
                      ? (email == null || email.isEmpty
                          ? 'End this account session on this device'
                          : 'Signed in as $email')
                      : 'Access cloud orders, sync and account features',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            key: const Key('profile-sign-out-action'),
            onPressed: _signingOut ? null : _handleAction,
            style: FilledButton.styleFrom(
              backgroundColor: authenticated ? AppColors.danger : AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: scheme.surfaceContainerHighest,
              minimumSize: const Size(92, 44),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _signingOut
                  ? const SizedBox(
                      key: Key('profile-sign-out-loading'),
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      authenticated ? 'Sign out' : 'Sign in',
                      key: const Key('profile-sign-out-label'),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
