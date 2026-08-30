import 'package:flutter/material.dart';

import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_pressable.dart';
import '../product_filter.dart';

class FilterBottomSheet extends StatefulWidget {
  final ProductFilter initialFilter;

  const FilterBottomSheet({
    super.key,
    required this.initialFilter,
  });

  static Future<ProductFilter?> show(
    BuildContext context, {
    required ProductFilter initialFilter,
  }) {
    return showModalBottomSheet<ProductFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheet(initialFilter: initialFilter),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late RangeValues _priceRange;
  late double _rating;
  late bool _inStockOnly;
  late bool _onSaleOnly;

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(
      widget.initialFilter.minPrice,
      widget.initialFilter.maxPrice,
    );
    _rating = widget.initialFilter.minRating;
    _inStockOnly = widget.initialFilter.inStockOnly;
    _onSaleOnly = widget.initialFilter.onSaleOnly;
  }

  void _reset() {
    setState(() {
      _priceRange = const RangeValues(0, 500);
      _rating = 0;
      _inStockOnly = false;
      _onSaleOnly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Filter products',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    TextButton(onPressed: _reset, child: const Text('Reset')),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Refine the catalogue without losing your place.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 26),
                const _SectionTitle('Price range'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _PricePill(label: 'Min', value: _priceRange.start),
                    const SizedBox(width: 10),
                    _PricePill(label: 'Max', value: _priceRange.end),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 500,
                  divisions: 50,
                  labels: RangeLabels(
                    'QAR ${_priceRange.start.round()}',
                    'QAR ${_priceRange.end.round()}',
                  ),
                  onChanged: (value) => setState(() => _priceRange = value),
                ),
                const SizedBox(height: 18),
                const _SectionTitle('Minimum rating'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [0, 3, 4, 4.5].map((rating) {
                    final selected = _rating == rating;
                    final label = rating == 0 ? 'Any' : '$rating+';
                    return ChoiceChip(
                      selected: selected,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (rating != 0) ...[
                            const Icon(Icons.star_rounded, size: 16, color: AppColors.star),
                            const SizedBox(width: 4),
                          ],
                          Text(label),
                        ],
                      ),
                      onSelected: (_) => setState(() => _rating = rating.toDouble()),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const _SectionTitle('Availability'),
                const SizedBox(height: 8),
                _FilterSwitch(
                  icon: Icons.inventory_2_outlined,
                  title: 'In stock only',
                  subtitle: 'Hide products that are unavailable',
                  value: _inStockOnly,
                  onChanged: (value) => setState(() => _inStockOnly = value),
                ),
                _FilterSwitch(
                  icon: Icons.local_offer_outlined,
                  title: 'Deals only',
                  subtitle: 'Show products currently discounted',
                  value: _onSaleOnly,
                  onChanged: (value) => setState(() => _onSaleOnly = value),
                ),
                const SizedBox(height: 24),
                AppPressable(
                  onTap: () {
                    Navigator.of(context).pop(
                      ProductFilter(
                        minPrice: _priceRange.start,
                        maxPrice: _priceRange.end,
                        minRating: _rating,
                        inStockOnly: _inStockOnly,
                        onSaleOnly: _onSaleOnly,
                      ),
                    );
                  },
                  child: Container(
                    height: 56,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: .24),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Apply filters',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  final String label;
  final double value;

  const _PricePill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'QAR ${value.round()}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _FilterSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
