import 'package:ecommerce_mobile/core/theme/app_colors.dart';
import 'package:ecommerce_mobile/navigation/widgets/dcx_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const items = <DcxNavigationItem>[
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

  testWidgets('bottom navigation stays bounded on common phone widths',
      (tester) async {
    final sizes = <Size>[
      const Size(320, 568),
      const Size(360, 640),
      const Size(360, 800),
      const Size(390, 844),
      const Size(412, 915),
    ];

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    for (final size in sizes) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.background,
          ),
          home: Scaffold(
            body: const SizedBox.expand(),
            bottomNavigationBar: DcxBottomNavigationBar(
              currentIndex: 2,
              position: 2,
              items: items,
              onSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'Failed at size $size');
    }
  });
}
