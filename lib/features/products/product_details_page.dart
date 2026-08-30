import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/design_system/app_tokens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_pressable.dart';
import '../../data/demo_catalog.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import 'widgets/product_gallery.dart';
import 'widgets/product_quantity_selector.dart';
import 'widgets/product_variant_selector.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;
  final Object? heroTag;

  const ProductDetailsPage({
    super.key,
    required this.product,
    this.heroTag,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _quantity = 1;
  int _selectedVariant = 0;
  bool _favorite = false;

  Product get product => widget.product;

  @override
  void initState() {
    super.initState();
    _favorite = product.favorite;
  }

  List<String> get _variants {
    switch (product.category) {
      case 'Fashion':
        return const ['S', 'M', 'L', 'XL'];
      case 'Sports':
        return const ['38', '39', '40', '41', '42'];
      case 'Beauty':
        return const ['Single', 'Duo', 'Gift set'];
      case 'Home':
        return const ['White', 'Sand', 'Charcoal'];
      default:
        return const ['Midnight', 'Lavender', 'Silver'];
    }
  }

  String get _variantTitle {
    switch (product.category) {
      case 'Fashion':
      case 'Sports':
        return 'Select size';
      case 'Beauty':
        return 'Select pack';
      default:
        return 'Select option';
    }
  }

  List<Product> get _relatedProducts => DemoCatalog.products
      .where((item) => item.category == product.category && item.id != product.id)
      .take(4)
      .toList();

  void _showAddedFeedback({required bool buyNow}) {
    FocusManager.instance.primaryFocus?.unfocus();
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
                  buyNow
                      ? 'Your item is ready to continue to checkout.'
                      : '$_quantity × ${product.name} added to your cart.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          product.brand.isEmpty ? 'Product details' : product.brand,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Share product',
            onPressed: () {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text('Product share options are ready.'),
                  ),
                );
            },
            icon: const Icon(Icons.ios_share_rounded),
          ),
          IconButton(
            tooltip: _favorite ? 'Remove from wishlist' : 'Add to wishlist',
            onPressed: () => setState(() => _favorite = !_favorite),
            icon: AnimatedSwitcher(
              duration: AppMotion.fast,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: Icon(
                _favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey(_favorite),
                color: _favorite ? AppColors.danger : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 10,
                              child: ProductGallery(product: product, heroTag: widget.heroTag),
                            ),
                            const SizedBox(width: 28),
                            Expanded(
                              flex: 11,
                              child: _ProductDetailsContent(
                                product: product,
                                variants: _variants,
                                variantTitle: _variantTitle,
                                selectedVariant: _selectedVariant,
                                onVariantSelected: (index) {
                                  setState(() => _selectedVariant = index);
                                },
                                quantity: _quantity,
                                onQuantityChanged: (value) {
                                  setState(() => _quantity = value);
                                },
                                relatedProducts: _relatedProducts,
                                onRelatedProductTap: _openRelatedProduct,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProductGallery(product: product, heroTag: widget.heroTag),
                            const SizedBox(height: 22),
                            _ProductDetailsContent(
                              product: product,
                              variants: _variants,
                              variantTitle: _variantTitle,
                              selectedVariant: _selectedVariant,
                              onVariantSelected: (index) {
                                setState(() => _selectedVariant = index);
                              },
                              quantity: _quantity,
                              onQuantityChanged: (value) {
                                setState(() => _quantity = value);
                              },
                              relatedProducts: _relatedProducts,
                              onRelatedProductTap: _openRelatedProduct,
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _PurchaseBar(
        product: product,
        quantity: _quantity,
        onAddToCart: product.inStock ? () => _showAddedFeedback(buyNow: false) : null,
        onBuyNow: product.inStock ? () => _showAddedFeedback(buyNow: true) : null,
      ),
    );
  }

  void _openRelatedProduct(Product related) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsPage(
          product: related,
          heroTag: 'related-product-${product.id}-${related.id}',
        ),
      ),
    );
  }
}

