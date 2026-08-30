import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_pressable.dart';
import '../../data/demo_catalog.dart';
import '../../models/product.dart';
import '../products/product_listing_page.dart';

class SearchPage extends StatefulWidget {
  final String initialQuery;
  final bool returnQuery;

  const SearchPage({
    super.key,
    this.initialQuery = '',
    this.returnQuery = false,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  final List<String> _recentSearches = [
    'Smart watch',
    'Running shoes',
    'Coffee maker',
  ];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
    _query = widget.initialQuery;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<Product> get _matches {
    if (_query.trim().isEmpty) return const [];
    final query = _query.trim().toLowerCase();
    return DemoCatalog.products
        .where((product) => product.searchableText.contains(query))
        .take(5)
        .toList();
  }

  void _submit(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) return;

    setState(() {
      _recentSearches
          .removeWhere((item) => item.toLowerCase() == value.toLowerCase());
      _recentSearches.insert(0, value);
      if (_recentSearches.length > 5) _recentSearches.removeLast();
    });

    if (widget.returnQuery) {
      Navigator.of(context).pop(value);
      return;
    }

    Navigator.of(context).push(
      AppPageRoute(
        page: ProductListingPage(
          title: 'Search results',
          searchQuery: value,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matches = _matches;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: const Text('Search'),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.search,
                onChanged: (value) => setState(() => _query = value),
                onSubmitted: _submit,
                decoration: InputDecoration(
                  hintText: 'Search DCX Online Store',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear',
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.standard,
                child: _query.trim().isEmpty
                    ? _SearchDiscovery(
                        recentSearches: _recentSearches,
                        onSearch: (value) {
                          _controller.text = value;
                          _controller.selection =
                              TextSelection.collapsed(offset: value.length);
                          setState(() => _query = value);
                          _submit(value);
                        },
                        onClearRecent: () => setState(_recentSearches.clear),
                      )
                    : _SearchSuggestions(
                        query: _query,
                        matches: matches,
                        onSearch: _submit,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchDiscovery extends StatelessWidget {
  final List<String> recentSearches;
  final ValueChanged<String> onSearch;
  final VoidCallback onClearRecent;

  const _SearchDiscovery({
    required this.recentSearches,
    required this.onSearch,
    required this.onClearRecent,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('discovery'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
      physics: const ClampingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF171A24), Color(0xFF2A2F3E)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: const Row(
            children: [
              Icon(Icons.auto_awesome_rounded,
                  color: Color(0xFFA796FF), size: 30),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find it faster',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Search products, brands, categories and useful keywords.',
                      style: TextStyle(
                        color: Color(0xFFBFC4D2),
                        fontSize: 11,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (recentSearches.isNotEmpty) ...[
          const SizedBox(height: 26),
          Row(
            children: [
              const Expanded(
                child: Text('Recent searches',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
              ),
              TextButton(onPressed: onClearRecent, child: const Text('Clear')),
            ],
          ),
          const SizedBox(height: 8),
          ...recentSearches.map(
            (item) => _SearchHistoryTile(
              label: item,
              onTap: () => onSearch(item),
            ),
          ),
        ],
        const SizedBox(height: 24),
        const Text('Popular right now',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 9,
          children: DemoCatalog.popularSearches
              .map(
                (item) => ActionChip(
                  avatar: const Icon(Icons.trending_up_rounded, size: 16),
                  label: Text(item),
                  onPressed: () => onSearch(item),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _SearchSuggestions extends StatelessWidget {
  final String query;
  final List<Product> matches;
  final ValueChanged<String> onSearch;

  const _SearchSuggestions({
    required this.query,
    required this.matches,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('suggestions'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
      physics: const ClampingScrollPhysics(),
      children: [
        AppPressable(
          onTap: () => onSearch(query),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: const Color(0xFFD8CFFF)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.search_rounded,
                      color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Search for “$query”',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w900),
                  ),
                ),
                const Icon(Icons.arrow_forward_rounded,
                    color: AppColors.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          matches.isEmpty ? 'No instant matches' : 'Top suggestions',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        if (matches.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                Icon(Icons.search_off_rounded,
                    size: 54, color: AppColors.textTertiary),
                SizedBox(height: 12),
                Text(
                  'Press search to check the full catalogue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
        else
          ...matches.map(
            (product) => AppPressable(
              onTap: () => onSearch(product.name),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: product.softColor,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      alignment: Alignment.center,
                      child:
                          Icon(product.icon, color: product.accent, size: 25),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${product.category} • ${product.brand}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.north_west_rounded,
                        size: 17, color: AppColors.textTertiary),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SearchHistoryTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SearchHistoryTile({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.history_rounded,
                  size: 19, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700)),
            ),
            const Icon(Icons.north_west_rounded,
                size: 16, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
