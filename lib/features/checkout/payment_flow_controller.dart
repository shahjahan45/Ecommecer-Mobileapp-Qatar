import 'package:flutter/foundation.dart';

import '../../models/payment.dart';

class PaymentFlowController extends ChangeNotifier {
  CheckoutPaymentMethod _selectedMethod = CheckoutPaymentMethod.cashOnDelivery;
  bool _isProcessing = false;
  String? _errorMessage;

  CheckoutPaymentMethod get selectedMethod => _selectedMethod;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  void selectMethod(CheckoutPaymentMethod method) {
    if (_selectedMethod == method) return;
    _selectedMethod = method;
    _errorMessage = null;
    notifyListeners();
  }

  Future<PaymentAuthorizationResult> authorize({
    required double amount,
    Duration? simulatedDelay,
  }) async {
    if (_isProcessing) {
      return PaymentAuthorizationResult(
        method: _selectedMethod,
        status: CheckoutPaymentStatus.failed,
        reference: '',
        message: 'Payment is already being processed.',
      );
    }

    if (amount <= 0) {
      _errorMessage = 'Order total must be greater than zero.';
      notifyListeners();
      return PaymentAuthorizationResult(
        method: _selectedMethod,
        status: CheckoutPaymentStatus.failed,
        reference: '',
        message: _errorMessage!,
      );
    }

    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    final delay = simulatedDelay ??
        (_selectedMethod == CheckoutPaymentMethod.cashOnDelivery
            ? const Duration(milliseconds: 220)
            : const Duration(milliseconds: 720));
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    final now = DateTime.now();
    final suffix = now.microsecondsSinceEpoch.toString();
    final reference = switch (_selectedMethod) {
      CheckoutPaymentMethod.cashOnDelivery => 'COD-${suffix.substring(suffix.length - 8)}',
      CheckoutPaymentMethod.card => 'CARD-${suffix.substring(suffix.length - 8)}',
      CheckoutPaymentMethod.bankTransfer => 'BANK-${suffix.substring(suffix.length - 8)}',
    };

    final result = switch (_selectedMethod) {
      CheckoutPaymentMethod.cashOnDelivery => PaymentAuthorizationResult(
          method: _selectedMethod,
          status: CheckoutPaymentStatus.payOnDelivery,
          reference: reference,
          message: 'Cash on delivery confirmed.',
        ),
      CheckoutPaymentMethod.card => PaymentAuthorizationResult(
          method: _selectedMethod,
          status: CheckoutPaymentStatus.paid,
          reference: reference,
          message: 'Card payment authorized securely.',
        ),
      CheckoutPaymentMethod.bankTransfer => PaymentAuthorizationResult(
          method: _selectedMethod,
          status: CheckoutPaymentStatus.awaitingTransfer,
          reference: reference,
          message: 'Bank transfer instructions are ready.',
        ),
    };

    _isProcessing = false;
    notifyListeners();
    return result;
  }

  @visibleForTesting
  void resetForTesting() {
    _selectedMethod = CheckoutPaymentMethod.cashOnDelivery;
    _isProcessing = false;
    _errorMessage = null;
    notifyListeners();
  }
}
