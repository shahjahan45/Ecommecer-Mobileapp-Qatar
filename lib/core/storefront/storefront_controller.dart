import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/demo_catalog.dart';
import '../../data/demo_promotions.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../models/promotion.dart';
import '../../models/storefront_banner.dart';
import '../network/api_client.dart';
import '../network/api_environment.dart';
import '../network/api_models.dart';
import '../theme/app_colors.dart';

class StorefrontController extends ChangeNotifier {
  StorefrontController._();

  static final StorefrontController instance = StorefrontController._();

  static const String _cacheKey = 'dcx.storefront.snapshot.v1';
  static const String _revisionKey = 'dcx.storefront.revision.v1';

  final ApiClient _client = ApiClient();
  Timer? _pollTimer;
  bool _started = false;
  bool _refreshing = false;
  int _revision = 0;
  DateTime? _lastSyncedAt;
  String? _lastError;

  List<ShopCategory> _categories = List<ShopCategory>.from(DemoCatalog.categories);
  List<Product> _products = List<Product>.from(DemoCatalog.products);
  List<Promotion> _promotions = List<Promotion>.from(DemoPromotions.promotions);
  List<StorefrontBanner> _banners = const <StorefrontBanner>[
    StorefrontBanner(
      id: -1,
      eyebrow: 'WEEKEND DROP',
      title: 'Premium picks\nup to 40% off',
      subtitle: 'Fresh deals picked for you',
      linkType: 'catalog',
      linkValue: 'featured',
      startColor: Color(0xFF5B3FF0),
      endColor: Color(0xFF907CFF),
    ),
    StorefrontBanner(
      id: -2,
      eyebrow: 'NEW ARRIVALS',
      title: 'Smarter tech.\nCleaner style.',
      subtitle: 'Explore this week’s new collection',
      linkType: 'catalog',
      linkValue: 'new',
      startColor: Color(0xFF1267D6),
      endColor: Color(0xFF4EA1FF),
    ),
  ];
  Map<String, dynamic> _settings = <String, dynamic>{};
  Map<String, dynamic> _contentPages = <String, dynamic>{};
  List<Map<String, dynamic>> _socialLinks = <Map<String, dynamic>>[];

