import 'package:flutter/material.dart';

import '../../core/widgets/empty_state_card.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: const EmptyStateCard(
        icon: Icons.receipt_long_outlined,
        title: 'No orders yet',
        message:
            'Order cards, status filters, order details and animated tracking will be added in Phase 9.',
      ),
    );
  }
}
