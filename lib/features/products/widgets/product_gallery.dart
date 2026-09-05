import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/storefront_image.dart';
import '../../../models/product.dart';

class ProductGallery extends StatefulWidget {
  final Product product;
  final Object? heroTag;

  const ProductGallery({
    super.key,
    required this.product,
    this.heroTag,
  });

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  late final PageController _controller;
  int _index = 0;

  Product get product => widget.product;
  List<String> get _images => product.allImageUrls;
  int get _itemCount => _images.isEmpty ? 1 : _images.length;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void didUpdateWidget(covariant ProductGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_index >= _itemCount) {
      _index = 0;
      if (_controller.hasClients) _controller.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final galleryHeight = math.min(math.max(constraints.maxWidth * 0.70, 235), 430).toDouble();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: galleryHeight,
              decoration: BoxDecoration(
                color: product.softColor,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: product.accent.withValues(alpha: 0.10)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _controller,
                    itemCount: _itemCount,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemBuilder: (context, index) {
                      final visual = StorefrontProductVisual(
                        product: product,
                        imageUrl: _images.isEmpty ? null : _images[index],
                        iconSize: 124,
                        fit: BoxFit.contain,
                      );
                      if (index != 0) return visual;
                      return Hero(
                        tag: widget.heroTag ?? 'product-icon-${product.id}',
                        child: Material(color: Colors.transparent, child: visual),
                      );
                    },
                  ),
                  if (product.discountPercent > 0)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(AppRadius.pill)),
                        child: Text('-${product.discountPercent}%', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.90), borderRadius: BorderRadius.circular(AppRadius.pill)),
                      child: Text('${_index + 1} / $_itemCount', style: const TextStyle(color: AppColors.textPrimary, fontSize: 9.5, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
            if (_itemCount > 1) ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 62,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _itemCount,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      onTap: () => _controller.animateToPage(index, duration: AppMotion.standard, curve: AppMotion.standardCurve),
                      child: AnimatedContainer(
                        duration: AppMotion.fast,
                        width: 68,
                        decoration: BoxDecoration(
                          color: product.softColor,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: _index == index ? AppColors.primary : AppColors.border, width: _index == index ? 1.5 : 1),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: StorefrontProductVisual(product: product, imageUrl: _images[index], iconSize: 27, fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
