import 'package:flutter/material.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_colors.dart';
import '../login/login_page.dart';
import '../widgets/brand_mark.dart';
import '../widgets/primary_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static const _items = [
    _OnboardingItem(
      icon: Icons.storefront_rounded,
      eyebrow: 'DISCOVER',
      title: 'Everything you love,\nin one beautiful shop',
      description:
          'Browse curated products, explore categories and discover offers through a clean shopping experience.',
      accent: Color(0xFF6C4DF6),
      soft: Color(0xFFEEE9FF),
    ),
    _OnboardingItem(
      icon: Icons.local_shipping_rounded,
      eyebrow: 'TRACK',
      title: 'Know where your\norder is at every step',
      description:
          'Follow your order from confirmation to delivery with a simple status timeline and clear updates.',
      accent: Color(0xFF1677FF),
      soft: Color(0xFFE7F1FF),
    ),
    _OnboardingItem(
      icon: Icons.verified_user_rounded,
      eyebrow: 'SECURE',
      title: 'Simple checkout.\nSecure shopping.',
      description:
          'Your important order totals and stock will later be verified by Laravel before any purchase is created.',
      accent: Color(0xFF20A66A),
      soft: Color(0xFFE6F7EF),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    if (_currentPage < _items.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
      return;
    }
    _openLogin();
  }

  void _openLogin() {
    Navigator.of(context).pushReplacement(
      AppPageRoute(page: const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactHeight = constraints.maxHeight < 650;
            final compactWidth = constraints.maxWidth < 360;
            final side = compactWidth ? 14.0 : 20.0;
            final headerHeight = compactHeight ? 54.0 : 62.0;
            final footerHeight = compactHeight ? 104.0 : 118.0;

            // Stack-based composition deliberately avoids a root Flex with
            // fixed children. That makes the screen safe on short phones,
            // landscape devices, split-screen mode and unusual aspect ratios.
            return Stack(
              children: [
                Positioned.fill(
                  top: headerHeight,
                  bottom: footerHeight,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _items.length,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return _OnboardingSlide(
                        item: _items[index],
                        compact: compactHeight || compactWidth,
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 6,
                  left: side,
                  right: side,
                  child: Row(
                    children: [
                      const Expanded(child: BrandMark(compact: true)),
                      TextButton(
                        onPressed: _openLogin,
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: side,
                  right: side,
                  bottom: 8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _items.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutCubic,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: index == _currentPage ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: index == _currentPage
                                  ? AppColors.primary
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: compactHeight ? 12 : 18),
                      PrimaryButton(
                        label: _currentPage == _items.length - 1
                            ? 'Start shopping'
                            : 'Continue',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _continue,
                      ),
                    ],
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

class _OnboardingSlide extends StatelessWidget {
  final _OnboardingItem item;
  final bool compact;

  const _OnboardingSlide({
    required this.item,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final illustrationSize = compact
        ? (width * 0.48).clamp(132.0, 190.0)
        : (width * 0.62).clamp(200.0, 300.0);

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(
        width < 360 ? 14 : 20,
        compact ? 8 : 18,
        width < 360 ? 14 : 20,
        compact ? 10 : 18,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 360),
            curve: Curves.easeOutCubic,
            width: illustrationSize,
            height: illustrationSize,
            decoration: BoxDecoration(
              color: item.soft,
              borderRadius: BorderRadius.circular(compact ? 28 : 38),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: compact ? 18 : 28,
                  right: compact ? 20 : 30,
                  child: _miniDot(item.accent, 16, 0.16),
                ),
                Positioned(
                  left: compact ? 18 : 28,
                  bottom: compact ? 20 : 34,
                  child: _miniDot(item.accent, 28, 0.10),
                ),
                Container(
                  width: compact ? 88 : 130,
                  height: compact ? 88 : 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: item.accent.withValues(alpha: 0.15),
                        blurRadius: 28,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Icon(
                    item.icon,
                    color: item.accent,
                    size: compact ? 44 : 62,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 18 : 30),
          Text(
            item.eyebrow,
            style: TextStyle(
              color: item.accent,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: compact ? 22 : 28,
                  height: 1.13,
                  letterSpacing: -0.7,
                ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width < 360 ? 2 : 10),
            child: Text(
              item.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.50,
                    fontSize: compact ? 12.5 : 14,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniDot(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}

class _OnboardingItem {
  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final Color accent;
  final Color soft;

  const _OnboardingItem({
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.accent,
    required this.soft,
  });
}
