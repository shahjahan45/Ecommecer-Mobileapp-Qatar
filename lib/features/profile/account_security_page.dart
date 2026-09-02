import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/theme/app_colors.dart';

class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    constraints: BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SecurityHero(),
                        SizedBox(height: 18),
                        _SecurityInfoCard(
                          icon: Icons.lock_outline_rounded,
                          title: 'Sign-in protection',
                          description: 'Your account access is separated from shopping data and protected by the sign-in flow.',
                          color: AppColors.primary,
                          softColor: AppColors.primarySoft,
                        ),
                        SizedBox(height: 10),
                        _SecurityInfoCard(
                          icon: Icons.verified_user_outlined,
                          title: 'Protected checkout',
                          description: 'Checkout keeps delivery and payment choices inside the secured shopping flow.',
                          color: AppColors.success,
                          softColor: AppColors.successSoft,
                        ),
                        SizedBox(height: 10),
                        _SecurityInfoCard(
                          icon: Icons.visibility_outlined,
                          title: 'Privacy-aware account center',
                          description: 'Sensitive payment details are not displayed in full inside account summaries.',
                          color: AppColors.info,
                          softColor: AppColors.infoSoft,
                        ),
                      ],
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
                  'Clear security information without exposing sensitive account details.',
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
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: softColor,
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
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
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
