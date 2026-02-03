import '../services/payment_service.dart';
import '../models/payment_intent.dart';
import '../models/payment_method.dart';
import '../models/payment_result.dart';

class PaypalPaymentServicePlaceholder implements PaymentService {
  @override
  Future<PaymentIntentModel> createPayment({
    required int amountMinor,
    required String currency,
    String? description,
  }) async {
    return PaymentIntentModel(
      id: 'paypal_order_placeholder',
      amountMinor: amountMinor,
      currency: currency,
      description: description,
    );
  }

  @override
  Future<PaymentResult> pollStatus({
    required String intentId,
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 2),
  }) {
    throw UnimplementedError('Integrate PayPal status polling.');
  }

  @override
  Future<void> cancel(String intentId) {
    throw UnimplementedError('Implement PayPal cancel.');
  }
}
