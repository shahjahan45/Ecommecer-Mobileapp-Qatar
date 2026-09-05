import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/design_system/app_tokens.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/network/api_environment.dart';
import '../../core/theme/app_theme_context.dart';
import '../../models/payment.dart';
import '../../models/shop_order.dart';
import '../orders/order_details_page.dart';
import '../profile/help_support_page.dart';

class OrderConfirmationPage extends StatelessWidget {
  final ShopOrder order;
  final bool? cloudSynced;
  final String? cloudSyncMessage;

  const OrderConfirmationPage({
    super.key,
    required this.order,
    this.cloudSynced,
    this.cloudSyncMessage,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      key: const Key('order-confirmation-page'),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Order confirmed'),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth < 380 ? 16.0 : 20.0;
            return ListView(
              key: const PageStorageKey<String>('order-confirmation-scroll'),
              padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, bottom + 28),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SuccessHero(order: order),
                        if (cloudSynced != null) ...[
                          const SizedBox(height: 12),
                          _CloudSyncStatusCard(
                            synced: cloudSynced!,
                            message: cloudSyncMessage,
                          ),
                        ],
                        const SizedBox(height: 14),
                        _StatusCard(order: order),
                        const SizedBox(height: 12),
                        _ReceiptCard(order: order),
                        const SizedBox(height: 12),
                        _DeliveryCard(order: order),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          key: const Key('confirmation-view-order'),
                          onPressed: () {
                            Navigator.of(context).push(
                              AppPageRoute(page: OrderDetailsPage(order: order)),
                            );
                          },
                          icon: const Icon(Icons.receipt_long_rounded),
                          label: const Text('View order details'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          key: const Key('confirmation-continue-shopping'),
                          onPressed: () {
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          icon: const Icon(Icons.storefront_outlined),
                          label: const Text('Continue shopping'),
                        ),
                        const SizedBox(height: 18),
                        _SupportCard(
                          onContactSupport: () {
                            Navigator.of(context).push(
                              AppPageRoute(page: const HelpSupportPage()),
                            );
                          },
                        ),
                      ],
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
}


class _CloudSyncStatusCard extends StatelessWidget {
  final bool synced;
  final String? message;

  const _CloudSyncStatusCard({
    required this.synced,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.dcxScheme;
    final accent = synced ? scheme.tertiary : scheme.error;
    final background = synced
        ? scheme.tertiaryContainer.withValues(alpha: context.isDarkMode ? .28 : .46)
        : scheme.errorContainer.withValues(alpha: context.isDarkMode ? .28 : .46);

    return Container(
      key: Key(synced ? 'confirmation-cloud-synced' : 'confirmation-cloud-pending'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: accent.withValues(alpha: .18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              synced ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
              color: accent,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  synced ? 'Synced with DCX Core' : 'Server sync pending',
                  style: TextStyle(
                    color: context.dcxTextPrimary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message ??
                      (synced
                          ? 'Accepted by ${ApiEnvironment.displayHost}. Use the admin dashboard connected to this same DCX Core server/database.'
                          : 'Open Profile → Data & sync to retry when the server is reachable.'),
                  style: TextStyle(
                    color: context.dcxTextTertiary,
                    fontSize: 9.2,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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


class _SupportCard extends StatelessWidget {
  final VoidCallback onContactSupport;

  const _SupportCard({required this.onContactSupport});

  @override
  Widget build(BuildContext context) {
    final scheme = context.dcxScheme;
    return Container(
      key: const Key('confirmation-support-card'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: context.isDarkMode ? .28 : .42),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: scheme.primary.withValues(alpha: .12)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .10),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(Icons.support_agent_rounded, color: scheme.primary, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help with your order?',
                  style: TextStyle(
                    color: context.dcxTextPrimary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Our support center is ready whenever you need assistance.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.dcxTextTertiary,
                    fontSize: 8.8,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            key: const Key('confirmation-contact-support'),
            onPressed: onContactSupport,
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 15),
            label: const Text('Contact'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              minimumSize: const Size(0, 38),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessHero extends StatelessWidget {
  final ShopOrder order;

  const _SuccessHero({required this.order});

  @override
  Widget build(BuildContext context) {
    final scheme = context.dcxScheme;
    final dark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [const Color(0xFF183A31), const Color(0xFF162B27)]
              : [const Color(0xFFE8FFF6), const Color(0xFFF6FFFB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: scheme.tertiary.withValues(alpha: .20)),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.check_rounded,
              color: scheme.onTertiaryContainer,
              size: 38,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Thank you for your order',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.dcxTextPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -.4,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            order.id,
            key: const Key('confirmation-order-id'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.dcxTextSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: .3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${AppConstants.currency} ${order.total.toStringAsFixed(0)}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.dcxTextPrimary,
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final ShopOrder order;

  const _StatusCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order.paymentStatus;
    final icon = switch (status) {
      CheckoutPaymentStatus.paid => Icons.verified_rounded,
      CheckoutPaymentStatus.payOnDelivery => Icons.payments_outlined,
      CheckoutPaymentStatus.awaitingTransfer => Icons.account_balance_outlined,
      CheckoutPaymentStatus.failed => Icons.error_outline_rounded,
    };

    return _SurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.dcxScheme.primaryContainer,
              borderRadius: BorderRadius.circular(13),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: context.dcxScheme.onPrimaryContainer, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.label,
                  key: const Key('confirmation-payment-status'),
                  style: TextStyle(
                    color: context.dcxTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${order.paymentMethod}${order.paymentReference == null ? '' : ' • ${order.paymentReference}'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.dcxTextSecondary,
                    fontSize: 10.5,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
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

class _ReceiptCard extends StatelessWidget {
  final ShopOrder order;

  const _ReceiptCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Order summary',
            style: TextStyle(
              color: context.dcxTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _ReceiptRow(label: '${order.totalQuantity} items', value: order.subtotal),
          if (order.discount > 0) ...[
            const SizedBox(height: 8),
            _ReceiptRow(label: order.promotionCode == null ? 'Discount' : 'Promo • ${order.promotionCode}', value: -order.discount),
          ],
          const SizedBox(height: 8),
          _ReceiptRow(label: 'Delivery', value: order.deliveryFee, freeLabel: true),
          const Divider(height: 24),
          _ReceiptRow(label: 'Total', value: order.total, strong: true),
        ],
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final ShopOrder order;

  const _DeliveryCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping_outlined, size: 19, color: context.dcxScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Delivery details',
                  style: TextStyle(
                    color: context.dcxTextPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.deliveryWindow,
            style: TextStyle(
              color: context.dcxTextPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            order.deliveryAddress,
            style: TextStyle(
              color: context.dcxTextSecondary,
              fontSize: 10.5,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  final Widget child;

  const _SurfaceCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.dcxSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.dcxBorder),
      ),
      child: child,
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final double value;
  final bool strong;
  final bool freeLabel;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.strong = false,
    this.freeLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueLabel = freeLabel && value == 0
        ? 'Free'
        : '${value < 0 ? '-' : ''}${AppConstants.currency} ${value.abs().toStringAsFixed(0)}';
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: strong ? context.dcxTextPrimary : context.dcxTextSecondary,
              fontSize: strong ? 12.5 : 10.5,
              fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          valueLabel,
          style: TextStyle(
            color: value < 0 ? context.dcxScheme.tertiary : context.dcxTextPrimary,
            fontSize: strong ? 13 : 10.5,
            fontWeight: strong ? FontWeight.w900 : FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
