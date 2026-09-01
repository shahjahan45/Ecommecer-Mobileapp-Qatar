import 'package:flutter/material.dart';

import '../../core/navigation/app_page_route.dart';
import '../../core/widgets/empty_state_card.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../cart/cart_controller.dart';
import '../products/product_details_page.dart';
import '../products/widgets/product_list_tile.dart';
import 'widgets/wishlist_hero_card.dart';
import 'widgets/wishlist_toolbar.dart';
import 'wishlist_controller.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final WishlistController _wishlist = WishlistController.instance;
  final TextEditingController _searchController = TextEditingController();

  WishlistFilter _filter = WishlistFilter.all;
  String _query = '';
  bool? _gridViewOverride;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          AnimatedBuilder(
            animation: _wishlist,
            builder: (context, child) {
              if (_wishlist.isEmpty) return const SizedBox.shrink();

              return PopupMenuButton<String>(
                tooltip: 'Wishlist options',
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: (value) {
                  if (value == 'clear') _confirmClearWishlist();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 19),
                        SizedBox(width: 10),
                        Text('Clear wishlist'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: _wishlist,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final contentWidth = constraints.maxWidth;
                final defaultGridView = contentWidth >= 700;
                final gridView = _gridViewOverride ?? defaultGridView;
                final visibleProducts = _wishlist.visibleProducts(
                  filter: _filter,
                  query: _query,
                );

                return CustomScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        contentWidth < 380 ? 16 : 20,
                        10,
                        contentWidth < 380 ? 16 : 20,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1120),
                            child: WishlistHeroCard(
                              count: _wishlist.count,
                              totalSavings: _wishlist.totalSavings,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!_wishlist.isEmpty)
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          contentWidth < 380 ? 16 : 20,
                          22,
                          contentWidth < 380 ? 16 : 20,
                          18,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1120),
                              child: WishlistToolbar(
                                searchController: _searchController,
                                onSearchChanged: (value) {
                                  setState(() => _query = value);
                                },
                                filter: _filter,
                                onFilterChanged: (value) {
                                  setState(() => _filter = value);
                                },
                                visibleCount: visibleProducts.length,
                                gridView: gridView,
                                onViewChanged: (value) {
                                  setState(() => _gridViewOverride = value);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (_wishlist.isEmpty)
                      _buildEmptySliver(
                        contentWidth: contentWidth,
                        child: EmptyStateCard(
                          icon: Icons.favorite_border_rounded,
                          title: 'Your wishlist is ready',
                          message:
                              'Save products you love and come back to them whenever you are ready to shop.',
                          actionLabel: 'Continue shopping',
                          onAction: () => Navigator.maybePop(context),
                        ),
                      )
                    else if (visibleProducts.isEmpty)
                      _buildEmptySliver(
                        contentWidth: contentWidth,
                        child: EmptyStateCard(
                          icon: Icons.manage_search_rounded,
                          title: 'No saved products match',
                          message:
                              'Try another search or reset the current wishlist filter.',
                          actionLabel: 'Reset filters',
                          onAction: _resetFilters,
                        ),
                      )
                    else if (gridView)
                      _buildGrid(visibleProducts, contentWidth)
                    else
                      _buildList(visibleProducts, contentWidth),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptySliver({
    required double contentWidth,
    required Widget child,
  }) {
    final horizontalPadding = contentWidth < 380 ? 8.0 : 12.0;

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        0,
        horizontalPadding,
        28,
      ),
      sliver: SliverToBoxAdapter(
        child: child,
      ),
    );
  }

  Widget _buildGrid(List<Product> products, double width) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        width < 380 ? 16 : 20,
        0,
        width < 380 ? 16 : 20,
        32,
      ),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.crossAxisExtent;
          final columns = available >= 1000
              ? 4
              : available >= 680
                  ? 3
                  : available < 370
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
                final heroTag = 'wishlist-grid-${product.id}';
                return ProductCard(
                  product: product,
                  heroTag: heroTag,
                  onTap: () => _openProduct(product, heroTag),
                  onAdd: product.inStock ? () => _addToCart(product) : null,
                );
              },
              childCount: products.length,
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(List<Product> products, double width) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        width < 380 ? 16 : 20,
        0,
        width < 380 ? 16 : 20,
        32,
      ),
      sliver: SliverList.separated(
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          final heroTag = 'wishlist-list-${product.id}';
          return ProductListTile(
            product: product,
            heroTag: heroTag,
            onTap: () => _openProduct(product, heroTag),
            onAdd: product.inStock ? () => _addToCart(product) : null,
          );
        },
      ),
    );
  }

  void _openProduct(Product product, Object heroTag) {
    Navigator.of(context).push(
      AppPageRoute(
        page: ProductDetailsPage(
          product: product,
          heroTag: heroTag,
        ),
      ),
    );
  }

  void _addToCart(Product product) {
    CartController.instance.add(product);
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
                  '${product.name} added to your cart.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _filter = WishlistFilter.all;
    });
  }

  Future<void> _confirmClearWishlist() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.favorite_outline_rounded),
          title: const Text('Clear your wishlist?'),
          content: const Text(
            'This removes all saved products from your wishlist. You can undo immediately afterwards.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Clear wishlist'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final previous = _wishlist.clear();
    _resetFilters();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Text('Wishlist cleared.'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () => _wishlist.restore(previous),
          ),
        ),
      );
  }
}