  List<ShopCategory> get categories => List<ShopCategory>.unmodifiable(_categories);
  List<Product> get products => List<Product>.unmodifiable(_products);
  List<Promotion> get promotions => List<Promotion>.unmodifiable(_promotions);
  List<StorefrontBanner> get banners => List<StorefrontBanner>.unmodifiable(_banners);
  Map<String, dynamic> get contentPages => Map<String, dynamic>.unmodifiable(_contentPages);
  List<Map<String, dynamic>> get socialLinks => List<Map<String, dynamic>>.unmodifiable(_socialLinks);
  int get revision => _revision;
  DateTime? get lastSyncedAt => _lastSyncedAt;
  String? get lastError => _lastError;
  bool get isRefreshing => _refreshing;
  bool get isRemote => ApiEnvironment.isRemoteConfigured;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;
    await _loadCache();
    if (ApiEnvironment.isRemoteConfigured) {
      await refresh(force: _revision == 0);
      _schedulePolling();
    }
  }

  Future<void> refresh({bool force = false}) async {
    if (!ApiEnvironment.isRemoteConfigured || _refreshing) {
      return;
    }
    _refreshing = true;
    try {
      final response = await _client.get(
        '/api/v1/storefront',
        authenticated: false,
        queryParameters: <String, String>{
          if (!force && _revision > 0) 'revision': '$_revision',
        },
      );
      final body = response.jsonObject;
      final changed = body['changed'] == true;
      final serverRevision = _asInt(body['revision']);
      if (changed) {
        final data = _asMap(body['data']);
        _applySnapshot(data, serverRevision: serverRevision);
        await _saveCache(data, serverRevision);
      } else if (serverRevision > 0) {
        _revision = serverRevision;
      }
      _lastSyncedAt = DateTime.now();
      _lastError = null;
    } on ApiException catch (error) {
      _lastError = error.message;
    } catch (_) {
      _lastError = 'Storefront refresh is temporarily unavailable.';
    } finally {
      _refreshing = false;
      notifyListeners();
    }
  }

  Product? productById(int id) {
    for (final product in _products) {
      if (product.id == id) {
        return product;
      }
    }
    return null;
  }

  Promotion? promotionByCode(String code) {
    final normalized = code.trim().toUpperCase();
    for (final promotion in _promotions) {
      if (promotion.code.toUpperCase() == normalized) {
        return promotion;
      }
    }
    return null;
  }

  String settingString(String group, String key, String fallback) {
    final value = _group(group)[key];
    if (value == null) {
      return fallback;
    }
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  double settingDouble(String group, String key, double fallback) {
    final value = _group(group)[key];
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  bool settingBool(String group, String key, bool fallback) {
    final value = _group(group)[key];
    if (value is bool) {
      return value;
    }
    if (value == null) {
      return fallback;
    }
    return const <String>{'1', 'true', 'yes', 'on'}.contains(value.toString().toLowerCase());
  }

  String? content(String slug) {
    final page = _asMap(_contentPages[slug]);
    final value = page['content']?.toString();
    return value == null || value.trim().isEmpty ? null : value;
  }

  Map<String, dynamic> _group(String group) => _asMap(_settings[group]);

  void _applySnapshot(Map<String, dynamic> data, {required int serverRevision}) {
    final rawProducts = _asList(data['products']);
    final rawCategories = _asList(data['categories']);

    final categoryVisuals = <String, _CategoryVisual>{};
    for (final raw in rawCategories) {
      final item = _asMap(raw);
      final name = item['name']?.toString() ?? 'Category';
      final slug = item['slug']?.toString() ?? name.toLowerCase();
      categoryVisuals[name] = _CategoryVisual(
        icon: _iconForCategory(item['icon_key']?.toString(), slug),
        accent: _color(item['accent_hex'], _fallbackAccent(slug)),
        soft: _color(item['soft_hex'], _fallbackSoft(slug)),
      );
    }

    final products = rawProducts.map((raw) {
      final item = _asMap(raw);
      final category = item['category']?.toString() ?? 'Other';
      final visual = categoryVisuals[category] ?? _CategoryVisual(
        icon: Icons.shopping_bag_rounded,
        accent: AppColors.primary,
        soft: AppColors.primarySoft,
      );
      final image = _mediaUrl(item['image']?.toString());
      final gallery = _asList(item['gallery'])
          .map((value) => _mediaUrl(value?.toString()))
          .whereType<String>()
          .toList(growable: false);
      final attributes = _asMap(item['attributes']);
      final variantOptions = _asList(attributes['variant_options'])
          .map((value) => value.toString().trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
      final variantColors = _asList(attributes['variant_colors'])
          .map((value) => _colorOrNull(value))
          .whereType<Color>()
          .toList(growable: false);
      final mobileId = _asInt(item['mobile_catalog_id']);
      final serverId = _asInt(item['id']);
      return Product(
        id: mobileId > 0 ? mobileId : serverId,
        serverId: serverId > 0 ? serverId : null,
        name: item['name']?.toString() ?? 'Product',
        description: item['description']?.toString() ?? '',
        category: category,
        subcategory: item['subcategory']?.toString() ?? '',
        brand: item['brand']?.toString() ?? '',
        price: _asDouble(item['price']),
        oldPrice: item['compare_at_price'] == null ? null : _asDouble(item['compare_at_price']),
        rating: _asDouble(item['rating']),
        reviews: _asInt(item['review_count']),
        badge: item['badge']?.toString() ?? '',
        icon: _iconForProduct(category, item['name']?.toString() ?? '', visual.icon),
        accent: visual.accent,
        softColor: visual.soft,
        inStock: item['in_stock'] == true && _asInt(item['stock_qty']) > 0,
        stockQuantity: _asInt(item['stock_qty']),
        isNew: item['is_new'] == true,
        tags: _asList(item['tags']).map((value) => value.toString()).toList(growable: false),
        imageUrl: image,
        galleryUrls: gallery,
        variantTitle: attributes['variant_title']?.toString() ?? '',
        variantOptions: variantOptions,
        variantColors: variantColors.length == variantOptions.length
            ? variantColors
            : const <Color>[],
      );
    }).where((product) => product.id > 0).toList(growable: false);

    final categories = rawCategories.map((raw) {
      final item = _asMap(raw);
      final name = item['name']?.toString() ?? 'Category';
      final slug = item['slug']?.toString() ?? name.toLowerCase();
      final visual = categoryVisuals[name] ?? _CategoryVisual(
        icon: Icons.category_rounded,
        accent: AppColors.primary,
        soft: AppColors.primarySoft,
      );
      final subcategories = products
          .where((product) => product.category == name && product.subcategory.trim().isNotEmpty)
          .map((product) => product.subcategory)
          .toSet()
          .toList(growable: false)
        ..sort();
      return ShopCategory(
        name: name,
        slug: slug,
        icon: visual.icon,
        accent: visual.accent,
        softColor: visual.soft,
        productCount: _asInt(item['product_count']),
        subcategories: subcategories,
        imageUrl: _mediaUrl(item['image']?.toString()),
      );
    }).toList(growable: false);

    final promotions = _asList(data['promotions']).map((raw) {
      final item = _asMap(raw);
      final type = switch (item['type']?.toString()) {
        'fixed_amount' => PromotionType.fixedAmount,
        'free_delivery' => PromotionType.freeDelivery,
        _ => PromotionType.percentage,
      };
      return Promotion(
        code: item['code']?.toString() ?? '',
        title: item['title']?.toString() ?? '',
        description: item['description']?.toString() ?? '',
        type: type,
        value: _asDouble(item['value']),
        minimumSubtotal: _asDouble(item['minimum_subtotal']),
        maximumDiscount: item['maximum_discount'] == null ? null : _asDouble(item['maximum_discount']),
      );
    }).where((promotion) => promotion.code.isNotEmpty).toList(growable: false);

    final banners = _asList(data['banners']).map((raw) {
      final item = _asMap(raw);
      return StorefrontBanner(
        id: _asInt(item['id']),
        eyebrow: item['eyebrow']?.toString() ?? '',
        title: item['title']?.toString() ?? '',
        subtitle: item['subtitle']?.toString() ?? '',
        ctaLabel: item['cta_label']?.toString() ?? '',
        imageUrl: _mediaUrl(item['image']?.toString()),
        linkType: item['link_type']?.toString() ?? 'none',
        linkValue: item['link_value']?.toString() ?? '',
        startColor: _color(item['theme_start_hex'], const Color(0xFF5B3FF0)),
        endColor: _color(item['theme_end_hex'], const Color(0xFF907CFF)),
      );
    }).where((banner) => banner.title.trim().isNotEmpty).toList(growable: false);

    _products = products;
    _categories = categories;
    _promotions = promotions;
    _banners = banners;
    _settings = _asMap(data['settings']);
    _contentPages = _asMap(data['content_pages']);
    _socialLinks = _asList(data['social_links']).map(_asMap).toList(growable: false);
    _revision = serverRevision > 0 ? serverRevision : _revision;
    _schedulePolling();
  }

  Future<void> _loadCache() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final raw = preferences.getString(_cacheKey);
      _revision = preferences.getInt(_revisionKey) ?? 0;
      if (raw == null || raw.trim().isEmpty) {
        return;
      }
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        _applySnapshot(Map<String, dynamic>.from(decoded), serverRevision: _revision);
      }
    } catch (_) {
      // Demo data remains available if cache restoration fails.
    }
  }

  Future<void> _saveCache(Map<String, dynamic> data, int revision) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_cacheKey, jsonEncode(data));
      await preferences.setInt(_revisionKey, revision);
    } catch (_) {
      // A cache write failure must never block a successful live refresh.
    }
  }

  void _schedulePolling() {
    if (!ApiEnvironment.isRemoteConfigured) {
      return;
    }
    final seconds = settingDouble('mobile', 'storefront_refresh_seconds', 4)
        .round()
        .clamp(3, 60)
        .toInt();
    if (_pollTimer?.isActive == true && _pollTimer!.tick >= 0) {
      _pollTimer?.cancel();
    }
    _pollTimer = Timer.periodic(Duration(seconds: seconds), (_) => refresh());
  }

  String? _mediaUrl(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) {
      return null;
    }
    final parsed = Uri.tryParse(value);
    if (parsed != null && parsed.hasScheme) {
      return value;
    }
    final base = ApiEnvironment.baseUri;
    if (base == null) {
      return value;
    }
    if (value.startsWith('/')) {
      final normalizedBasePath = base.path == '/' || base.path.isEmpty
          ? ''
          : base.path.replaceFirst(RegExp(r'/$'), '');
      return base
          .replace(
            path: '$normalizedBasePath$value',
            query: null,
            fragment: null,
          )
          .toString();
    }
    final basePath = base.path.endsWith('/') ? base.path : '${base.path}/';
    return base.replace(path: '$basePath$value', query: null, fragment: null).toString();
  }

  Color _color(dynamic value, Color fallback) {
    return _colorOrNull(value) ?? fallback;
  }

  Color? _colorOrNull(dynamic value) {
    final text = value?.toString().replaceAll('#', '').trim() ?? '';
    if (text.length != 6) {
      return null;
    }
    final parsed = int.tryParse(text, radix: 16);
    return parsed == null ? null : Color(0xFF000000 | parsed);
  }

  Color _fallbackAccent(String slug) {
    if (slug.contains('elect')) {
      return const Color(0xFF2979FF);
    }
    if (slug.contains('fashion')) {
      return const Color(0xFFEC4899);
    }
    if (slug.contains('beaut')) {
      return const Color(0xFF9C4DFF);
    }
    if (slug.contains('home')) {
      return const Color(0xFFFF8C42);
    }
    if (slug.contains('sport')) {
      return const Color(0xFF1FA971);
    }
    return AppColors.primary;
  }

  Color _fallbackSoft(String slug) {
    if (slug.contains('elect')) {
      return const Color(0xFFEAF2FF);
    }
    if (slug.contains('fashion')) {
      return const Color(0xFFFFEAF4);
    }
    if (slug.contains('beaut')) {
      return const Color(0xFFF4EAFE);
    }
    if (slug.contains('home')) {
      return const Color(0xFFFFF0E5);
    }
    if (slug.contains('sport')) {
      return const Color(0xFFE8F8F1);
    }
    return AppColors.primarySoft;
  }

  IconData _iconForCategory(String? key, String slug) {
    final normalized = (key ?? slug).toLowerCase();
    if (normalized.contains('device') || normalized.contains('elect')) {
      return Icons.devices_rounded;
    }
    if (normalized.contains('fashion')) {
      return Icons.checkroom_rounded;
    }
    if (normalized.contains('beaut')) {
      return Icons.spa_rounded;
    }
    if (normalized.contains('home')) {
      return Icons.chair_alt_rounded;
    }
    if (normalized.contains('sport')) {
      return Icons.sports_basketball_rounded;
    }
    if (normalized.contains('life') || normalized.contains('travel')) {
      return Icons.auto_awesome_rounded;
    }
    return Icons.category_rounded;
  }

  IconData _iconForProduct(String category, String name, IconData fallback) {
    final value = '$category $name'.toLowerCase();
    if (value.contains('headphone')) {
      return Icons.headphones_rounded;
    }
    if (value.contains('watch')) {
      return Icons.watch_rounded;
    }
    if (value.contains('shoe') || value.contains('sneaker')) {
      return Icons.directions_run_rounded;
    }
    if (value.contains('backpack') || value.contains('bag')) {
      return Icons.backpack_rounded;
    }
    if (value.contains('coffee')) {
      return Icons.coffee_maker_rounded;
    }
    if (value.contains('phone')) {
      return Icons.phone_android_rounded;
    }
    if (value.contains('lamp')) {
      return Icons.light_rounded;
    }
    if (value.contains('fitness') || value.contains('training')) {
      return Icons.fitness_center_rounded;
    }
    if (value.contains('fragrance') || value.contains('beauty')) {
      return Icons.local_florist_rounded;
    }
    return fallback;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  static List<dynamic> _asList(dynamic value) => value is List ? value : const <dynamic>[];
  static int _asInt(dynamic value) => value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
  static double _asDouble(dynamic value) => value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '') ?? 0;

  @visibleForTesting
  void resetForTesting() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _started = false;
    _refreshing = false;
    _revision = 0;
    _lastError = null;
    _lastSyncedAt = null;
    _categories = List<ShopCategory>.from(DemoCatalog.categories);
    _products = List<Product>.from(DemoCatalog.products);
    _promotions = List<Promotion>.from(DemoPromotions.promotions);
    _banners = const <StorefrontBanner>[
      StorefrontBanner(
        id: -1,
        eyebrow: 'WEEKEND DROP',
        title: 'Premium picks\nup to 40% off',
        subtitle: 'Fresh deals picked for you',
        linkType: 'catalog',
        linkValue: 'featured',
        startColor: Color(0xFF5B3FF0),
        endColor: Color(0xFF907CFF),
      ),
      StorefrontBanner(
        id: -2,
        eyebrow: 'NEW ARRIVALS',
        title: 'Smarter tech.\nCleaner style.',
        subtitle: 'Explore this week’s new collection',
        linkType: 'catalog',
        linkValue: 'new',
        startColor: Color(0xFF1267D6),
        endColor: Color(0xFF4EA1FF),
      ),
    ];
    _settings = <String, dynamic>{};
    _contentPages = <String, dynamic>{};
    _socialLinks = <Map<String, dynamic>>[];
    notifyListeners();
  }
}

class _CategoryVisual {
  final IconData icon;
  final Color accent;
  final Color soft;

  const _CategoryVisual({required this.icon, required this.accent, required this.soft});
}