class _ProductDetailsContent extends StatelessWidget {
  final Product product;
  final List<String> variants;
  final String variantTitle;
  final int selectedVariant;
  final ValueChanged<int> onVariantSelected;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final List<Product> relatedProducts;
  final ValueChanged<Product> onRelatedProductTap;

  const _ProductDetailsContent({
    required this.product,
    required this.variants,
    required this.variantTitle,
    required this.selectedVariant,
    required this.onVariantSelected,
    required this.quantity,
    required this.onQuantityChanged,
    required this.relatedProducts,
    required this.onRelatedProductTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Pill(
              icon: Icons.verified_rounded,
              label: product.brand.isEmpty ? product.category : product.brand,
              color: AppColors.primary,
              background: AppColors.primarySoft,
            ),
            _Pill(
              icon: product.inStock ? Icons.check_circle_rounded : Icons.cancel_rounded,
              label: product.inStock ? '${product.stockQuantity} in stock' : 'Out of stock',
              color: product.inStock ? AppColors.success : AppColors.danger,
              background: product.inStock ? AppColors.successSoft : AppColors.dangerSoft,
            ),
            if (product.isNew)
              const _Pill(
                icon: Icons.auto_awesome_rounded,
                label: 'New arrival',
                color: AppColors.info,
                background: AppColors.infoSoft,
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          product.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 25,
            height: 1.16,
            letterSpacing: -0.45,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: AppColors.star, size: 20),
                const SizedBox(width: 4),
                Text(
                  product.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${product.reviews} reviews)',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Text(
              '${product.category} • ${product.subcategory}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _PriceBlock(product: product),
        const SizedBox(height: 22),
        _InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductVariantSelector(
                title: variantTitle,
                options: variants,
                selectedIndex: selectedVariant,
                onSelected: onVariantSelected,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantity',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Choose how many you need',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ProductQuantitySelector(
                    value: quantity,
                    maxValue: product.stockQuantity > 0 ? product.stockQuantity : 1,
                    onChanged: onQuantityChanged,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _TrustStrip(product: product),
        const SizedBox(height: 22),
        _SectionCard(
          title: 'About this product',
          icon: Icons.notes_rounded,
          child: Text(
            '${product.name} is designed for dependable everyday use with a clean, modern finish. '
            'It brings together thoughtful usability, quality materials and the practical details expected from ${product.brand.isEmpty ? 'DCX Online Store' : product.brand}.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.62,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 14),
        _SectionCard(
          title: 'Specifications',
          icon: Icons.tune_rounded,
          child: Column(
            children: [
              _SpecificationRow(label: 'Brand', value: product.brand.isEmpty ? 'DCX' : product.brand),
              _SpecificationRow(label: 'Category', value: product.category),
              _SpecificationRow(label: 'Type', value: product.subcategory),
              _SpecificationRow(label: 'SKU', value: 'DCX-${product.id.toString().padLeft(5, '0')}'),
              _SpecificationRow(
                label: 'Availability',
                value: product.inStock ? 'Ready to order' : 'Unavailable',
                showDivider: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _RatingCard(product: product),
        if (relatedProducts.isNotEmpty) ...[
          const SizedBox(height: 26),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'You may also like',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                product.category,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 304,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: relatedProducts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final related = relatedProducts[index];
                return SizedBox(
                  width: 184,
                  child: ProductCard(
                    product: related,
                    heroTag: 'related-product-${product.id}-${related.id}',
                    onTap: () => onRelatedProductTap(related),
                    onAdd: related.inStock
                        ? () {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text('${related.name} added to your cart.'),
                                ),
                              );
                          }
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _PriceBlock extends StatelessWidget {
  final Product product;

  const _PriceBlock({required this.product});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          '${AppConstants.currency} ${product.price.toStringAsFixed(0)}',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            letterSpacing: -0.5,
            fontWeight: FontWeight.w900,
          ),
        ),
        if (product.oldPrice != null)
          Text(
            '${AppConstants.currency} ${product.oldPrice!.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.textTertiary,
              decoration: TextDecoration.lineThrough,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (product.discountPercent > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.dangerSoft,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              'Save ${product.discountPercent}%',
              style: const TextStyle(
                color: AppColors.danger,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color background;

  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;

  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: child,
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: AppColors.primary, size: 19),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SpecificationRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const _SpecificationRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}

class _TrustStrip extends StatelessWidget {
  final Product product;

  const _TrustStrip({required this.product});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 390;
        final items = <Widget>[
          const _TrustItem(
            icon: Icons.verified_user_outlined,
            title: 'Secure order',
            subtitle: 'Protected checkout',
          ),
          _TrustItem(
            icon: Icons.inventory_2_outlined,
            title: product.inStock ? 'Ready to ship' : 'Unavailable',
            subtitle: product.inStock ? '${product.stockQuantity} available' : 'Check again soon',
          ),
          const _TrustItem(
            icon: Icons.support_agent_rounded,
            title: 'DCX support',
            subtitle: 'Help when needed',
          ),
        ];

        if (narrow) {
          return Column(
            children: [
              for (var index = 0; index < items.length; index++) ...[
                items[index],
                if (index != items.length - 1) const SizedBox(height: 8),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              Expanded(child: items[index]),
              if (index != items.length - 1) const SizedBox(width: 8),
            ],
          ],
        );
      },
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TrustItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8.5,
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

class _RatingCard extends StatelessWidget {
  final Product product;

  const _RatingCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Customer rating',
      icon: Icons.reviews_outlined,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product.rating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: index < product.rating.round() ? AppColors.star : AppColors.border,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${product.reviews} ratings',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _RatingBar(
                  label: '5',
                  value: (product.rating / 5).clamp(0.72, 0.96).toDouble(),
                ),
                _RatingBar(label: '4', value: (1 - (product.rating / 5)) * 0.9 + 0.12),
                const _RatingBar(label: '3', value: 0.08),
                const _RatingBar(label: '2', value: 0.04),
                const _RatingBar(label: '1', value: 0.02),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final String label;
  final double value;

  const _RatingBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final safeValue = value.clamp(0.0, 1.0).toDouble();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            child: Text(
              label,
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: safeValue,
                minHeight: 6,
                backgroundColor: AppColors.surfaceStrong,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.star),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseBar extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;

  const _PurchaseBar({
    required this.product,
    required this.quantity,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.elevated,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 360;
            final total = product.price * quantity;

            final price = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppConstants.currency} ${total.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ],
            );

            final actions = Row(
              children: [
                Expanded(
                  child: _PurchaseButton(
                    label: 'Add to cart',
                    icon: Icons.shopping_bag_outlined,
                    outlined: true,
                    onTap: onAddToCart,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PurchaseButton(
                    label: 'Buy now',
                    icon: Icons.arrow_forward_rounded,
                    onTap: onBuyNow,
                  ),
                ),
              ],
            );

            if (compact) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  price,
                  const SizedBox(height: 10),
                  actions,
                ],
              );
            }

            return Row(
              children: [
                SizedBox(width: 96, child: price),
                const SizedBox(width: 10),
                Expanded(child: actions),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PurchaseButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool outlined;
  final VoidCallback? onTap;

  const _PurchaseButton({
    required this.label,
    required this.icon,
    this.outlined = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return AppPressable(
      onTap: onTap,
      pressedScale: 0.98,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: outlined
              ? AppColors.surface
              : enabled
                  ? AppColors.primary
                  : AppColors.surfaceStrong,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: outlined
                ? enabled
                    ? AppColors.primary.withValues(alpha: 0.35)
                    : AppColors.border
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: outlined
                  ? enabled
                      ? AppColors.primary
                      : AppColors.textTertiary
                  : enabled
                      ? Colors.white
                      : AppColors.textTertiary,
            ),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                enabled ? label : 'Unavailable',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: outlined
                      ? enabled
                          ? AppColors.primary
                          : AppColors.textTertiary
                      : enabled
                          ? Colors.white
                          : AppColors.textTertiary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
