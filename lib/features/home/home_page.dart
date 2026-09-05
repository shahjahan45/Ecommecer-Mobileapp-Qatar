import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/storefront/storefront_controller.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/app_pressable.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../core/widgets/storefront_image.dart';
import '../../core/widgets/dcx_mobile_footer.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/promotion.dart';
import '../../models/storefront_banner.dart';
import '../../widgets/category_card.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';
import '../cart/cart_controller.dart';
import '../categories/categories_page.dart';
import '../products/product_details_page.dart';
import '../products/product_listing_page.dart';
import '../search/search_page.dart';
import '../notifications/notifications_page.dart';
import '../notifications/widgets/notification_badge_icon.dart';
import '../wishlist/wishlist_page.dart';
import '../wishlist/wishlist_controller.dart';
import '../profile/address/address_book_controller.dart';
import '../profile/address_book_page.dart';
import '../profile/app_information_page.dart';
import '../profile/help_support_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AddressBookController _addressBook = AddressBookController.instance;
  final PageController _bannerController = PageController(viewportFraction: .94);
  Timer? _bannerTimer;
  int _bannerIndex = 0;
  int _selectedCategory = 0;
  bool _loading = true;
  final StorefrontController _storefront = StorefrontController.instance;

  static const ShopCategory _allCategory = ShopCategory(
    name: 'All',
    slug: 'all',
    icon: Icons.apps_rounded,
    accent: AppColors.primary,
    softColor: AppColors.primarySoft,
  );

  List<ShopCategory> get categories => <ShopCategory>[_allCategory, ..._storefront.categories];
  List<Product> get products => _storefront.products;
  List<StorefrontBanner> get banners => _storefront.banners;

  @override
  void initState() {
    super.initState();
    _addressBook.addListener(_handleAddressBookChanged);
    _storefront.addListener(_handleStorefrontChanged);
    _storefront.start();
    _addressBook.load();
    _simulateInitialLoad();
    _startBannerTimer();
  }

  Future<void> _simulateInitialLoad() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_bannerController.hasClients || !mounted || banners.length < 2) {
        return;
      }
      final next = (_bannerIndex + 1) % banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _handleAddressBookChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleStorefrontChanged() {
    if (!mounted) {
      return;
    }
    setState(() {
      if (_selectedCategory >= categories.length) {
        _selectedCategory = 0;
      }
      if (_bannerIndex >= banners.length) {
        _bannerIndex = 0;
      }
    });
  }

  @override
  void dispose() {
    _addressBook.removeListener(_handleAddressBookChanged);
    _storefront.removeListener(_handleStorefrontChanged);
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _openBanner(StorefrontBanner banner) async {
    switch (banner.linkType) {
      case 'product':
        final id = int.tryParse(banner.linkValue);
        final product = id == null ? null : _storefront.productById(id);
        if (product != null) {
          _openProductDetails(product, heroTag: 'banner-product-${product.id}');
          return;
        }
        break;
      case 'category':
        ShopCategory? selected;
        for (final category in _storefront.categories) {
          if (category.slug == banner.linkValue || category.name == banner.linkValue) {
            selected = category;
            break;
          }
        }
        if (selected != null) {
          Navigator.of(context).push(
            AppPageRoute(
              page: ProductListingPage(
                title: selected.name,
                categoryName: selected.name,
              ),
            ),
          );
          return;
        }
        break;
      case 'catalog':
        Navigator.of(context).push(
          AppPageRoute(page: const ProductListingPage(title: 'Shop')),
        );
        return;
      case 'url':
        final uri = Uri.tryParse(banner.linkValue.trim());
        if (uri != null && uri.hasScheme) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
        break;
    }
    Navigator.of(context).push(
      AppPageRoute(page: const ProductListingPage(title: 'Shop')),
    );
  }

  void _openProductDetails(
    Product product, {
    required Object heroTag,
  }) {
    Navigator.of(context).push(
      AppPageRoute(
        page: ProductDetailsPage(
          product: product,
          heroTag: heroTag,
        ),
      ),
    );
  }

  void _showAdded(Product product) {
    final quantity = CartController.instance.add(product);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  quantity >= product.stockQuantity
                      ? '${product.name} is at the available stock limit in your cart.'
                      : '${product.name} added to your cart.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
  }

  Future<void> _refresh() async {
    await _storefront.refresh(force: true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _HomeLoadingState();
    }

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          slivers: [
            SliverToBoxAdapter(
              child: FadeSlideIn(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildHeader(context),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeSlideIn(
                delayMilliseconds: 50,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: _buildSearchBar(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeSlideIn(
                delayMilliseconds: 100,
                child: _buildBannerCarousel(),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeSlideIn(
                delayMilliseconds: 140,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                  child: _buildQuickBenefits(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 10),
                child: SectionHeader(
                  title: _storefront.settingString('home', 'category_title', 'Shop by category'),
                  subtitle: _storefront.settingString('home', 'category_subtitle', 'Find exactly what you need'),
                  actionText: 'See all',
                  onAction: () {
                    Navigator.of(context).push(AppPageRoute(page: const CategoriesPage()));
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                child: SectionHeader(
                  title: _storefront.settingString('home', 'trending_title', 'Trending now'),
                  subtitle: _storefront.settingString('home', 'trending_subtitle', 'Popular choices from our collection'),
                  actionText: 'View all',
                  onAction: () {
                    Navigator.of(context).push(
                      AppPageRoute(page: const ProductListingPage(title: 'Trending products')),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildTrendingProducts()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: _buildDealCard(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: SectionHeader(
                  title: _storefront.settingString('home', 'recommended_title', 'Recommended for you'),
                  subtitle: _storefront.settingString('home', 'recommended_subtitle', 'A curated selection from our live catalog'),
                  actionText: 'View all',
                  onAction: () {
                    Navigator.of(context).push(
                      AppPageRoute(page: const ProductListingPage(title: 'Recommended for you')),
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final columns = width >= 1000
                      ? 4
                      : width >= 680
                          ? 3
                          : width < 370
                              ? 1
                              : 2;
                  final cardHeight = columns == 1 ? 330.0 : 300.0;

                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      mainAxisExtent: cardHeight,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = products[index];
                        return ProductCard(
                          product: product,
                          heroTag: 'home-recommended-${product.id}',
                          onTap: () => _openProductDetails(
                            product,
                            heroTag: 'home-recommended-${product.id}',
                          ),
                          onAdd: () => _showAdded(product),
                        );
                      },
                      childCount: products.take(8).length,
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                child: DcxHomeBottomSection(
                  onHelp: () => Navigator.of(context).push(
                    AppPageRoute(page: const HelpSupportPage()),
                  ),
                  onContact: () => Navigator.of(context).push(
                    AppPageRoute(page: const HelpSupportPage()),
                  ),
                  onAbout: () => Navigator.of(context).push(
                    AppPageRoute(
                      page: const AppInformationPage(type: AppInformationType.about),
                    ),
                  ),
                  onPrivacy: () => Navigator.of(context).push(
                    AppPageRoute(
                      page: const AppInformationPage(type: AppInformationType.privacy),
                    ),
                  ),
                  onTerms: () => Navigator.of(context).push(
                    AppPageRoute(
                      page: const AppInformationPage(type: AppInformationType.terms),
                    ),
                  ),
                  onRefund: () => Navigator.of(context).push(
                    AppPageRoute(
                      page: const AppInformationPage(type: AppInformationType.refund),
                    ),
                  ),
                  onFaqs: () => Navigator.of(context).push(
                    AppPageRoute(page: const HelpSupportPage()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            key: const Key('home-delivery-location'),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            onTap: () {
              Navigator.of(context).push(
                AppPageRoute(page: const AddressBookPage()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Delivering to',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _addressBook.defaultAddress == null
                              ? _storefront.settingString('general', 'default_location', 'Doha, Qatar')
                              : '${_addressBook.defaultAddress!.label} • ${_addressBook.defaultAddress!.addressLine}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 19),
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        NotificationBadgeIcon(
          onTap: () {
            Navigator.of(context).push(
              AppPageRoute(page: const NotificationsPage()),
            );
          },
        ),
        const SizedBox(width: 10),
        AnimatedBuilder(
          animation: WishlistController.instance,
          builder: (context, child) {
            final count = WishlistController.instance.count;
            return AppIconButton(
              icon: count > 0 ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              iconColor: count > 0 ? AppColors.danger : Theme.of(context).colorScheme.onSurface,
              showBadge: count > 0,
              badgeText: count > 99 ? '99+' : '$count',
              onTap: () {
                Navigator.of(context).push(
                  AppPageRoute(page: const WishlistPage()),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return AppPressable(
      onTap: () {
        Navigator.of(context).push(AppPageRoute(page: const SearchPage()));
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
          boxShadow: Theme.of(context).brightness == Brightness.dark ? null : AppShadows.soft,
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 23),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                'Search products, brands and categories',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: .72),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 19),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    if (banners.isEmpty) {
      return const SizedBox.shrink();
    }
    final width = MediaQuery.sizeOf(context).width;
    final bannerHeight = width < 360 ? 210.0 : 190.0;

    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: bannerHeight,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: banners.length,
            onPageChanged: (index) => setState(() => _bannerIndex = index),
            itemBuilder: (context, index) {
              final banner = banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _PromoBanner(data: banner, onTap: () {
                  unawaited(_openBanner(banner));
                }),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (index) => AnimatedContainer(
              duration: AppMotion.standard,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: index == _bannerIndex ? 24 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: index == _bannerIndex ? AppColors.primary : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickBenefits() {
    const benefits = [
      _BenefitData(Icons.local_shipping_outlined, 'Fast delivery', 'Across Qatar'),
      _BenefitData(Icons.verified_user_outlined, 'Secure checkout', 'Protected flow'),
      _BenefitData(Icons.support_agent_rounded, 'Easy support', 'We are here'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 350) {
          return SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              itemCount: benefits.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final item = benefits[index];
                return SizedBox(width: 118, child: _BenefitCard(item: item));
              },
            ),
          );
        }

        return Row(
          children: benefits.asMap().entries.map((entry) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: entry.key == benefits.length - 1 ? 0 : 8,
                ),
                child: _BenefitCard(item: entry.value),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 116,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return CategoryCard(
            category: categories[index],
            selected: index == _selectedCategory,
            onTap: () {
              setState(() => _selectedCategory = index);
              if (index == 0) {
                Navigator.of(context).push(
                  AppPageRoute(page: const ProductListingPage(title: 'All products')),
                );
              } else {
                final selected = categories[index];
                Navigator.of(context).push(
                  AppPageRoute(
                    page: ProductListingPage(
                      title: selected.name,
                      categoryName: selected.name,
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildTrendingProducts() {
    return SizedBox(
      height: 310,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: products.length < 4 ? products.length : 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: 188,
            child: ProductCard(
              product: product,
              heroTag: 'home-trending-${product.id}',
              onTap: () => _openProductDetails(
                product,
                heroTag: 'home-trending-${product.id}',
              ),
              onAdd: () => _showAdded(product),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDealCard() {
    final promotion = _storefront.promotions.isEmpty ? null : _storefront.promotions.first;
    if (promotion == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 350;
        final saving = switch (promotion.type) {
          PromotionType.percentage => '${promotion.value.toStringAsFixed(promotion.value % 1 == 0 ? 0 : 1)}% off',
          PromotionType.fixedAmount => 'QAR ${promotion.value.toStringAsFixed(0)} off',
          PromotionType.freeDelivery => 'Free delivery',
        };
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: .16),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                promotion.code,
                style: const TextStyle(color: AppColors.secondary, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: .7),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              promotion.title.isEmpty ? saving : promotion.title,
              style: const TextStyle(color: Colors.white, fontSize: 22, height: 1.12, fontWeight: FontWeight.w900, letterSpacing: -.5),
            ),
            const SizedBox(height: 8),
            Text(
              promotion.description.isEmpty ? saving : promotion.description,
              style: const TextStyle(color: Color(0xFFAEB3C0), fontSize: 11.5, height: 1.4, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 14),
            AppPressable(
              onTap: () => Navigator.of(context).push(AppPageRoute(page: const ProductListingPage(title: 'Offers'))),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.sm)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('Explore offer', style: TextStyle(color: AppColors.textPrimary, fontSize: 11.5, fontWeight: FontWeight.w800)), SizedBox(width: 6), Icon(Icons.arrow_forward_rounded, size: 16)]),
              ),
            ),
          ],
        );
        final art = Container(
          width: compact ? double.infinity : 110,
          height: compact ? 96 : 140,
          decoration: BoxDecoration(color: const Color(0xFF242834), borderRadius: BorderRadius.circular(AppRadius.lg)),
          alignment: Alignment.center,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.local_offer_rounded, size: 48, color: AppColors.secondary), const SizedBox(height: 7), Text(saving, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900))]),
        );
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF171A24), borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: AppShadows.elevated),
          child: compact ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [copy, const SizedBox(height: 16), art]) : Row(children: [Expanded(child: copy), const SizedBox(width: 12), art]),
        );
      },
    );
  }

}

class _PromoBanner extends StatelessWidget {
  final StorefrontBanner data;
  final VoidCallback? onTap;

  const _PromoBanner({required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [data.startColor, data.endColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [BoxShadow(color: data.startColor.withValues(alpha: .24), blurRadius: 28, offset: const Offset(0, 14))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (data.imageUrl != null)
            Positioned.fill(
              child: Opacity(
                opacity: .30,
                child: StorefrontImage(url: data.imageUrl, fit: BoxFit.cover, fallback: const SizedBox.shrink()),
              ),
            ),
          Positioned(right: -30, bottom: -65, child: Container(width: 190, height: 190, decoration: BoxDecoration(color: Colors.white.withValues(alpha: .10), shape: BoxShape.circle))),
          Positioned(right: 15, top: 12, child: Transform.rotate(angle: -.14, child: Icon(Icons.shopping_bag_rounded, color: Colors.white.withValues(alpha: .20), size: 112))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.eyebrow.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: .16), borderRadius: BorderRadius.circular(AppRadius.pill), border: Border.all(color: Colors.white.withValues(alpha: .12))),
                  child: Text(data.eyebrow, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: .9)),
                ),
              const SizedBox(height: 12),
              Text(data.title, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 25, height: 1.06, fontWeight: FontWeight.w900, letterSpacing: -.7)),
              const Spacer(),
              Row(children: [Expanded(child: Text(data.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withValues(alpha: .86), fontSize: 11, height: 1.3, fontWeight: FontWeight.w600))), const SizedBox(width: 6), Icon(data.ctaLabel.isNotEmpty ? Icons.arrow_forward_rounded : Icons.auto_awesome_rounded, color: Colors.white, size: 16)]),
            ],
          ),
        ],
      ),
    );
    return AppPressable(onTap: onTap, borderRadius: BorderRadius.circular(AppRadius.xxl), child: content);
  }
}

class _HomeLoadingState extends StatelessWidget {
  const _HomeLoadingState();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        children: const [
          Row(
            children: [
              Expanded(child: AppSkeleton(width: double.infinity, height: 46)),
              SizedBox(width: 10),
              AppSkeleton(width: 46, height: 46),
              SizedBox(width: 10),
              AppSkeleton(width: 46, height: 46),
            ],
          ),
          SizedBox(height: 18),
          AppSkeleton(width: double.infinity, height: 56, radius: AppRadius.lg),
          SizedBox(height: 20),
          AppSkeleton(width: double.infinity, height: 190, radius: AppRadius.xxl),
          SizedBox(height: 26),
          AppSkeleton(width: 180, height: 24),
          SizedBox(height: 14),
          SizedBox(
            height: 104,
            child: Row(
              children: [
                Expanded(child: AppSkeleton(width: double.infinity, height: 104, radius: AppRadius.lg)),
                SizedBox(width: 10),
                Expanded(child: AppSkeleton(width: double.infinity, height: 104, radius: AppRadius.lg)),
                SizedBox(width: 10),
                Expanded(child: AppSkeleton(width: double.infinity, height: 104, radius: AppRadius.lg)),
              ],
            ),
          ),
          SizedBox(height: 26),
          AppSkeleton(width: 160, height: 24),
          SizedBox(height: 14),
          AppSkeleton(width: double.infinity, height: 250, radius: AppRadius.xl),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final _BenefitData item;

  const _BenefitCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: AppColors.primary, size: 21),
          const SizedBox(height: 6),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            item.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: .72),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitData(this.icon, this.title, this.subtitle);
}
