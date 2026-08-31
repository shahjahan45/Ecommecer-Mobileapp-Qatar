import 'package:flutter/material.dart';

import '../features/cart/cart_controller.dart';
import '../features/cart/cart_page.dart';
import '../features/categories/categories_page.dart';
import '../features/home/home_page.dart';
import '../features/orders/orders_page.dart';
import '../features/profile/profile_page.dart';
import 'widgets/dcx_bottom_navigation_bar.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late final PageController _pageController;

  static const _pages = <Widget>[
    HomePage(),
    CategoriesPage(),
    CartPage(),
    OrdersPage(),
    ProfilePage(),
  ];

  static const _items = <DcxNavigationItem>[
    DcxNavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    DcxNavigationItem(
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
      label: 'Categories',
    ),
    DcxNavigationItem(
      icon: Icons.shopping_bag_outlined,
      selectedIcon: Icons.shopping_bag_rounded,
      label: 'Cart',
    ),
    DcxNavigationItem(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
      label: 'Orders',
    ),
    DcxNavigationItem(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectTab(int index) {
    if (!_pageController.hasClients) return;

    final page = _pageController.page ?? _currentIndex.toDouble();
    if ((page - index).abs() < 0.001) return;

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOutCubic,
    );
  }

  double get _navigationPosition {
    if (!_pageController.hasClients) {
      return _currentIndex.toDouble();
    }

    return (_pageController.page ?? _currentIndex.toDouble())
        .clamp(0.0, (_items.length - 1).toDouble())
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        allowImplicitScrolling: true,
        onPageChanged: (index) {
          if (_currentIndex != index) {
            setState(() => _currentIndex = index);
          }
        },
        children: _pages,
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _pageController,
        builder: (context, child) {
          final position = _navigationPosition;
          final visualIndex = position.round();

          return AnimatedBuilder(
            animation: CartController.instance,
            builder: (context, child) {
              return DcxBottomNavigationBar(
                currentIndex: visualIndex,
                position: position,
                items: _items,
                badgeCounts: <int, int>{
                  if (CartController.instance.totalQuantity > 0)
                    2: CartController.instance.totalQuantity,
                },
                onSelected: _selectTab,
              );
            },
          );
        },
      ),
    );
  }
}
