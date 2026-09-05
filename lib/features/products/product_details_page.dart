import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/design_system/app_tokens.dart';
import '../../core/theme/app_colors.dart';
import '../../core/storefront/storefront_controller.dart';
import '../../models/product.dart';
import '../../widgets/product_card.dart';
import '../cart/cart_controller.dart';
import '../checkout/checkout_page.dart';
import '../wishlist/wishlist_controller.dart';
import 'widgets/product_gallery.dart';
import 'widgets/product_info_card.dart';
import 'widgets/product_quantity_selector.dart';
import 'widgets/product_variant_selector.dart';
import 'widgets/sticky_checkout_bar.dart';

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
  final StorefrontController _storefront = StorefrontController.instance;
  int _quantity = 1;
  int _selectedVariant = 0;
  bool _checkoutNavigationPending = false;

  Product get product => _storefront.productById(widget.product.id) ?? widget.product;

  @override
  void initState() {
    super.initState();
    _storefront.addListener(_handleStorefrontChanged);
    _storefront.start();
  }

  @override
  void dispose() {
    _storefront.removeListener(_handleStorefrontChanged);
    super.dispose();
  }

  void _handleStorefrontChanged() {
    if (!mounted) return;
    final latest = _storefront.productById(widget.product.id);
    if (latest == null) return;
    setState(() {
      if (_quantity > latest.stockQuantity && latest.stockQuantity > 0) {
        _quantity = latest.stockQuantity;
      }
    });
  }

  List<String> get _variants {
    if (product.variantOptions.isNotEmpty) {
      return product.variantOptions;
    }
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

  List<Color>? get _variantColors {
    if (product.variantColors.length == _variants.length &&
        product.variantColors.isNotEmpty) {
      return product.variantColors;
    }
    if (product.variantOptions.isNotEmpty) return null;
    switch (product.category) {
      case 'Home':
        return const [
          Color(0xFFF8F8F5),
          Color(0xFFD8BE96),
          Color(0xFF35363A),
        ];
      case 'Fashion':
      case 'Sports':
      case 'Beauty':
        return null;
      default:
        return const [
          Color(0xFF171C35),
          Color(0xFFAD8BFF),
          Color(0xFFC5CBD5),
        ];
    }
  }

  String get _variantTitle {
    if (product.variantTitle.trim().isNotEmpty) {
      return product.variantTitle;
    }
    switch (product.category) {
      case 'Fashion':
      case 'Sports':
        return 'Select size';
      case 'Beauty':
        return 'Select pack';
      case 'Home':
      default:
        return 'Select color';
    }
  }

  List<Product> get _relatedProducts => _storefront.products
      .where((item) => item.category == product.category && item.id != product.id)
      .take(4)
      .toList();

  void _showAddedFeedback({required bool buyNow}) {
    if (buyNow && _checkoutNavigationPending) return;

    FocusManager.instance.primaryFocus?.unfocus();

    final selectedVariant =
        _variants.isEmpty ? null : _variants[_selectedVariant];

    CartController.instance.add(
      product,
      quantity: _quantity,
      variant: selectedVariant,
    );

    if (buyNow) {
      // CartController notifies listeners synchronously. Deferring the route
      // push until the next frame keeps that rebuild separate from Navigator's
      // Overlay mutation and prevents route teardown/deactivation races.
      _checkoutNavigationPending = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _checkoutNavigationPending = false;

        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const CheckoutPage(),
          ),
        );
      });
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$_quantity × ${product.name} added to your cart.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 58,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          'Product details',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
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
          AnimatedBuilder(
            animation: WishlistController.instance,
            builder: (context, child) {
              final favorite = WishlistController.instance.contains(product);
              return IconButton(
                tooltip: favorite ? 'Remove from wishlist' : 'Add to wishlist',
                onPressed: () => WishlistController.instance.toggle(product),
                icon: AnimatedSwitcher(
                  duration: AppMotion.fast,
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: Icon(
                    favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    key: ValueKey(favorite),
                    color: favorite ? AppColors.danger : AppColors.textPrimary,
                  ),
                ),
              );
            },
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
              key: const Key('product-details-scroll'),
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 22),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 10,
                              child: HeroMode(
                                enabled: false,
                                child: ProductGallery(
                                  product: product,
                                  heroTag: widget.heroTag,
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              flex: 11,
                              child: _ProductDetailsContent(
                                product: product,
                                variants: _variants,
                                variantTitle: _variantTitle,
                                variantColors: _variantColors,
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
                                onSizeGuideTap: _showSizeGuide,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            HeroMode(
                              enabled: false,
                              child: ProductGallery(
                                product: product,
                                heroTag: widget.heroTag,
                              ),
                            ),
                            const SizedBox(height: 18),
                            _ProductDetailsContent(
                              product: product,
                              variants: _variants,
                              variantTitle: _variantTitle,
                              variantColors: _variantColors,
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
                              onSizeGuideTap: _showSizeGuide,
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: StickyCheckoutBar(
        product: product,
        quantity: _quantity,
        onAddToCart: product.inStock ? () => _showAddedFeedback(buyNow: false) : null,
        onBuyNow: product.inStock ? () => _showAddedFeedback(buyNow: true) : null,
      ),
    );
  }

  void _showSizeGuide() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Size guide',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose the option that best matches your usual fit. Available sizes for this product are shown below.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _variants
                      .map(
                        (variant) => Container(
                          width: 52,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            variant,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
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
  final List<Color>? variantColors;
  final int selectedVariant;
  final ValueChanged<int> onVariantSelected;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final List<Product> relatedProducts;
  final ValueChanged<Product> onRelatedProductTap;
  final VoidCallback onSizeGuideTap;

  const _ProductDetailsContent({
    required this.product,
    required this.variants,
    required this.variantTitle,
    required this.variantColors,
    required this.selectedVariant,
    required this.onVariantSelected,
    required this.quantity,
    required this.onQuantityChanged,
    required this.relatedProducts,
    required this.onRelatedProductTap,
    required this.onSizeGuideTap,
  });

  bool get _isSizeProduct => product.category == 'Fashion' || product.category == 'Sports';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 7,
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
        const SizedBox(height: 13),
        Text(
          product.name,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            height: 1.14,
            letterSpacing: -0.55,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        _ProductMetaRow(product: product),
        const SizedBox(height: 16),
        _PriceBlock(product: product),
        const SizedBox(height: 20),
        ProductVariantSelector(
          title: variantTitle,
          options: variants,
          colorValues: variantColors,
          selectedIndex: selectedVariant,
          onSelected: onVariantSelected,
          showGuide: _isSizeProduct,
          onGuideTap: _isSizeProduct ? onSizeGuideTap : null,
        ),
        const SizedBox(height: 18),
        _QuantityRow(
          product: product,
          quantity: quantity,
          onQuantityChanged: onQuantityChanged,
        ),
        const SizedBox(height: 18),
        ProductInfoCard(
          icon: Icons.verified_user_outlined,
          title: 'Secure order',
          subtitle: 'Protected checkout',
          showChevron: true,
        ),
        const SizedBox(height: 9),
        ProductInfoCard(
          icon: Icons.inventory_2_outlined,
          title: product.inStock ? 'Ready to ship' : 'Unavailable',
          subtitle: product.inStock ? '${product.stockQuantity} available' : 'Check again soon',
          showChevron: true,
        ),
        const SizedBox(height: 9),
        const ProductInfoCard(
          icon: Icons.support_agent_rounded,
          title: 'DCX support',
          subtitle: 'Help when you need it',
          showChevron: true,
        ),
        const SizedBox(height: 20),
        _SectionCard(
          title: 'About this product',
          icon: Icons.notes_rounded,
          child: Text(
            product.description.trim().isNotEmpty
                ? product.description
                : '${product.name} is designed for dependable everyday use with a clean, modern finish. It brings together thoughtful usability, quality materials and the practical details expected from ${product.brand.isEmpty ? 'DCX Online Store' : product.brand}.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 12),
        _RatingCard(product: product),
        if (relatedProducts.isNotEmpty) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'You may also like',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
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
          const SizedBox(height: 12),
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
                            CartController.instance.add(related);
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(
                                      '${related.name} added to your cart.',
                                    ),
                                  ),
                                );
                            });
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

class _ProductMetaRow extends StatelessWidget {
  final Product product;

  const _ProductMetaRow({required this.product});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: AppColors.star, size: 19),
          const SizedBox(width: 4),
          Text(
            product.rating.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
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
          const SizedBox(width: 11),
          Container(width: 1, height: 16, color: AppColors.border),
          const SizedBox(width: 11),
          Text(
            product.category,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 18),
          if (product.subcategory.isNotEmpty) ...[
            Text(
              product.subcategory,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuantityRow extends StatelessWidget {
  final Product product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const _QuantityRow({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quantity',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Choose how many you need',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ProductQuantitySelector(
          value: quantity,
          maxValue: product.stockQuantity > 0 ? product.stockQuantity : 1,
          onChanged: onQuantityChanged,
        ),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
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
                width: 34,
                height: 34,
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
          const SizedBox(height: 12),
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

