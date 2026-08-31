import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/app_pressable.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../widgets/category_card.dart';
import '../../widgets/product_card.dart';
import '../../widgets/section_header.dart';
import '../cart/cart_controller.dart';
import '../categories/categories_page.dart';
import '../products/product_details_page.dart';
import '../products/product_listing_page.dart';
import '../search/search_page.dart';
import '../notifications/notifications_page.dart';
import '../wishlist/wishlist_page.dart';
import '../wishlist/wishlist_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _bannerController =
      PageController(viewportFraction: .94);
  Timer? _bannerTimer;
  int _bannerIndex = 0;
  int _selectedCategory = 0;
  bool _loading = true;

  static const categories = <ShopCategory>[
    ShopCategory(
      name: 'All',
      icon: Icons.apps_rounded,
      accent: AppColors.primary,
      softColor: AppColors.primarySoft,
    ),
    ShopCategory(
      name: 'Phones',
      icon: Icons.smartphone_rounded,
      accent: Color(0xFF2979FF),
      softColor: Color(0xFFEAF2FF),
    ),
    ShopCategory(
      name: 'Fashion',
      icon: Icons.checkroom_rounded,
      accent: Color(0xFFEC4899),
      softColor: Color(0xFFFFEAF4),
    ),
    ShopCategory(
      name: 'Beauty',
      icon: Icons.spa_rounded,
      accent: Color(0xFF9C4DFF),
      softColor: Color(0xFFF4EAFE),
    ),
    ShopCategory(
      name: 'Home',
      icon: Icons.chair_alt_rounded,
      accent: Color(0xFFFF8C42),
      softColor: Color(0xFFFFF0E5),
    ),
    ShopCategory(
      name: 'Sports',
      icon: Icons.sports_basketball_rounded,
      accent: Color(0xFF1FA971),
      softColor: Color(0xFFE8F8F1),
    ),
  ];

  static const products = <Product>[
    Product(
      id: 1,
      name: 'AirBeat Pro Wireless Headphones',
      category: 'Electronics',
      price: 299,
      oldPrice: 349,
      rating: 4.8,
      reviews: 326,
      badge: 'Hot',
      icon: Icons.headphones_rounded,
      accent: Color(0xFF6B4EFF),
      softColor: Color(0xFFF0ECFF),
    ),
    Product(
      id: 2,
      name: 'PulseFit Smart Watch Series X',
      category: 'Wearables',
      price: 179,
      rating: 4.7,
      reviews: 218,
      favorite: true,
      badge: 'Popular',
      icon: Icons.watch_rounded,
      accent: Color(0xFF2979FF),
      softColor: Color(0xFFEAF2FF),
    ),
    Product(
      id: 3,
      name: 'CloudStep Everyday Running Shoes',
      category: 'Sports',
      price: 229,
      oldPrice: 279,
      rating: 4.9,
      reviews: 492,
      icon: Icons.directions_run_rounded,
      accent: Color(0xFF1FA971),
      softColor: Color(0xFFE8F8F1),
    ),
    Product(
      id: 4,
      name: 'Urban Carry Minimal Backpack',
      category: 'Fashion',
      price: 149,
      rating: 4.6,
      reviews: 174,
      badge: 'New',
      icon: Icons.backpack_rounded,
      accent: Color(0xFFEC4899),
      softColor: Color(0xFFFFEAF4),
    ),
    Product(
      id: 5,
      name: 'GlowCare Premium Skin Essentials',
      category: 'Beauty',
      price: 119,
      oldPrice: 145,
      rating: 4.8,
      reviews: 291,
      icon: Icons.spa_rounded,
      accent: Color(0xFF9C4DFF),
      softColor: Color(0xFFF4EAFE),
    ),
    Product(
      id: 6,
      name: 'BrewMate Smart Coffee Maker',
      category: 'Home',
      price: 249,
      rating: 4.5,
      reviews: 138,
      badge: 'Trending',
      icon: Icons.coffee_maker_rounded,
      accent: Color(0xFFFF8C42),
      softColor: Color(0xFFFFF0E5),
    ),
  ];

  static const banners = <_PromoBannerData>[
    _PromoBannerData(
      eyebrow: 'WEEKEND DROP',
      title: 'Premium picks\nup to 40% off',
      subtitle: 'Fresh deals picked for you',
      icon: Icons.shopping_bag_rounded,
      colors: [Color(0xFF5B3FF0), Color(0xFF907CFF)],
    ),
    _PromoBannerData(
      eyebrow: 'NEW ARRIVALS',
      title: 'Smarter tech.\nCleaner style.',
      subtitle: 'Explore this week’s new collection',
      icon: Icons.devices_rounded,
      colors: [Color(0xFF1267D6), Color(0xFF4EA1FF)],
    ),
    _PromoBannerData(
      eyebrow: 'FREE DELIVERY',
      title: 'More shopping.\nLess waiting.',
      subtitle: 'On selected orders this week',
      icon: Icons.local_shipping_rounded,
      colors: [Color(0xFF15845E), Color(0xFF40C08B)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _simulateInitialLoad();
    _startBannerTimer();
  }

  Future<void> _simulateInitialLoad() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _loading = false);
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_bannerController.hasClients || !mounted) return;
      final next = (_bannerIndex + 1) % banners.length;
      _bannerController.animateToPage(
        next,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$feature is currently unavailable.')),
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
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
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
    await Future<void>.delayed(const Duration(milliseconds: 650));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _HomeLoadingState();

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics()),
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
                  title: 'Shop by category',
                  subtitle: 'Find exactly what you need',
                  actionText: 'See all',
                  onAction: () {
                    Navigator.of(context)
                        .push(AppPageRoute(page: const CategoriesPage()));
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(child: _buildCategories()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 12),
                child: SectionHeader(
                  title: 'Trending now',
                  subtitle: 'Popular choices from our collection',
                  actionText: 'View all',
                  onAction: () {
                    Navigator.of(context).push(
                      AppPageRoute(
                          page: const ProductListingPage(
                              title: 'Trending products')),
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
                  title: 'Recommended for you',
                  subtitle: 'A curated selection based on your interests',
                  actionText: 'View all',
                  onAction: () {
                    Navigator.of(context).push(
                      AppPageRoute(
                          page: const ProductListingPage(
                              title: 'Recommended for you')),
                    );
                  },
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
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
                      childCount: products.length,
                    ),
                  );
                },
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on_rounded,
                      size: 16, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text(
                    'Delivering to',
                    style: TextStyle(
                      color: AppColors.textSecondary,
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
                      'Doha, Qatar',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontSize: 19),
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                ],
              ),
            ],
          ),
        ),
        AppIconButton(
          icon: Icons.notifications_none_rounded,
          showBadge: true,
          badgeText: '3',
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
              icon: count > 0
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              iconColor: count > 0 ? AppColors.danger : AppColors.textPrimary,
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded,
                color: AppColors.textSecondary, size: 23),
            const SizedBox(width: 11),
            const Expanded(
              child: Text(
                'Search products, brands and categories',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textTertiary,
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
              child: const Icon(Icons.tune_rounded,
                  color: AppColors.primary, size: 19),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
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
                child: _PromoBanner(data: banner),
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
                color: index == _bannerIndex
                    ? AppColors.primary
                    : AppColors.border,
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
      _BenefitData(
          Icons.local_shipping_outlined, 'Fast delivery', 'Across Qatar'),
      _BenefitData(
          Icons.verified_user_outlined, 'Secure checkout', 'Protected flow'),
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
                  AppPageRoute(
                      page: const ProductListingPage(title: 'All products')),
                );
              } else {
                final selected = categories[index];
                final categoryName =
                    selected.name == 'Phones' ? 'Electronics' : selected.name;
                final subcategory = selected.name == 'Phones' ? 'Phones' : null;
                Navigator.of(context).push(
                  AppPageRoute(
                    page: ProductListingPage(
                      title: selected.name,
                      categoryName: categoryName,
                      subcategoryName: subcategory,
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
        itemCount: 4,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 350;

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
              child: const Text(
                'DEAL OF THE DAY',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Smart essentials\nfor less',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                height: 1.12,
                fontWeight: FontWeight.w900,
                letterSpacing: -.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Limited-time prices on selected tech.',
              style: TextStyle(
                color: Color(0xFFAEB3C0),
                fontSize: 11.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            AppPressable(
              onTap: () => _showComingSoon('Deals'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Explore deals',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            ),
          ],
        );

        final art = Container(
          width: compact ? double.infinity : 110,
          height: compact ? 96 : 140,
          decoration: BoxDecoration(
            color: const Color(0xFF242834),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.headphones_rounded,
            size: 64,
            color: AppColors.secondary,
          ),
        );

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF171A24),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.elevated,
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [copy, const SizedBox(height: 16), art],
                )
              : Row(
                  children: [
                    Expanded(child: copy),
                    const SizedBox(width: 12),
                    art,
                  ],
                ),
        );
      },
    );
  }
}

