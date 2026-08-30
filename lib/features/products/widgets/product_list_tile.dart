import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_pressable.dart';
import '../../../models/product.dart';

class ProductListTile extends StatefulWidget {
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
  State<ProductListTile> createState() => _ProductListTileState();
}

class _ProductListTileState extends State<ProductListTile> {
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
        padding: const EdgeInsets.all(12),
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
              width: 104,
              height: 112,
              decoration: BoxDecoration(
                color: product.softColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Hero(
                      tag: widget.heroTag ?? 'product-icon-${product.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: Icon(
                          product.icon,
                          color: product.accent,
                          size: 48,
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
                            horizontal: 7, vertical: 4),
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
            const SizedBox(width: 13),
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
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => setState(() => _favorite = !_favorite),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: AnimatedSwitcher(
                            duration: AppMotion.fast,
                            child: Icon(
                              _favorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              key: ValueKey(_favorite),
                              color: _favorite
                                  ? AppColors.danger
                                  : AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                        ),
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
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppColors.star, size: 16),
                      const SizedBox(width: 3),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w900),
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
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 4),
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
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${AppConstants.currency} ${product.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w900),
                            ),
                            if (product.oldPrice != null) ...[
                              const SizedBox(width: 6),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 1),
                                child: Text(
                                  product.oldPrice!.toStringAsFixed(0),
                                  style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      AppPressable(
                        onTap: product.inStock ? widget.onAdd : null,
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
      ),
    );
  }
}
