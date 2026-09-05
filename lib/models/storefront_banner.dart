import 'package:flutter/material.dart';

class StorefrontBanner {
  final int id;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String ctaLabel;
  final String? imageUrl;
  final String linkType;
  final String linkValue;
  final Color startColor;
  final Color endColor;

  const StorefrontBanner({
    required this.id,
    this.eyebrow = '',
    required this.title,
    this.subtitle = '',
    this.ctaLabel = '',
    this.imageUrl,
    this.linkType = 'none',
    this.linkValue = '',
    required this.startColor,
    required this.endColor,
  });
}
