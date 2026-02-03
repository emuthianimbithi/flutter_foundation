import '../models/payment_intent.dart';
import '../models/payment_result.dart';
import 'payment_service.dart';

/// Safe fallback when no payment provider is configured.
class NotConfiguredPaymentService implements PaymentService {
  final String message;
  const NotConfiguredPaymentService({
    this.message =
        'Payment provider not configured. Configure Stripe backend or override paymentServiceProvider with your implementation.',
  });

  @override
  Future<PaymentIntentModel> createPayment(
      {required int amountMinor,
      required String currency,
      String? description}) async {
    return PaymentIntentModel(
      id: 'payment_not_configured',
      amountMinor: amountMinor,
      currency: currency,
      description: description,
    );
  }

  @override
  Future<PaymentResult> confirmPayment(PaymentIntentModel intent) async {
    return PaymentResult(status: PaymentStatus.failed, message: message);
  }

  @override
  Future<PaymentResult> pollStatus(
      {required String intentId,
      Duration interval = const Duration(seconds: 2),
      Duration timeout = const Duration(minutes: 2)}) async {
    return PaymentResult(status: PaymentStatus.failed, message: message);
  }

  @override
  Future<void> cancel(String intentId) async {}
}
