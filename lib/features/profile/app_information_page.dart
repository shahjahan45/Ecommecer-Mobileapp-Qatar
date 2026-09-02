import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/theme/app_theme_context.dart';

enum AppInformationType {
  about,
  privacy,
  terms,
  refund,
}

extension AppInformationTypeX on AppInformationType {
  String get title {
    switch (this) {
      case AppInformationType.about:
        return 'About Us';
      case AppInformationType.privacy:
        return 'Privacy Policy';
      case AppInformationType.terms:
        return 'Terms & Conditions';
      case AppInformationType.refund:
        return 'Refund Policy';
    }
  }

  IconData get icon {
    switch (this) {
      case AppInformationType.about:
        return Icons.storefront_outlined;
      case AppInformationType.privacy:
        return Icons.privacy_tip_outlined;
      case AppInformationType.terms:
        return Icons.gavel_outlined;
      case AppInformationType.refund:
        return Icons.replay_rounded;
    }
  }
}

class AppInformationPage extends StatelessWidget {
  final AppInformationType type;

  const AppInformationPage({
    super.key,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final content = _content(type);
    return Scaffold(
      appBar: AppBar(title: Text(type.title)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: context.dcxSurfaceMuted,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(color: context.dcxBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: context.dcxScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            alignment: Alignment.center,
                            child: Icon(type.icon, color: context.dcxScheme.onPrimaryContainer),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type.title,
                                  style: TextStyle(
                                    color: context.dcxTextPrimary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  content.intro,
                                  style: TextStyle(
                                    color: context.dcxTextSecondary,
                                    fontSize: 10.8,
                                    height: 1.4,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    for (final section in content.sections) ...[
                      Text(
                        section.$1,
                        style: TextStyle(
                          color: context.dcxTextPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        section.$2,
                        style: TextStyle(
                          color: context.dcxTextSecondary,
                          fontSize: 11,
                          height: 1.55,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (type != AppInformationType.about)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.dcxScheme.primaryContainer.withValues(alpha: .42),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Text(
                          'The production release should synchronize this screen with the store’s approved legal policy text so customers always see the authoritative version.',
                          style: TextStyle(
                            color: context.dcxTextSecondary,
                            fontSize: 10.3,
                            height: 1.45,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

({String intro, List<(String, String)> sections}) _content(AppInformationType type) {
  switch (type) {
    case AppInformationType.about:
      return (
        intro: 'A focused shopping experience designed around clarity, trust and convenience.',
        sections: <(String, String)>[
          (
            'DCX Online Store',
            'DCX Online Store brings product discovery, wishlist, secure checkout, promotions, order tracking and customer support into one consistent mobile experience.',
          ),
          (
            'Customer-first design',
            'The app is built to reduce unnecessary steps, keep important information easy to find and provide clear feedback throughout the shopping journey.',
          ),
        ],
      );
    case AppInformationType.privacy:
      return (
        intro: 'A clear place for customers to understand how account and shopping information is handled.',
        sections: <(String, String)>[
          ('Information', 'This section is prepared for the approved description of information collected or processed by the store.'),
          ('Use and protection', 'This section is prepared for the approved explanation of how information is used, secured and retained.'),
          ('Customer choices', 'This section is prepared for the approved instructions covering access, correction and privacy choices.'),
        ],
      );
    case AppInformationType.terms:
      return (
        intro: 'A dedicated location for the store’s current shopping and account terms.',
        sections: <(String, String)>[
          ('Ordering', 'This section is prepared for approved terms related to orders, pricing, availability and acceptance.'),
          ('Payments and delivery', 'This section is prepared for approved payment, delivery and fulfillment conditions.'),
          ('Account use', 'This section is prepared for approved customer account and acceptable-use conditions.'),
        ],
      );
    case AppInformationType.refund:
      return (
        intro: 'A dedicated place for clear return, refund and exchange information.',
        sections: <(String, String)>[
          ('Eligibility', 'This section is prepared for the approved rules describing eligible products and return windows.'),
          ('Refund process', 'This section is prepared for the approved refund method, timing and verification process.'),
          ('Need help?', 'Customers can contact the Support Center directly from the app if they need assistance with an order or return.'),
        ],
      );
  }
}
