import 'package:flutter/material.dart';

import '../../core/widgets/empty_state_card.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: const EmptyStateCard(
        icon: Icons.shopping_bag_outlined,
        title: 'Your cart is waiting',
        message:
            'The full cart with quantity controls, coupon UI, totals and checkout preparation will be built in Phase 7.',
      ),
    );
  }
}
