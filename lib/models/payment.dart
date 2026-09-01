enum CheckoutPaymentMethod {
  cashOnDelivery,
  card,
  bankTransfer,
}

enum CheckoutPaymentStatus {
  payOnDelivery,
  paid,
  awaitingTransfer,
  failed,
}

extension CheckoutPaymentMethodUi on CheckoutPaymentMethod {
  String get label {
    switch (this) {
      case CheckoutPaymentMethod.cashOnDelivery:
        return 'Cash on delivery';
      case CheckoutPaymentMethod.card:
        return 'Card payment';
      case CheckoutPaymentMethod.bankTransfer:
        return 'Bank transfer';
    }
  }

  String get subtitle {
    switch (this) {
      case CheckoutPaymentMethod.cashOnDelivery:
        return 'Pay securely when your order arrives';
      case CheckoutPaymentMethod.card:
        return 'Secure authorization before order confirmation';
      case CheckoutPaymentMethod.bankTransfer:
        return 'Confirm the order and complete your transfer';
    }
  }
}

extension CheckoutPaymentStatusUi on CheckoutPaymentStatus {
  String get label {
    switch (this) {
      case CheckoutPaymentStatus.payOnDelivery:
        return 'Pay on delivery';
      case CheckoutPaymentStatus.paid:
        return 'Payment authorized';
      case CheckoutPaymentStatus.awaitingTransfer:
        return 'Awaiting transfer';
      case CheckoutPaymentStatus.failed:
        return 'Payment failed';
    }
  }
}

class PaymentAuthorizationResult {
  final CheckoutPaymentMethod method;
  final CheckoutPaymentStatus status;
  final String reference;
  final String message;

  const PaymentAuthorizationResult({
    required this.method,
    required this.status,
    required this.reference,
    required this.message,
  });

  bool get succeeded => status != CheckoutPaymentStatus.failed;
}
