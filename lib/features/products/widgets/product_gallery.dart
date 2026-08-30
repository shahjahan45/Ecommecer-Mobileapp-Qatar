import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = PageController();
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
        final galleryHeight = math
            .min(math.max(constraints.maxWidth * 0.84, 275), 470)
            .toDouble();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: galleryHeight,
              decoration: BoxDecoration(
                color: product.softColor,
                borderRadius: BorderRadius.circular(AppRadius.xxl),
                border:
                    Border.all(color: product.accent.withValues(alpha: 0.10)),
                boxShadow: AppShadows.soft,
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _controller,
                    itemCount: 3,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemBuilder: (context, index) {
                      return _GalleryVisual(
                        product: product,
                        index: index,
                        heroTag: widget.heroTag,
                      );
                    },
                  ),
                  if (product.discountPercent > 0)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          '-${product.discountPercent}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        '${_index + 1} / 3',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      onTap: () {
                        _controller.animateToPage(
                          index,
                          duration: AppMotion.standard,
                          curve: AppMotion.standardCurve,
                        );
                      },
                      child: AnimatedContainer(
                        duration: AppMotion.fast,
                        height: 66,
                        decoration: BoxDecoration(
                          color: product.softColor,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: _index == index
                                ? AppColors.primary
                                : AppColors.border,
                            width: _index == index ? 1.5 : 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          _iconForIndex(index),
                          color: product.accent
                              .withValues(alpha: _index == index ? 1 : 0.65),
                          size: 27,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _iconForIndex(int index) {
    if (index == 1) return Icons.auto_awesome_rounded;
    if (index == 2) return Icons.view_in_ar_rounded;
    return product.icon;
  }
}

class _GalleryVisual extends StatelessWidget {
  final Product product;
  final int index;
  final Object? heroTag;

  const _GalleryVisual({
    required this.product,
    required this.index,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final icon = index == 0
        ? product.icon
        : index == 1
            ? Icons.auto_awesome_rounded
            : Icons.view_in_ar_rounded;

    final visual = Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                product.softColor,
                product.accent.withValues(alpha: 0.16 + (index * 0.025)),
              ],
              begin: index == 2 ? Alignment.bottomLeft : Alignment.topLeft,
              end: index == 2 ? Alignment.topRight : Alignment.bottomRight,
            ),
          ),
        ),
        Positioned(
          right: -36,
          top: -24,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.36),
            ),
          ),
        ),
        Positioned(
          left: -34,
          bottom: -58,
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: product.accent.withValues(alpha: 0.07),
            ),
          ),
        ),
        Center(
          child: Transform.rotate(
            angle: index == 0
                ? -0.08
                : index == 1
                    ? 0.08
                    : 0,
            child: Icon(
              icon,
              size: index == 0 ? 124 : 104,
              color: product.accent,
            ),
          ),
        ),
      ],
    );

    if (index != 0) return visual;

    return Hero(
      tag: heroTag ?? 'product-icon-${product.id}',
      child: Material(
        color: Colors.transparent,
        child: visual,
      ),
    );
  }
}
