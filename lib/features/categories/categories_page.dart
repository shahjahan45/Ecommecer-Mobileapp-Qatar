import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_pressable.dart';
import '../../core/widgets/fade_slide_in.dart';
import '../../data/demo_catalog.dart';
import '../../models/category.dart';
import '../products/product_listing_page.dart';
import '../search/search_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  int _selectedIndex = 0;

  ShopCategory get _selectedCategory => DemoCatalog.categories[_selectedIndex];

  void _openCategory(ShopCategory category, {String? subcategory}) {
    Navigator.of(context).push(
      AppPageRoute(
        page: ProductListingPage(
          title: subcategory ?? category.name,
          categoryName: category.name,
          subcategoryName: subcategory,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = _selectedCategory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filledTonal(
              tooltip: 'Search products',
              onPressed: () {
                Navigator.of(context).push(
                  AppPageRoute(page: const SearchPage()),
                );
              },
              icon: const Icon(Icons.search_rounded),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: FadeSlideIn(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: _buildHero(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 26)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shop by department',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Choose a category to reveal its subcategories.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        AppPageRoute(
                            page: const ProductListingPage(
                                title: 'All products')),
                      );
                    },
                    child: const Text('View all'),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.crossAxisExtent;
                final columns = width >= 900
                    ? 4
                    : width >= 620
                        ? 3
                        : width < 350
                            ? 1
                            : 2;
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    mainAxisExtent: columns == 1 ? 126 : 138,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = DemoCatalog.categories[index];
                      return _CategoryDepartmentCard(
                        category: item,
                        selected: index == _selectedIndex,
                        onTap: () => setState(() => _selectedIndex = index),
                        onOpen: () => _openCategory(item),
                      );
                    },
                    childCount: DemoCatalog.categories.length,
                  ),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: AnimatedSwitcher(
                duration: AppMotion.standard,
                switchInCurve: AppMotion.standardCurve,
                child: _SubcategoryPanel(
                  key: ValueKey(category.name),
                  category: category,
                  onOpenCategory: () => _openCategory(category),
                  onOpenSubcategory: (subcategory) {
                    _openCategory(category, subcategory: subcategory);
                  },
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B3FF0), Color(0xFF8E79FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -34,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const Text(
                        'DCX SHOP COLLECTIONS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Everything organised.\nNothing hard to find.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        height: 1.12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.4,
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Browse departments and jump directly into focused product lists.',
                      style: TextStyle(
                        color: Color(0xFFEAE7FF),
                        fontSize: 11,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.grid_view_rounded,
                    color: Colors.white, size: 38),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryDepartmentCard extends StatelessWidget {
  final ShopCategory category;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onOpen;

  const _CategoryDepartmentCard({
    required this.category,
    required this.selected,
    required this.onTap,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.standard,
        curve: AppMotion.standardCurve,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? category.softColor : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected
                ? category.accent.withValues(alpha: .35)
                : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: selected ? AppShadows.soft : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: selected ? AppColors.surface : category.softColor,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: Icon(category.icon, color: category.accent, size: 22),
                ),
                const Spacer(),
                InkWell(
                  onTap: onOpen,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color:
                          selected ? AppColors.surface : AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.arrow_outward_rounded,
                      size: 17,
                      color:
                          selected ? category.accent : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 3),
            Text(
              '${category.productCount} products',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubcategoryPanel extends StatelessWidget {
  final ShopCategory category;
  final VoidCallback onOpenCategory;
  final ValueChanged<String> onOpenSubcategory;

  const _SubcategoryPanel({
    super.key,
    required this.category,
    required this.onOpenCategory,
    required this.onOpenSubcategory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category.softColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                alignment: Alignment.center,
                child: Icon(category.icon, color: category.accent, size: 25),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${category.subcategories.length} focused collections',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                  onPressed: onOpenCategory, child: const Text('View all')),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: category.subcategories
                .map(
                  (item) => ActionChip(
                    avatar:
                        Icon(category.icon, size: 16, color: category.accent),
                    label: Text(item),
                    onPressed: () => onOpenSubcategory(item),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
