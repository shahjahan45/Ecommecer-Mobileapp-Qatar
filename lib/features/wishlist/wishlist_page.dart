import 'package:flutter/material.dart';

import '../../core/widgets/empty_state_card.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      body: EmptyStateCard(
        icon: Icons.favorite_border_rounded,
        title: 'Save products you love',
        message:
            'Tap the heart on any product card. Real wishlist persistence will be connected to Laravel in a later phase.',
        actionLabel: 'Continue shopping',
        onAction: () => Navigator.maybePop(context),
      ),
    );
  }
}
