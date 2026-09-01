import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/design_system/app_tokens.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/app_pressable.dart';
import '../features/wishlist/wishlist_controller.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final Object? heroTag;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAdd,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final visualSoft = dark
        ? Color.alphaBlend(
            product.accent.withValues(alpha: .13), scheme.surfaceContainer)
        : product.softColor;

    return AppPressable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: dark ? null : AppShadows.soft,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: visualSoft,
                      gradient: LinearGradient(
                        colors: [
                          visualSoft,
                          product.accent.withValues(alpha: dark ? 0.16 : 0.10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Hero(
                      tag: heroTag ?? 'product-icon-${product.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Transform.rotate(
                          angle: -0.08,
                          child: Icon(product.icon,
                              size: 68, color: product.accent),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: AnimatedBuilder(
                      animation: WishlistController.instance,
                      builder: (context, child) {
                        final favorite =
                            WishlistController.instance.contains(product);
                        return Semantics(
                          button: true,
                          label: favorite
                              ? 'Remove ${product.name} from wishlist'
                              : 'Add ${product.name} to wishlist',
                          child: AppPressable(
                            onTap: () =>
                                WishlistController.instance.toggle(product),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            child: AnimatedContainer(
                              duration: AppMotion.fast,
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: scheme.surface.withValues(alpha: 0.94),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.sm),
                                boxShadow: dark ? null : AppShadows.soft,
                              ),
                              alignment: Alignment.center,
                              child: AnimatedSwitcher(
                                duration: AppMotion.fast,
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(
                                        scale: animation, child: child),
                                child: Icon(
                                  favorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  key: ValueKey(favorite),
                                  size: 19,
                                  color: favorite
                                      ? AppColors.danger
                                      : scheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (product.badge.isNotEmpty || product.discountPercent > 0)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: product.discountPercent > 0
                              ? AppColors.danger
                              : scheme.inverseSurface,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          product.discountPercent > 0
                              ? '-${product.discountPercent}%'
                              : product.badge.toUpperCase(),
                          style: TextStyle(
                            color: product.discountPercent > 0
                                ? Colors.white
                                : scheme.onInverseSurface,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .4,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 9.5,
                      letterSpacing: .6,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 13.5,
                      height: 1.25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.star, size: 17),
                      const SizedBox(width: 3),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviews})',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: scheme.onSurfaceVariant.withValues(alpha: .72),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppConstants.currency} ${product.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: scheme.onSurface,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (product.oldPrice != null)
                              Text(
                                '${AppConstants.currency} ${product.oldPrice!.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant
                                      .withValues(alpha: .72),
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: scheme.onSurfaceVariant,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Semantics(
                        button: true,
                        enabled: product.inStock && onAdd != null,
                        label: product.inStock
                            ? 'Add ${product.name} to cart'
                            : '${product.name} is out of stock',
                        child: AppPressable(
                          onTap: product.inStock ? onAdd : null,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: product.inStock
                                  ? scheme.primary
                                  : scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              boxShadow: product.inStock && !dark
                                  ? [
                                      BoxShadow(
                                        color: scheme.primary
                                            .withValues(alpha: .24),
                                        blurRadius: 14,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              product.inStock
                                  ? Icons.add_rounded
                                  : Icons.block_rounded,
                              color: product.inStock
                                  ? scheme.onPrimary
                                  : scheme.onSurfaceVariant,
                              size: 21,
                            ),
                          ),
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
    );
  }
}
