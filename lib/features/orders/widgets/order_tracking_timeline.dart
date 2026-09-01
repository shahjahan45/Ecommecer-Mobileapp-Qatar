import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/shop_order.dart';

class OrderTrackingProgress extends StatelessWidget {
  final ShopOrderStatus status;

  const OrderTrackingProgress({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    if (status == ShopOrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.dangerSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.danger, size: 19),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'This order was cancelled before shipment.',
                style: TextStyle(
                  color: AppColors.danger,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    const labels = <String>[
      'Ordered',
      'Packed',
      'Shipped',
      'On the way',
      'Delivered'
    ];
    final current = status.progressIndex;

    return Semantics(
      label: 'Order progress ${labels[current]}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: List.generate(labels.length, (index) {
              final complete = index <= current;
              final isCurrent = index == current;
              return Expanded(
                child: Row(
                  children: [
                    Container(
                      width: isCurrent ? 22 : 18,
                      height: isCurrent ? 22 : 18,
                      decoration: BoxDecoration(
                        color: complete
                            ? AppColors.primary
                            : AppColors.surfaceStrong,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              complete ? AppColors.primary : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: complete
                          ? Icon(
                              index < current
                                  ? Icons.check_rounded
                                  : Icons.circle,
                              color: Colors.white,
                              size: index < current ? 12 : 7,
                            )
                          : null,
                    ),
                    if (index != labels.length - 1)
                      Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: index < current
                                ? AppColors.primary
                                : AppColors.surfaceStrong,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(labels.length, (index) {
              return Expanded(
                child: Text(
                  labels[index],
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  textAlign: index == 0
                      ? TextAlign.left
                      : index == labels.length - 1
                          ? TextAlign.right
                          : TextAlign.center,
                  style: TextStyle(
                    color: index <= current
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                    fontSize: 8.5,
                    fontWeight:
                        index == current ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class ShippingHistoryTimeline extends StatelessWidget {
  final List<ShippingEvent> events;

  const ShippingHistoryTimeline({
    super.key,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(events.length, (index) {
        final event = events[index];
        final isLast = index == events.length - 1;
        final highlight = index == 0;

        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (!isLast)
                Positioned(
                  left: 6,
                  top: 14,
                  bottom: -18,
                  child: Container(
                    width: 2,
                    color: AppColors.border,
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: highlight ? 14 : 10,
                    height: highlight ? 14 : 10,
                    margin: EdgeInsets.only(
                      left: highlight ? 0 : 2,
                      top: highlight ? 2 : 4,
                      right: highlight ? 0 : 2,
                    ),
                    decoration: BoxDecoration(
                      color: highlight
                          ? AppColors.primary
                          : AppColors.surfaceStrong,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: highlight ? AppColors.primary : AppColors.border,
                        width: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                event.title,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 12.5,
                                  fontWeight: highlight
                                      ? FontWeight.w900
                                      : FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                event.timestamp,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 9.5,
                                  height: 1.25,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          event.description,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
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
            ],
          ),
        );
      }),
    );
  }
}
