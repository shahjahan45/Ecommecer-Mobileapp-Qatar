import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/network/session_controller.dart';
import '../../core/theme/app_colors.dart';
import 'change_password_page.dart';

class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = SessionController.instance;
    return Scaffold(
      key: const Key('account-security-page'),
      appBar: AppBar(title: const Text('Security & privacy')),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth < 380 ? 16.0 : 20.0;
            return ListView(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                10,
                horizontal,
                MediaQuery.paddingOf(context).bottom + 28,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: AnimatedBuilder(
                      animation: session,
                      builder: (context, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _SecurityHero(),
                            const SizedBox(height: 18),
                            _SecurityActionCard(
                              key: const Key('security-change-password-action'),
                              icon: Icons.password_rounded,
                              title: 'Change password',
                              description: session.isAuthenticated
                                  ? 'Update your password and disconnect other signed-in devices.'
                                  : 'Sign in before changing your account password.',
                              color: AppColors.primary,
                              softColor: AppColors.primarySoft,
                              enabled: session.isAuthenticated,
                              onTap: () => Navigator.of(context).push(
                                AppPageRoute(page: const ChangePasswordPage()),
                              ),
                            ),
                            const SizedBox(height: 10),
                            _SecurityInfoCard(
                              icon: Icons.verified_user_outlined,
                              title: 'Current account session',
                              description: session.isAuthenticated
                                  ? 'Signed in as ${session.email ?? 'your DCX customer account'}. Your API token is protected in the active app session.'
                                  : 'No customer account is currently signed in on this app session.',
                              color: AppColors.success,
                              softColor: AppColors.successSoft,
                            ),
                            const SizedBox(height: 10),
                            const _SecurityInfoCard(
                              icon: Icons.devices_other_rounded,
                              title: 'Device session protection',
                              description: 'Changing your password revokes other active mobile API sessions while keeping the current phone connected.',
                              color: AppColors.info,
                              softColor: AppColors.infoSoft,
                            ),
                            const SizedBox(height: 10),
                            const _SecurityInfoCard(
                              icon: Icons.visibility_outlined,
                              title: 'Privacy-aware account center',
                              description: 'Sensitive passwords and full payment credentials are never displayed in account summaries.',
                              color: AppColors.secondary,
                              softColor: AppColors.secondarySoft,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SecurityHero extends StatelessWidget {
  const _SecurityHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF17151D), Color(0xFF2C2940)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Color(0x24FFFFFF),
            child: Icon(Icons.shield_rounded, color: Colors.white, size: 27),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account protection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Manage password security and understand how your signed-in session is protected.',
                  style: TextStyle(
                    color: Color(0xFFD7D4E5),
                    fontSize: 11.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color softColor;
  final bool enabled;
  final VoidCallback onTap;

  const _SecurityActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.softColor,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final iconSurface = dark
        ? Color.alphaBlend(color.withValues(alpha: .16), scheme.surfaceContainer)
        : softColor;
    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: enabled ? color : scheme.onSurfaceVariant, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 11.5,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                enabled ? Icons.chevron_right_rounded : Icons.lock_outline_rounded,
                color: scheme.onSurfaceVariant,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final Color softColor;

  const _SecurityInfoCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.softColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final iconSurface = dark
        ? Color.alphaBlend(color.withValues(alpha: .16), scheme.surfaceContainer)
        : softColor;
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
