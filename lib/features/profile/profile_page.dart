import 'package:flutter/material.dart';

import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../data/demo_orders.dart';
import '../notifications/notifications_page.dart';
import '../orders/orders_page.dart';
import '../wishlist/wishlist_controller.dart';
import '../wishlist/wishlist_page.dart';
import 'account_security_page.dart';
import 'address_book_page.dart';
import 'help_support_page.dart';
import 'payment_methods_page.dart';
import 'widgets/account_hero_card.dart';
import 'widgets/account_menu_section.dart';
import 'widgets/account_quick_action.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(AppPageRoute(page: page));
  }

  @override
  Widget build(BuildContext context) {
    final wishlist = WishlistController.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _open(context, const NotificationsPage()),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: AnimatedBuilder(
          animation: wishlist,
          builder: (context, child) {
            final activeOrders = DemoOrders.orders.where((order) => order.isActive).length;
            return LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth < 380 ? 16.0 : 20.0;
                final bottom = MediaQuery.paddingOf(context).bottom + 28;

                return CustomScrollView(
                  key: const PageStorageKey<String>('profile-account-scroll'),
                  physics: const ClampingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
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
                                AccountHeroCard(
                                  ordersCount: DemoOrders.orders.length,
                                  activeOrdersCount: activeOrders,
                                  wishlistCount: wishlist.count,
                                ),
                                const SizedBox(height: 18),
                                const Text(
                                  'Quick access',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 9),
                                _QuickAccessGrid(
                                  wishlistCount: wishlist.count,
                                  activeOrders: activeOrders,
                                  onOrders: () => _open(context, const OrdersPage()),
                                  onWishlist: () => _open(context, const WishlistPage()),
                                  onAddresses: () => _open(context, const AddressBookPage()),
                                  onPayments: () => _open(context, const PaymentMethodsPage()),
                                ),
                                const SizedBox(height: 22),
                                AccountMenuSection(
                                  title: 'Shopping',
                                  items: [
                                    AccountMenuItem(
                                      icon: Icons.receipt_long_outlined,
                                      title: 'My orders',
                                      subtitle: activeOrders == 0
                                          ? 'Review purchases and delivery history'
                                          : '$activeOrders active ${activeOrders == 1 ? 'order' : 'orders'} to follow',
                                      color: AppColors.primary,
                                      softColor: AppColors.primarySoft,
                                      trailingLabel: '${DemoOrders.orders.length}',
                                      onTap: () => _open(context, const OrdersPage()),
                                    ),
                                    AccountMenuItem(
                                      icon: Icons.favorite_border_rounded,
                                      title: 'Wishlist',
                                      subtitle: 'Products you saved for later',
                                      color: AppColors.danger,
                                      softColor: AppColors.dangerSoft,
                                      trailingLabel: '${wishlist.count}',
                                      onTap: () => _open(context, const WishlistPage()),
                                    ),
                                    AccountMenuItem(
                                      icon: Icons.notifications_none_rounded,
                                      title: 'Notifications',
                                      subtitle: 'Offers, delivery and account updates',
                                      color: AppColors.secondary,
                                      softColor: AppColors.secondarySoft,
                                      onTap: () => _open(context, const NotificationsPage()),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                AccountMenuSection(
                                  title: 'Account & checkout',
                                  items: [
                                    AccountMenuItem(
                                      icon: Icons.location_on_outlined,
                                      title: 'Delivery addresses',
                                      subtitle: 'Manage addresses used for checkout',
                                      color: AppColors.success,
                                      softColor: AppColors.successSoft,
                                      onTap: () => _open(context, const AddressBookPage()),
                                    ),
                                    AccountMenuItem(
                                      icon: Icons.credit_card_rounded,
                                      title: 'Payment methods',
                                      subtitle: 'Choose your preferred payment option',
                                      color: AppColors.info,
                                      softColor: AppColors.infoSoft,
                                      onTap: () => _open(context, const PaymentMethodsPage()),
                                    ),
                                    AccountMenuItem(
                                      icon: Icons.shield_outlined,
                                      title: 'Security & privacy',
                                      subtitle: 'Review how your account is protected',
                                      color: AppColors.primary,
                                      softColor: AppColors.primarySoft,
                                      onTap: () => _open(context, const AccountSecurityPage()),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                AccountMenuSection(
                                  title: 'Support',
                                  items: [
                                    AccountMenuItem(
                                      icon: Icons.support_agent_rounded,
                                      title: 'Help & support',
                                      subtitle: 'Quick answers for shopping and account questions',
                                      color: AppColors.warning,
                                      softColor: AppColors.warningSoft,
                                      onTap: () => _open(context, const HelpSupportPage()),
                                    ),
                                  ],
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
            );
          },
        ),
      ),
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  final int wishlistCount;
  final int activeOrders;
  final VoidCallback onOrders;
  final VoidCallback onWishlist;
  final VoidCallback onAddresses;
  final VoidCallback onPayments;

  const _QuickAccessGrid({
    required this.wishlistCount,
    required this.activeOrders,
    required this.onOrders,
    required this.onWishlist,
    required this.onAddresses,
    required this.onPayments,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final items = <Widget>[
          AccountQuickAction(
            icon: Icons.local_shipping_outlined,
            label: 'Orders',
            supportingText: activeOrders == 0 ? 'Order history' : '$activeOrders active',
            color: AppColors.primary,
            softColor: AppColors.primarySoft,
            onTap: onOrders,
          ),
          AccountQuickAction(
            icon: Icons.favorite_border_rounded,
            label: 'Wishlist',
            supportingText: '$wishlistCount saved',
            color: AppColors.danger,
            softColor: AppColors.dangerSoft,
            onTap: onWishlist,
          ),
          AccountQuickAction(
            icon: Icons.location_on_outlined,
            label: 'Addresses',
            supportingText: 'Delivery details',
            color: AppColors.success,
            softColor: AppColors.successSoft,
            onTap: onAddresses,
          ),
          AccountQuickAction(
            icon: Icons.credit_card_rounded,
            label: 'Payments',
            supportingText: 'Preferences',
            color: AppColors.info,
            softColor: AppColors.infoSoft,
            onTap: onPayments,
          ),
        ];

        // On compact phones a fixed two-column grid makes each action card
        // unnecessarily narrow. A horizontal rail keeps touch targets and text
        // comfortable while also giving users a natural swipe affordance.
        if (constraints.maxWidth < 350) {
          final cardWidth =
              (constraints.maxWidth * 0.58).clamp(172.0, 196.0).toDouble();
          return SingleChildScrollView(
            key: const Key('account-quick-actions-scroll'),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                for (var index = 0; index < items.length; index++) ...[
                  SizedBox(width: cardWidth, child: items[index]),
                  if (index != items.length - 1) const SizedBox(width: gap),
                ],
              ],
            ),
          );
        }

        final columns = constraints.maxWidth >= 700 ? 4 : 2;
        final itemWidth =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items
              .map((item) => SizedBox(width: itemWidth, child: item))
              .toList(growable: false),
        );
      },
    );
  }
}