class _PromoBanner extends StatelessWidget {
  final _PromoBannerData data;

  const _PromoBanner({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: data.colors.first.withValues(alpha: .24),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            bottom: -65,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 15,
            top: 12,
            child: Transform.rotate(
              angle: -.14,
              child: Icon(
                data.icon,
                color: Colors.white.withValues(alpha: .20),
                size: 112,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: .12)),
                ),
                child: Text(
                  data.eyebrow,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .9,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                data.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  height: 1.06,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.7,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      data.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .82),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 16),
                ],
              ),
            ],
          ),
        ],
      ),
    );
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
          AppSkeleton(
              width: double.infinity, height: 190, radius: AppRadius.xxl),
          SizedBox(height: 26),
          AppSkeleton(width: 180, height: 24),
          SizedBox(height: 14),
          SizedBox(
            height: 104,
            child: Row(
              children: [
                Expanded(
                    child: AppSkeleton(
                        width: double.infinity,
                        height: 104,
                        radius: AppRadius.lg)),
                SizedBox(width: 10),
                Expanded(
                    child: AppSkeleton(
                        width: double.infinity,
                        height: 104,
                        radius: AppRadius.lg)),
                SizedBox(width: 10),
                Expanded(
                    child: AppSkeleton(
                        width: double.infinity,
                        height: 104,
                        radius: AppRadius.lg)),
              ],
            ),
          ),
          SizedBox(height: 26),
          AppSkeleton(width: 160, height: 24),
          SizedBox(height: 14),
          AppSkeleton(
              width: double.infinity, height: 250, radius: AppRadius.xl),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
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
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoBannerData {
  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;

  const _PromoBannerData({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
  });
}

class _BenefitData {
  final IconData icon;
  final String title;
  final String subtitle;

  const _BenefitData(this.icon, this.title, this.subtitle);
}
