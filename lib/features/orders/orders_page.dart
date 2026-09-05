import 'package:flutter/material.dart';

import '../../core/design_system/app_tokens.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state_card.dart';
import '../../data/demo_orders.dart';
import '../../models/shop_order.dart';
import '../cart/cart_controller.dart';
import 'order_remote_sync_controller.dart';
import 'order_details_page.dart';
import 'widgets/order_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  _OrderFilter _filter = _OrderFilter.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshOrders());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ShopOrder> get _filteredOrders {
    final query = _query.trim().toLowerCase();

    return DemoOrders.orders.where((order) {
      final matchesFilter = switch (_filter) {
        _OrderFilter.all => true,
        _OrderFilter.active => order.isActive,
        _OrderFilter.delivered => order.isDelivered,
        _OrderFilter.cancelled => order.isCancelled,
      };
      if (!matchesFilter) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }

      final searchable = <String>[
        order.id,
        order.status.label,
        order.carrier,
        order.deliveryAddress,
        ...order.items.map((item) => item.product.name),
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final orders = _filteredOrders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My orders'),
        actions: [
          IconButton(
            tooltip: 'Refresh order status',
            onPressed: _refreshOrders,
            icon: const Icon(Icons.sync_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth < 380 ? 16.0 : 20.0;
            final bottomPadding = MediaQuery.paddingOf(context).bottom + 24;

            return RefreshIndicator(
              onRefresh: _refreshOrders,
              child: CustomScrollView(
              key: const PageStorageKey<String>('orders-scroll'),
              physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(horizontal, 8, horizontal, 0),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 820),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _OrdersOverviewHero(orders: DemoOrders.orders),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _searchController,
                              textInputAction: TextInputAction.search,
                              onChanged: (value) => setState(() => _query = value),
                              decoration: InputDecoration(
                                hintText: 'Search order number or product',
                                prefixIcon: const Icon(Icons.search_rounded),
                                suffixIcon: _query.isEmpty
                                    ? null
                                    : IconButton(
                                        tooltip: 'Clear search',
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _query = '');
                                        },
                                        icon: const Icon(Icons.close_rounded, size: 19),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _FilterBar(
                              selected: _filter,
                              onSelected: (filter) => setState(() => _filter = filter),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _filter.title,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${orders.length} ${orders.length == 1 ? 'order' : 'orders'}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (orders.isEmpty)
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, bottomPadding),
                    sliver: SliverToBoxAdapter(
                      child: EmptyStateCard(
                        icon: Icons.receipt_long_outlined,
                        title: _query.isEmpty ? 'No orders here' : 'No matching orders',
                        message: _query.isEmpty
                            ? 'Orders with this status will appear here when available.'
                            : 'Try another order number, product name, or filter.',
                        actionLabel: _query.isEmpty ? null : 'Clear search',
                        onAction: _query.isEmpty
                            ? null
                            : () {
                                _searchController.clear();
                                setState(() {
                                  _query = '';
                                  _filter = _OrderFilter.all;
                                });
                              },
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, bottomPadding),
                    sliver: SliverList.separated(
                      itemCount: orders.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: OrderCard(
                              order: order,
                              onOpen: () => _openOrder(order),
                              onReorder: () => _reorder(order),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _refreshOrders() async {
    await OrderRemoteSyncController.instance.refresh();
    if (!mounted) {
      return;
    }
    setState(() {});
    final error = OrderRemoteSyncController.instance.lastError;
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _openOrder(ShopOrder order) {
    Navigator.of(context).push(
      AppPageRoute(page: OrderDetailsPage(order: order)),
    );
  }

  void _reorder(ShopOrder order) {
    final cart = CartController.instance;
    var updatedLines = 0;

    for (final item in order.items) {
      final before = cart.quantityFor(item.product, variant: item.variant);
      final after = cart.add(
        item.product,
        quantity: item.quantity,
        variant: item.variant,
      );
      if (after > before) {
        updatedLines++;
      }
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            updatedLines > 0
                ? 'Items from ${order.id} were added to your cart.'
                : 'These items are already at their available cart quantity.',
          ),
        ),
      );
  }
}

enum _OrderFilter {
  all,
  active,
  delivered,
  cancelled,
}

extension on _OrderFilter {
  String get title {
    switch (this) {
      case _OrderFilter.all:
        return 'All orders';
      case _OrderFilter.active:
        return 'Active orders';
      case _OrderFilter.delivered:
        return 'Delivered orders';
      case _OrderFilter.cancelled:
        return 'Cancelled orders';
    }
  }

  String get shortLabel {
    switch (this) {
      case _OrderFilter.all:
        return 'All';
      case _OrderFilter.active:
        return 'Active';
      case _OrderFilter.delivered:
        return 'Delivered';
      case _OrderFilter.cancelled:
        return 'Cancelled';
    }
  }
}

class _FilterBar extends StatelessWidget {
  final _OrderFilter selected;
  final ValueChanged<_OrderFilter> onSelected;

  const _FilterBar({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final filter in _OrderFilter.values) ...[
            ChoiceChip(
              label: Text(filter.shortLabel),
              selected: selected == filter,
              onSelected: (_) => onSelected(filter),
              showCheckmark: false,
              selectedColor: AppColors.primarySoft,
              side: BorderSide(
                color: selected == filter ? AppColors.primary : AppColors.border,
              ),
              labelStyle: TextStyle(
                color: selected == filter ? AppColors.primary : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            ),
            if (filter != _OrderFilter.values.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _OrdersOverviewHero extends StatelessWidget {
  final List<ShopOrder> orders;

  const _OrdersOverviewHero({required this.orders});

  @override
  Widget build(BuildContext context) {
    final active = orders.where((order) => order.isActive).length;
    final delivered = orders.where((order) => order.isDelivered).length;
    final totalItems = orders.fold<int>(0, (total, order) => total + order.totalQuantity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6847F5), Color(0xFF7955FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Orders at a glance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Track deliveries and revisit past purchases.',
                      style: TextStyle(
                        color: Color(0xFFE7E1FF),
                        fontSize: 10.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Icon(Icons.inventory_2_outlined, color: Colors.white, size: 29),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 330;
              final metrics = <Widget>[
                _HeroMetric(label: 'Active', value: '$active'),
                _HeroMetric(label: 'Delivered', value: '$delivered'),
                _HeroMetric(label: 'Items', value: '$totalItems'),
              ];

              if (compact) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: metrics
                      .map(
                        (metric) => SizedBox(
                          width: (constraints.maxWidth - 8) / 2,
                          child: metric,
                        ),
                      )
                      .toList(growable: false),
                );
              }

              return Row(
                children: [
                  for (var index = 0; index < metrics.length; index++) ...[
                    Expanded(child: metrics[index]),
                    if (index != metrics.length - 1) const SizedBox(width: 8),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;

  const _HeroMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              height: 1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFE9E4FF),
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
