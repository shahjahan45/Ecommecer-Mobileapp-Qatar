import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/design_system/app_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../cart_controller.dart';

class PromotionCodeCard extends StatefulWidget {
  final CartController cart;

  const PromotionCodeCard({
    super.key,
    required this.cart,
  });

  @override
  State<PromotionCodeCard> createState() => _PromotionCodeCardState();
}

class _PromotionCodeCardState extends State<PromotionCodeCard> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? _message;
  bool _messageIsError = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _apply() {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = widget.cart.applyPromotion(_controller.text);
    if (!mounted) return;

    setState(() {
      _message = result.message;
      _messageIsError = !result.applied;
      if (result.applied) {
        _controller.text = result.promotion?.code ?? _controller.text.trim();
      }
    });
  }

  void _remove() {
    widget.cart.removePromotion();
    if (!mounted) return;
    setState(() {
      _message = 'Promo code removed.';
      _messageIsError = false;
      _controller.clear();
    });
  }

  void _selectSuggestedCode(String code) {
    _controller
      ..text = code
      ..selection = TextSelection.collapsed(offset: code.length);
    setState(() {
      _message = null;
      _messageIsError = false;
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.cart,
      builder: (context, child) {
        final scheme = Theme.of(context).colorScheme;
        final promotion = widget.cart.appliedPromotion;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: promotion != null
              ? Semantics(
                  key: const ValueKey<String>('promotion-applied-card'),
                  container: true,
                  label: 'Promo code ${promotion.code} applied',
                  child: Container(
                    key: const ValueKey<String>('promotion-applied-surface'),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: scheme.brightness == Brightness.dark
                          ? AppColors.success.withValues(alpha: .12)
                          : AppColors.successSoft,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: AppColors.success.withValues(alpha: .22),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.local_offer_rounded,
                            color: AppColors.success,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      promotion.code,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: scheme.onSurface,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: .4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: .12),
                                      borderRadius: BorderRadius.circular(AppRadius.pill),
                                    ),
                                    child: const Text(
                                      'APPLIED',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: .5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                promotion.title,
                                style: TextStyle(
                                  color: scheme.onSurface,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                promotion.description,
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 10.5,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (widget.cart.promotionSavings > 0) ...[
                                const SizedBox(height: 7),
                                Text(
                                  'You save ${AppConstants.currency} ${widget.cart.promotionSavings.toStringAsFixed(0)} with this offer.',
                                  style: const TextStyle(
                                    color: AppColors.success,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Remove promo code',
                          onPressed: _remove,
                          icon: Icon(
                            Icons.close_rounded,
                            color: scheme.onSurfaceVariant,
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Container(
                  key: const ValueKey<String>('promotion-entry-card'),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: scheme.primaryContainer.withValues(alpha: .62),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.confirmation_number_outlined,
                              color: scheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Have a promo code?',
                                  style: TextStyle(
                                    color: scheme.onSurface,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Apply an eligible offer before checkout.',
                                  style: TextStyle(
                                    color: scheme.onSurfaceVariant,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 13),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 340;
                          final field = TextField(
                            key: const ValueKey<String>('promotion-code-field'),
                            controller: _controller,
                            focusNode: _focusNode,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.done,
                            autocorrect: false,
                            enableSuggestions: false,
                            onSubmitted: (_) => _apply(),
                            decoration: const InputDecoration(
                              hintText: 'Enter promo code',
                              prefixIcon: Icon(Icons.sell_outlined, size: 19),
                            ),
                          );
                          final button = FilledButton(
                            key: const ValueKey<String>('promotion-apply-button'),
                            onPressed: _apply,
                            child: const Text('Apply'),
                          );

                          if (compact) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                field,
                                const SizedBox(height: 9),
                                SizedBox(height: 48, child: button),
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: field),
                              const SizedBox(width: 9),
                              SizedBox(height: 50, child: button),
                            ],
                          );
                        },
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _message == null
                            ? const SizedBox.shrink()
                            : Padding(
                                key: ValueKey<String>(_message!),
                                padding: const EdgeInsets.only(top: 9),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      _messageIsError
                                          ? Icons.info_outline_rounded
                                          : Icons.check_circle_outline_rounded,
                                      size: 15,
                                      color: _messageIsError
                                          ? scheme.error
                                          : AppColors.success,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _message!,
                                        style: TextStyle(
                                          color: _messageIsError
                                              ? scheme.error
                                              : AppColors.success,
                                          fontSize: 10.5,
                                          height: 1.35,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 7,
                        runSpacing: 7,
                        children: [
                          _PromoHintChip(
                            code: 'WELCOME10',
                            onTap: () => _selectSuggestedCode('WELCOME10'),
                          ),
                          _PromoHintChip(
                            code: 'DCX25',
                            onTap: () => _selectSuggestedCode('DCX25'),
                          ),
                          _PromoHintChip(
                            code: 'FREESHIP',
                            onTap: () => _selectSuggestedCode('FREESHIP'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _PromoHintChip extends StatelessWidget {
  final String code;
  final VoidCallback onTap;

  const _PromoHintChip({
    required this.code,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Use promo code $code',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: .52),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              code,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: .25,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
