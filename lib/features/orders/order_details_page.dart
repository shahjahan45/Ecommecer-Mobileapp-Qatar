import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_constants.dart';
import '../../core/design_system/app_tokens.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../models/payment.dart';
import '../../models/shop_order.dart';
import '../cart/cart_controller.dart';
import '../products/product_details_page.dart';
import '../support/support_request_page.dart';
import 'widgets/order_item_tile.dart';
import 'widgets/order_status_chip.dart';
import 'widgets/order_tracking_timeline.dart';

class OrderDetailsPage extends StatelessWidget {
  final ShopOrder order;

  const OrderDetailsPage({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order details'),
        actions: [
          IconButton(
            tooltip: 'Copy order number',
            onPressed: () => _copyText(context, order.id, 'Order number copied.'),
            icon: const Icon(Icons.copy_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth < 380 ? 16.0 : 20.0;
            final bottom = MediaQuery.paddingOf(context).bottom + 28;

            return CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, bottom),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _OrderStatusHero(order: order),
                            const SizedBox(height: 12),
                            _SectionCard(
                              title: 'Delivery progress',
                              subtitle: order.isCancelled
                                  ? 'This order stopped before fulfillment.'
                                  : 'Live package progress at a glance.',
                              child: OrderTrackingProgress(status: order.status),
                            ),
                            const SizedBox(height: 12),
                            _TrackingInfoCard(
                              order: order,
                              onCopyTracking: () => _copyText(
                                context,
                                order.trackingNumber,
                                'Tracking number copied.',
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SectionCard(
                              title: 'Shipping updates',
                              subtitle: 'The latest events for this package.',
                              child: ShippingHistoryTimeline(events: order.shippingHistory),
                            ),
                            const SizedBox(height: 12),
                            _SectionCard(
                              title: 'Package contents',
                              subtitle:
                                  '${order.totalQuantity} ${order.totalQuantity == 1 ? 'item' : 'items'} in this order',
                              child: Column(
                                children: [
                                  for (var index = 0; index < order.items.length; index++) ...[
                                    OrderItemTile(
                                      item: order.items[index],
                                      onTap: () => Navigator.of(context).push(
                                        AppPageRoute(
                                          page: ProductDetailsPage(
                                            product: order.items[index].product,
                                            heroTag: 'order-${order.id}-${order.items[index].product.id}-$index',
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (index != order.items.length - 1)
                                      const Divider(height: 1),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            _OrderPaymentSummary(order: order),
                            const SizedBox(height: 12),
                            _OrderActions(
                              onReorder: () => _reorder(context),
                              onSupport: () => _showSupport(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _reorder(BuildContext context) {
    final cart = CartController.instance;
    var added = 0;
    for (final item in order.items) {
      final before = cart.totalQuantity;
      cart.add(
        item.product,
        quantity: item.quantity,
        variant: item.variant,
      );
      if (cart.totalQuantity > before) added++;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            added > 0
                ? 'Items from ${order.id} were added to your cart.'
                : 'These items are already at their available cart quantity.',
          ),
        ),
      );
  }

  Future<void> _showSupport(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(Icons.support_agent_rounded, color: AppColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Order support',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'This creates an order-linked inquiry for ${order.id}. DCX Support can reply from the admin panel and you can continue the conversation in Help & support.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      Navigator.of(context).push(
                        AppPageRoute(
                          page: SupportRequestPage(initialOrderId: order.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: const Text('Create order inquiry'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _copyText(BuildContext context, String text, String message) async {
    if (text == 'Not available') return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _OrderStatusHero extends StatelessWidget {
  final ShopOrder order;

  const _OrderStatusHero({required this.order});

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.isCancelled;
    final accent = isCancelled
        ? AppColors.danger
        : order.isDelivered
            ? AppColors.success
            : AppColors.primary;
    final soft = isCancelled
        ? AppColors.dangerSoft
        : order.isDelivered
            ? AppColors.successSoft
            : AppColors.primarySoft;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: soft,
                  borderRadius: BorderRadius.circular(15),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isCancelled
                      ? Icons.cancel_outlined
                      : order.isDelivered
                          ? Icons.inventory_2_outlined
                          : Icons.local_shipping_rounded,
                  color: accent,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.deliveryLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      order.deliveryWindow,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OrderStatusChip(status: order.status),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 17,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${AppConstants.currency} ${order.total.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _TrackingInfoCard extends StatelessWidget {
  final ShopOrder order;
  final VoidCallback onCopyTracking;

  const _TrackingInfoCard({
    required this.order,
    required this.onCopyTracking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tracking information',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.local_shipping_outlined,
            label: 'Carrier',
            value: order.carrier,
          ),
          const Divider(height: 22),
          _InfoRow(
            icon: Icons.pin_outlined,
            label: 'Tracking number',
            value: order.trackingNumber,
            valueColor: order.trackingNumber == 'Not available'
                ? AppColors.textSecondary
                : AppColors.primary,
            underlined: order.trackingNumber != 'Not available',
            onTap: order.trackingNumber == 'Not available' ? null : onCopyTracking,
          ),
          const Divider(height: 22),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Delivery to',
            value: order.deliveryAddress,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool underlined;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.underlined = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final valueWidget = Text(
      value,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
      style: TextStyle(
        color: valueColor ?? AppColors.textPrimary,
        fontSize: 11,
        height: 1.35,
        fontWeight: FontWeight.w800,
        decoration: underlined ? TextDecoration.underline : null,
        decorationColor: valueColor ?? AppColors.primary,
      ),
    );

    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(11),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.primary, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 2,
          child: onTap == null
              ? valueWidget
              : InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                    child: valueWidget,
                  ),
                ),
        ),
      ],
    );
  }
}

class _OrderPaymentSummary extends StatelessWidget {
  final ShopOrder order;

  const _OrderPaymentSummary({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Payment summary',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  order.paymentStatus.label,
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.paymentMethod,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (order.paymentReference != null) ...[
            const SizedBox(height: 3),
            Text(
              'Reference: ${order.paymentReference}',
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 14),
          _MoneyRow(label: 'Subtotal', value: order.subtotal),
          if (order.discount > 0) ...[
            const SizedBox(height: 8),
            _MoneyRow(
              label: order.promotionCode == null ? 'Discount' : 'Promo • ${order.promotionCode}',
              value: -order.discount,
              positive: true,
            ),
          ],
          const SizedBox(height: 8),
          _MoneyRow(label: 'Delivery', value: order.deliveryFee, freeLabel: true),
          const Divider(height: 24),
          _MoneyRow(label: 'Order total', value: order.total, total: true),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final double value;
  final bool positive;
  final bool total;
  final bool freeLabel;

  const _MoneyRow({
    required this.label,
    required this.value,
    this.positive = false,
    this.total = false,
    this.freeLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final display = freeLabel && value == 0
        ? 'Free'
        : '${positive && value < 0 ? '-' : ''}${AppConstants.currency} ${value.abs().toStringAsFixed(0)}';

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: total ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: total ? 12.5 : 10.5,
              fontWeight: total ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        Text(
          display,
          style: TextStyle(
            color: positive
                ? AppColors.success
                : total
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
            fontSize: total ? 14 : 10.5,
            fontWeight: total ? FontWeight.w900 : FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _OrderActions extends StatelessWidget {
  final VoidCallback onReorder;
  final VoidCallback onSupport;

  const _OrderActions({
    required this.onReorder,
    required this.onSupport,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 340;
        final reorder = FilledButton.icon(
          onPressed: onReorder,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Buy again'),
        );
        final support = OutlinedButton.icon(
          onPressed: onSupport,
          icon: const Icon(Icons.support_agent_rounded, size: 18),
          label: const Text('Get help'),
        );

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 52, child: reorder),
              const SizedBox(height: 8),
              SizedBox(height: 52, child: support),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: SizedBox(height: 52, child: reorder)),
            const SizedBox(width: 10),
            Expanded(child: SizedBox(height: 52, child: support)),
          ],
        );
      },
    );
  }
}
