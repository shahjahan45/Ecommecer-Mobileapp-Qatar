import 'package:ecommerce_mobile/features/checkout/payment_flow_controller.dart';
import 'package:ecommerce_mobile/models/payment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PaymentFlowController controller;

  setUp(() {
    controller = PaymentFlowController();
  });

  tearDown(() => controller.dispose());

  test('cash on delivery returns a pay-on-delivery result', () async {
    final result = await controller.authorize(
      amount: 120,
      simulatedDelay: Duration.zero,
    );

    expect(result.succeeded, isTrue);
    expect(result.status, CheckoutPaymentStatus.payOnDelivery);
    expect(result.reference, startsWith('COD-'));
    expect(controller.isProcessing, isFalse);
  });

  test('card authorization produces a paid result', () async {
    controller.selectMethod(CheckoutPaymentMethod.card);

    final result = await controller.authorize(
      amount: 240,
      simulatedDelay: Duration.zero,
    );

    expect(result.succeeded, isTrue);
    expect(result.status, CheckoutPaymentStatus.paid);
    expect(result.reference, startsWith('CARD-'));
  });

  test('bank transfer produces an awaiting-transfer result', () async {
    controller.selectMethod(CheckoutPaymentMethod.bankTransfer);

    final result = await controller.authorize(
      amount: 90,
      simulatedDelay: Duration.zero,
    );

    expect(result.succeeded, isTrue);
    expect(result.status, CheckoutPaymentStatus.awaitingTransfer);
    expect(result.reference, startsWith('BANK-'));
  });

  test('zero total is rejected without entering processing state', () async {
    final result = await controller.authorize(
      amount: 0,
      simulatedDelay: Duration.zero,
    );

    expect(result.succeeded, isFalse);
    expect(result.status, CheckoutPaymentStatus.failed);
    expect(controller.isProcessing, isFalse);
    expect(controller.errorMessage, isNotNull);
  });
}
