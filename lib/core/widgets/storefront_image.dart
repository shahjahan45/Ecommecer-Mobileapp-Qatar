import 'package:flutter/material.dart';

import '../../models/product.dart';

class StorefrontProductVisual extends StatelessWidget {
  final Product product;
  final double iconSize;
  final BoxFit fit;
  final String? imageUrl;

  const StorefrontProductVisual({
    super.key,
    required this.product,
    this.iconSize = 56,
    this.fit = BoxFit.cover,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = (imageUrl ?? product.imageUrl)?.trim();
    if (resolved != null && resolved.isNotEmpty) {
      return Image.network(
        resolved,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        errorBuilder: (context, error, stackTrace) => _fallback(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(color: product.softColor),
              Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: product.accent,
                    value: progress.expectedTotalBytes == null
                        ? null
                        : progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
    return _fallback();
  }

  Widget _fallback() => ColoredBox(
        color: product.softColor,
        child: Center(
          child: Icon(product.icon, size: iconSize, color: product.accent),
        ),
      );
}

class StorefrontImage extends StatelessWidget {
  final String? url;
  final Widget fallback;
  final BoxFit fit;

  const StorefrontImage({
    super.key,
    required this.url,
    required this.fallback,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final value = url?.trim();
    if (value == null || value.isEmpty) return fallback;
    return Image.network(
      value,
      width: double.infinity,
      height: double.infinity,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
