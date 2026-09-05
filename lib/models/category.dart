import 'package:flutter/material.dart';

class ShopCategory {
  final String name;
  final String slug;
  final IconData icon;
  final Color accent;
  final Color softColor;
  final int productCount;
  final List<String> subcategories;
  final String? imageUrl;

  const ShopCategory({
    required this.name,
    this.slug = '',
    required this.icon,
    required this.accent,
    required this.softColor,
    this.productCount = 0,
    this.subcategories = const [],
    this.imageUrl,
  });
}
