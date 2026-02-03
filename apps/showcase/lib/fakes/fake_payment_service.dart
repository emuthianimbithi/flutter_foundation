import 'dart:async';

import 'package:foundation_payments/foundation_payments.dart';

/// Demo-only payment service that simulates backend-driven polling.
class FakePaymentService implements PaymentService {
  @override
  Future<PaymentIntentModel> createPayment({
    required int amountMinor,
    required String currency,
    String? description,
  }) async {
    return PaymentIntentModel(
      id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      amountMinor: amountMinor,
      currency: currency,
      description: description,
    );
  }

  @override
  Future<PaymentResult> pollStatus({
    required String intentId,
    Duration interval = const Duration(seconds: 1),
    Duration timeout = const Duration(seconds: 10),
  }) async {
    // Simulate a pending -> succeeded transition.
    await Future<void>.delayed(interval * 2);
    return PaymentResult(status: PaymentStatus.succeeded, transactionId: intentId);
  }

  @override
  Future<void> cancel(String intentId) async {
    // No-op for demo.
  }
}
