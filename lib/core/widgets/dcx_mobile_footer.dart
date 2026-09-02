import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../design_system/app_tokens.dart';
import '../theme/app_theme_context.dart';

class DcxMobileFooter extends StatelessWidget {
  final VoidCallback? onHelp;
  final VoidCallback? onContact;
  final VoidCallback? onAbout;
  final VoidCallback? onPrivacy;
  final VoidCallback? onTerms;
  final VoidCallback? onRefund;
  final VoidCallback? onFaqs;

  const DcxMobileFooter({
    super.key,
    this.onHelp,
    this.onContact,
    this.onAbout,
    this.onPrivacy,
    this.onTerms,
    this.onRefund,
    this.onFaqs,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.dcxScheme;
    final year = DateTime.now().year;

    return Column(
      key: const Key('dcx-mobile-footer'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _TrustStrip(),
        const SizedBox(height: 14),
        Material(
          color: context.dcxSurfaceMuted.withValues(alpha: context.isDarkMode ? .74 : .58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            side: BorderSide(color: context.dcxBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
            child: Column(
              children: [
                Semantics(
                  image: true,
                  label: 'DCX Online Store official logo',
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    height: 62,
                    width: 114,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    isAntiAlias: true,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Shop confidently. We are here when you need us.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.dcxTextSecondary,
                    fontSize: 10.8,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                const _SocialRow(),
                const SizedBox(height: 14),
                _FooterLinks(
                  onHelp: onHelp,
                  onContact: onContact,
                  onAbout: onAbout,
                  onPrivacy: onPrivacy,
                  onTerms: onTerms,
                  onRefund: onRefund,
                  onFaqs: onFaqs,
                ),
                const SizedBox(height: 14),
                Text(
                  '© $year DCX Online Store. All rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.dcxTextTertiary,
                    fontSize: 9.2,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  key: const Key('dcx-developer-credit'),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: context.isDarkMode ? .30 : .52),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: scheme.primary.withValues(alpha: .14)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Designed & Developed by',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.dcxTextTertiary,
                          fontSize: 9.2,
                          fontWeight: FontWeight.w700,
                          letterSpacing: .15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 5,
                        runSpacing: 2,
                        children: [
                          Text(
                            'Sajahan Mansoor',
                            key: const Key('dcx-developer-name'),
                            style: TextStyle(
                              color: context.dcxTextPrimary,
                              fontSize: 10.4,
                              height: 1.3,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text('•', style: TextStyle(color: context.dcxTextTertiary, fontSize: 9)),
                          Text(
                            'DataCubeX Technologies',
                            key: const Key('dcx-developer-company'),
                            style: TextStyle(
                              color: scheme.primary,
                              fontSize: 10.4,
                              height: 1.3,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DcxHomeBottomSection extends StatelessWidget {
  final VoidCallback? onHelp;
  final VoidCallback? onContact;
  final VoidCallback? onAbout;
  final VoidCallback? onPrivacy;
  final VoidCallback? onTerms;
  final VoidCallback? onRefund;
  final VoidCallback? onFaqs;

  const DcxHomeBottomSection({
    super.key,
    this.onHelp,
    this.onContact,
    this.onAbout,
    this.onPrivacy,
    this.onTerms,
    this.onRefund,
    this.onFaqs,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      key: const Key('dcx-home-bottom-section'),
      color: context.dcxSurfaceMuted.withValues(alpha: context.isDarkMode ? .52 : .45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: BorderSide(color: context.dcxBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
        child: Column(
          children: [
            Text(
              'Stay connected',
              style: TextStyle(
                color: context.dcxTextPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Follow DCX for product updates, offers and shopping inspiration.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.dcxTextSecondary,
                fontSize: 10.3,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 13),
            const _SocialRow(),
            const SizedBox(height: 14),
            _FooterLinks(
              onHelp: onHelp,
              onContact: onContact,
              onAbout: onAbout,
              onPrivacy: onPrivacy,
              onTerms: onTerms,
              onRefund: onRefund,
              onFaqs: onFaqs,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('dcx-trust-strip'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: context.dcxSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.dcxBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _TrustItem(
              icon: Icons.verified_user_outlined,
              title: 'Secure payments',
              caption: 'Safe checkout',
              tint: context.dcxScheme.tertiary,
            ),
          ),
          _VerticalDivider(color: context.dcxBorder),
          Expanded(
            child: _TrustItem(
              icon: Icons.local_shipping_outlined,
              title: 'Fast delivery',
              caption: 'Reliable service',
              tint: context.dcxScheme.primary,
            ),
          ),
          _VerticalDivider(color: context.dcxBorder),
          Expanded(
            child: _TrustItem(
              icon: Icons.replay_rounded,
              title: 'Easy returns',
              caption: 'Simple support',
              tint: context.dcxScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  final Color color;

  const _VerticalDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      color: color,
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String caption;
  final Color tint;

  const _TrustItem({
    required this.icon,
    required this.title,
    required this.caption,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: tint.withValues(alpha: context.isDarkMode ? .18 : .10),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 17, color: tint),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.dcxTextPrimary,
            fontSize: 8.8,
            height: 1.15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          caption,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.dcxTextTertiary,
            fontSize: 7.8,
            height: 1.15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'DCX Online Store social channels',
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 10,
        runSpacing: 8,
        children: const [
          _SocialGlyph(label: 'Facebook', icon: FontAwesomeIcons.facebookF),
          _SocialGlyph(label: 'Instagram', icon: FontAwesomeIcons.instagram),
          _SocialGlyph(label: 'YouTube', icon: FontAwesomeIcons.youtube),
          _SocialGlyph(label: 'TikTok', icon: FontAwesomeIcons.tiktok),
        ],
      ),
    );
  }
}

class _SocialGlyph extends StatelessWidget {
  final String label;
  final FaIconData icon;

  const _SocialGlyph({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Tooltip(
        message: label,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: context.dcxSurface,
            shape: BoxShape.circle,
            border: Border.all(color: context.dcxBorder),
          ),
          alignment: Alignment.center,
          child: FaIcon(icon, size: 15, color: context.dcxTextPrimary),
        ),
      ),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  final VoidCallback? onHelp;
  final VoidCallback? onContact;
  final VoidCallback? onAbout;
  final VoidCallback? onPrivacy;
  final VoidCallback? onTerms;
  final VoidCallback? onRefund;
  final VoidCallback? onFaqs;
  final bool compact;

  const _FooterLinks({
    this.onHelp,
    this.onContact,
    this.onAbout,
    this.onPrivacy,
    this.onTerms,
    this.onRefund,
    this.onFaqs,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: compact ? 4 : 6,
      runSpacing: compact ? 2 : 4,
      children: [
        _FooterLink(label: 'Help & Support', onTap: onHelp),
        _FooterLink(label: 'Contact Us', onTap: onContact),
        _FooterLink(label: 'About Us', onTap: onAbout),
        _FooterLink(label: 'Privacy Policy', onTap: onPrivacy),
        _FooterLink(label: 'Terms & Conditions', onTap: onTerms),
        _FooterLink(label: 'Refund Policy', onTap: onRefund),
        _FooterLink(label: 'FAQs', onTap: onFaqs),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _FooterLink({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: onTap == null ? context.dcxTextSecondary : context.dcxScheme.primary,
      fontSize: 9.4,
      fontWeight: FontWeight.w800,
    );
    if (onTap == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Text(label, style: style),
      );
    }
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(label, style: style),
        ),
      ),
    );
  }
}
