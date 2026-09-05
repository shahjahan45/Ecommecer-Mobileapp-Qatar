import 'package:flutter/material.dart';

class Product {
  final int id;
  final int? serverId;
  final String name;
  final String description;
  final String category;
  final String subcategory;
  final String brand;
  final double price;
  final double? oldPrice;
  final double rating;
  final int reviews;
  final bool favorite;
  final String badge;
  final IconData icon;
  final Color accent;
  final Color softColor;
  final bool inStock;
  final int stockQuantity;
  final bool isNew;
  final List<String> tags;
  final String? imageUrl;
  final List<String> galleryUrls;
  final String variantTitle;
  final List<String> variantOptions;
  final List<Color> variantColors;

  const Product({
    required this.id,
    this.serverId,
    required this.name,
    this.description = '',
    required this.category,
    this.subcategory = '',
    this.brand = '',
    required this.price,
    this.oldPrice,
    required this.rating,
    this.reviews = 0,
    this.favorite = false,
    this.badge = '',
    required this.icon,
    required this.accent,
    required this.softColor,
    this.inStock = true,
    this.stockQuantity = 12,
    this.isNew = false,
    this.tags = const [],
    this.imageUrl,
    this.galleryUrls = const [],
    this.variantTitle = '',
    this.variantOptions = const [],
    this.variantColors = const [],
  });

  int get discountPercent {
    if (oldPrice == null || oldPrice! <= price) return 0;
    return (((oldPrice! - price) / oldPrice!) * 100).round();
  }

  bool get onSale => discountPercent > 0;

  List<String> get allImageUrls => <String>[
        if (imageUrl != null && imageUrl!.trim().isNotEmpty) imageUrl!,
        ...galleryUrls.where((url) => url.trim().isNotEmpty),
      ];

  String get searchableText => [
        name,
        description,
        category,
        subcategory,
        brand,
        ...tags,
      ].join(' ').toLowerCase();
}
