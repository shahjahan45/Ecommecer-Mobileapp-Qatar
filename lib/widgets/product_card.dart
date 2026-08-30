import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/design_system/app_tokens.dart';
import '../core/theme/app_colors.dart';
import '../core/widgets/app_pressable.dart';
import '../models/product.dart';

class ProductCard extends StatefulWidget {
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
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool _favorite;

  @override
  void initState() {
    super.initState();
    _favorite = widget.product.favorite;
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return AppPressable(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.soft,
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
                      color: product.softColor,
                      gradient: LinearGradient(
                        colors: [
                          product.softColor,
                          product.accent.withValues(alpha: 0.10),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Hero(
                      tag: widget.heroTag ?? 'product-icon-${product.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Transform.rotate(
                          angle: -0.08,
                          child: Icon(
                            product.icon,
                            size: 68,
                            color: product.accent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: AppPressable(
                      onTap: () => setState(() => _favorite = !_favorite),
                      child: AnimatedContainer(
                        duration: AppMotion.fast,
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          boxShadow: AppShadows.soft,
                        ),
                        alignment: Alignment.center,
                        child: AnimatedSwitcher(
                          duration: AppMotion.fast,
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                          child: Icon(
                            _favorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey(_favorite),
                            size: 19,
                            color: _favorite
                                ? AppColors.danger
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
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
                              : AppColors.textPrimary,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          product.discountPercent > 0
                              ? '-${product.discountPercent}%'
                              : product.badge.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
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
                    style: const TextStyle(
                      color: AppColors.textSecondary,
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
                    style: const TextStyle(
                      color: AppColors.textPrimary,
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
                        style: const TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviews})',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textTertiary,
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
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (product.oldPrice != null)
                              Text(
                                '${AppConstants.currency} ${product.oldPrice!.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  color: AppColors.textTertiary,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      AppPressable(
                        onTap: widget.onAdd,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: product.inStock
                                ? AppColors.primary
                                : AppColors.surfaceStrong,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            boxShadow: [
                              BoxShadow(
                                color: (product.inStock
                                        ? AppColors.primary
                                        : AppColors.surfaceStrong)
                                    .withValues(alpha: .24),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            product.inStock
                                ? Icons.add_rounded
                                : Icons.block_rounded,
                            color: product.inStock
                                ? Colors.white
                                : AppColors.textTertiary,
                            size: 21,
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
