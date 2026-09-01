import 'package:ecommerce_mobile/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts with official DCX Online Store branding',
      (tester) async {
    await tester.pumpWidget(const EcommerceApp());
    expect(find.bySemanticsLabel('DCX Online Store official logo'),
        findsOneWidget);
  });
}
