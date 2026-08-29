import 'package:ecommerce_mobile/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app starts with splash screen', (tester) async {
    await tester.pumpWidget(const EcommerceApp());
    expect(find.text('DCX Online Store'), findsOneWidget);
  });
}
