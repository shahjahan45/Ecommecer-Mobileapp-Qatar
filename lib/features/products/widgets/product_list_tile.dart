import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../core/widgets/storefront_image.dart';
import '../../wishlist/wishlist_controller.dart';
import '../../../models/product.dart';

class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;
  final Object? heroTag;

  const ProductListTile({
    super.key,
    required this.product,
    this.onTap,
    this.onAdd,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 350;

          return Container(
        padding: EdgeInsets.all(compact ? 10 : 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: compact ? 88 : 104,
              height: compact ? 104 : 112,
              decoration: BoxDecoration(
                color: product.softColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Hero(
                      tag: heroTag ?? 'product-icon-${product.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: StorefrontProductVisual(
                          product: product,
                          iconSize: 48,
                        ),
                      ),
                    ),
                  ),
                  if (product.discountPercent > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: compact ? 10 : 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: compact ? 13 : 14,
                            height: 1.25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      SizedBox(width: compact ? 4 : 8),
                      AnimatedBuilder(
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
                              onTap: () {
                                WishlistController.instance.toggle(product);
                              },
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              child: Padding(
                                padding: EdgeInsets.all(compact ? 3 : 5),
                                child: AnimatedSwitcher(
                                  duration: AppMotion.fast,
                                  transitionBuilder: (child, animation) =>
                                      ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                  child: Icon(
                                    favorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    key: ValueKey(favorite),
                                    color: favorite
                                        ? AppColors.danger
                                        : AppColors.textSecondary,
                                    size: compact ? 18 : 20,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${product.brand.isEmpty ? product.category : product.brand} • ${product.subcategory}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 5,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.star,
                            size: 16,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${product.reviews})',
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: product.inStock
                              ? AppColors.successSoft
                              : AppColors.dangerSoft,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          product.inStock ? 'In stock' : 'Out of stock',
                          style: TextStyle(
                            color: product.inStock
                                ? AppColors.success
                                : AppColors.danger,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.end,
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            Text(
                              '${AppConstants.currency} ${product.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (product.oldPrice != null)
                              Text(
                                '${AppConstants.currency} ${product.oldPrice!.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppPressable(
                        onTap: product.inStock ? onAdd : null,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: AnimatedContainer(
                          duration: AppMotion.fast,
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: product.inStock
                                ? AppColors.primary
                                : AppColors.surfaceStrong,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            product.inStock ? 'Add' : 'Unavailable',
                            style: TextStyle(
                              color: product.inStock
                                  ? Colors.white
                                  : AppColors.textTertiary,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
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
          );
        },
      ),
    );
  }
}
