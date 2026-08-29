import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_pressable.dart';
import '../../core/widgets/empty_state_card.dart';
import '../../data/demo_catalog.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../search/search_page.dart';
import 'product_filter.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/product_list_tile.dart';

enum ProductSort {
  featured,
  newest,
  priceLowHigh,
  priceHighLow,
  highestRated,
}

class ProductListingPage extends StatefulWidget {
  final String title;
  final String? categoryName;
  final String? subcategoryName;
  final String? searchQuery;

  const ProductListingPage({
    super.key,
    this.title = 'Shop',
    this.categoryName,
    this.subcategoryName,
    this.searchQuery,
  });

  @override
  State<ProductListingPage> createState() => _ProductListingPageState();
}

class _ProductListingPageState extends State<ProductListingPage> {
  bool _gridView = true;
  ProductSort _sort = ProductSort.featured;
  ProductFilter _filter = const ProductFilter();
  late String _query;
  late String? _subcategory;

  @override
  void initState() {
    super.initState();
    _query = widget.searchQuery?.trim() ?? '';
    _subcategory = widget.subcategoryName;
  }

  List<Product> get _visibleProducts {
    var items = DemoCatalog.products.where((product) {
      if (widget.categoryName != null &&
          product.category != widget.categoryName) {
        return false;
      }
      if (_subcategory != null &&
          _subcategory!.isNotEmpty &&
          product.subcategory != _subcategory) {
        return false;
      }
      if (_query.isNotEmpty &&
          !product.searchableText.contains(_query.toLowerCase())) {
        return false;
      }
      if (product.price < _filter.minPrice ||
          product.price > _filter.maxPrice) {
        return false;
      }
      if (product.rating < _filter.minRating) return false;
      if (_filter.inStockOnly && !product.inStock) return false;
      if (_filter.onSaleOnly && !product.onSale) return false;
      return true;
    }).toList();

    switch (_sort) {
      case ProductSort.featured:
        items.sort((a, b) => b.reviews.compareTo(a.reviews));
        break;
      case ProductSort.newest:
        items.sort((a, b) {
          final byNew = (b.isNew ? 1 : 0).compareTo(a.isNew ? 1 : 0);
          return byNew != 0 ? byNew : b.id.compareTo(a.id);
        });
        break;
      case ProductSort.priceLowHigh:
        items.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSort.priceHighLow:
        items.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSort.highestRated:
        items.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return items;
  }

  Future<void> _showFilters() async {
    final result = await FilterBottomSheet.show(
      context,
      initialFilter: _filter,
    );
    if (result != null && mounted) {
      setState(() => _filter = result);
    }
  }

  Future<void> _showSort() async {
    final result = await showModalBottomSheet<ProductSort>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SortSheet(selected: _sort),
    );
    if (result != null && mounted) {
      setState(() => _sort = result);
    }
  }

  void _add(Product product) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
            content: Text('${product.name} added for Phase 4 UI preview.')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final products = _visibleProducts;
    final category = widget.categoryName == null
        ? null
        : DemoCatalog.categories
            .where((item) => item.name == widget.categoryName)
            .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () {
              Navigator.of(context).push(
                AppPageRoute(page: const SearchPage()),
              );
            },
            icon: const Icon(Icons.search_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SearchSummary(
                    query: _query,
                    category: widget.categoryName,
                    resultCount: products.length,
                    onTap: () async {
                      final query = await Navigator.of(context).push<String>(
                        AppPageRoute(
                            page: SearchPage(
                                initialQuery: _query, returnQuery: true)),
                      );
                      if (query != null && mounted) {
                        setState(() => _query = query);
                      }
                    },
                  ),
                  if (category != null &&
                      category.subcategories.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: category.subcategories.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final label = index == 0
                              ? 'All'
                              : category.subcategories[index - 1];
                          final selected = index == 0
                              ? _subcategory == null
                              : _subcategory == label;
                          return ChoiceChip(
                            selected: selected,
                            label: Text(label),
                            onSelected: (_) {
                              setState(() =>
                                  _subcategory = index == 0 ? null : label);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _ControlButton(
                          icon: Icons.swap_vert_rounded,
                          label: _sortLabel(_sort),
                          onTap: _showSort,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ControlButton(
                          icon: Icons.tune_rounded,
                          label: _filter.activeCount == 0
                              ? 'Filters'
                              : 'Filters (${_filter.activeCount})',
                          active: _filter.activeCount > 0,
                          onTap: _showFilters,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            _ViewButton(
                              icon: Icons.grid_view_rounded,
                              selected: _gridView,
                              onTap: () => setState(() => _gridView = true),
                            ),
                            _ViewButton(
                              icon: Icons.view_agenda_outlined,
                              selected: !_gridView,
                              onTap: () => setState(() => _gridView = false),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
          if (products.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateCard(
                icon: Icons.search_off_rounded,
                title: 'No matching products',
                message:
                    'Try a broader search or reset one of your active filters.',
              ),
            )
          else if (_gridView)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
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
                          onTap: () => _showProductPreview(product),
                          onAdd: product.inStock ? () => _add(product) : null,
                        );
                      },
                      childCount: products.length,
                    ),
                  );
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
              sliver: SliverList.separated(
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ProductListTile(
                    product: product,
                    onTap: () => _showProductPreview(product),
                    onAdd: product.inStock ? () => _add(product) : null,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showProductPreview(Product product) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: product.softColor,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  alignment: Alignment.center,
                  child: Icon(product.icon, size: 78, color: product.accent),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    product.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Product details are intentionally reserved for Phase 5. Phase 4 focuses on professional discovery, search and filtering.',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Continue browsing'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchSummary extends StatelessWidget {
  final String query;
  final String? category;
  final int resultCount;
  final VoidCallback onTap;

  const _SearchSummary({
    required this.query,
    required this.category,
    required this.resultCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF0ECFF), Color(0xFFF8F6FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: const Color(0xFFE3DCFF)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.search_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    query.isNotEmpty
                        ? 'Results for “$query”'
                        : category == null
                            ? 'Explore all products'
                            : 'Explore $category',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$resultCount products available in this view',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 15, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: active ? AppColors.primarySoft : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
              color: active ? const Color(0xFFD8CFFF) : AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 17,
                color: active ? AppColors.primary : AppColors.textPrimary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? AppColors.primary : AppColors.textPrimary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ViewButton(
      {required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        width: 40,
        height: 42,
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 18,
          color: selected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  final ProductSort selected;

  const _SortSheet({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Sort products',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(height: 12),
              ...ProductSort.values.map((sort) {
                final isSelected = sort == selected;
                return AppPressable(
                  onTap: () => Navigator.of(context).pop(sort),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primarySoft
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFD8CFFF)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _sortLabel(sort),
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: AppMotion.fast,
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: isSelected
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 14)
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

String _sortLabel(ProductSort sort) {
  switch (sort) {
    case ProductSort.featured:
      return 'Featured';
    case ProductSort.newest:
      return 'Newest';
    case ProductSort.priceLowHigh:
      return 'Price: Low to High';
    case ProductSort.priceHighLow:
      return 'Price: High to Low';
    case ProductSort.highestRated:
      return 'Highest rated';
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
