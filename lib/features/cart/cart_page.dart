import 'package:flutter/material.dart';

import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state_card.dart';
import '../../models/cart_item.dart';
import '../checkout/checkout_page.dart';
import '../products/product_details_page.dart';
import '../wishlist/wishlist_controller.dart';
import 'cart_controller.dart';
import 'widgets/cart_checkout_bar.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_summary_card.dart';
import 'widgets/promotion_code_card.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  CartController get _cart => CartController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          AnimatedBuilder(
            animation: _cart,
            builder: (context, child) {
              if (_cart.isEmpty) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                tooltip: 'Cart options',
                onSelected: (value) {
                  if (value == 'clear') _confirmClearCart(context);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<String>(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 19),
                        SizedBox(width: 10),
                        Text('Clear cart'),
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
          animation: _cart,
          builder: (context, child) {
            if (_cart.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(top: 14, bottom: 28),
                children: const [
                  EmptyStateCard(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Your cart is waiting',
                    message:
                        'Add products you love and they will stay here ready for a secure checkout.',
                  ),
                ],
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth < 380 ? 14.0 : 20.0;
                final items = _cart.items;

                return CustomScrollView(
                  physics: const ClampingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding:
                          EdgeInsets.fromLTRB(horizontal, 10, horizontal, 0),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: _CartStatusStrip(cart: _cart),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding:
                          EdgeInsets.fromLTRB(horizontal, 14, horizontal, 0),
                      sliver: SliverList.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 820),
                              child: CartItemCard(
                                item: item,
                                onTap: () => _openProduct(context, item),
                                onIncrement: () => _cart.increment(item.key),
                                onDecrement: () {
                                  if (item.quantity <= 1) {
                                    _removeWithUndo(context, item);
                                  } else {
                                    _cart.decrement(item.key);
                                  }
                                },
                                onRemove: () => _removeWithUndo(context, item),
                                onMoveToWishlist: () =>
                                    _moveToWishlist(context, item),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SliverPadding(
                      padding:
                          EdgeInsets.fromLTRB(horizontal, 16, horizontal, 0),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: PromotionCodeCard(cart: _cart),
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding:
                          EdgeInsets.fromLTRB(horizontal, 12, horizontal, 32),
                      sliver: SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: CartSummaryCard(cart: _cart),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _cart,
        builder: (context, child) {
          if (_cart.isEmpty) return const SizedBox.shrink();
          return CartCheckoutBar(
            itemCount: _cart.totalQuantity,
            total: _cart.total,
            onCheckout: () {
              Navigator.of(context).push(
                AppPageRoute(page: const CheckoutPage()),
              );
            },
          );
        },
      ),
    );
  }

  void _openProduct(BuildContext context, CartItem item) {
    Navigator.of(context).push(
      AppPageRoute(
        page: ProductDetailsPage(
          product: item.product,
          heroTag: 'cart-product-${item.key}',
        ),
      ),
    );
  }

  void _removeWithUndo(BuildContext context, CartItem item) {
    final removed = _cart.remove(item.key);
    if (removed == null) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('${item.product.name} removed from your cart.'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () => _cart.restore(removed),
          ),
        ),
      );
  }

  void _moveToWishlist(BuildContext context, CartItem item) {
    final wishlist = WishlistController.instance;
    final wasAlreadySaved = wishlist.contains(item.product);
    wishlist.add(item.product);
    _cart.remove(item.key);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('${item.product.name} saved to your wishlist.'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              if (!wasAlreadySaved) wishlist.remove(item.product);
              _cart.restore(item);
            },
          ),
        ),
      );
  }

  Future<void> _confirmClearCart(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.shopping_bag_outlined),
          title: const Text('Clear your cart?'),
          content: const Text(
            'This removes all products currently in your cart. You can undo immediately afterwards.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Clear cart'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final previous = _cart.clear();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Text('Cart cleared.'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () => _cart.restoreAll(previous),
          ),
        ),
      );
  }
}

class _CartStatusStrip extends StatelessWidget {
  final CartController cart;

  const _CartStatusStrip({required this.cart});

  @override
  Widget build(BuildContext context) {
    final freeDelivery = cart.deliveryFee == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: freeDelivery ? AppColors.successSoft : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (freeDelivery ? AppColors.success : AppColors.primary)
              .withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              freeDelivery
                  ? Icons.local_shipping_rounded
                  : Icons.shopping_bag_rounded,
              color: freeDelivery ? AppColors.success : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cart.totalQuantity} ${cart.totalQuantity == 1 ? 'item' : 'items'} in your cart',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  freeDelivery
                      ? 'Free delivery is unlocked for this order.'
                      : 'Your cart is saved while you continue shopping.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                    height: 1.35,
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
