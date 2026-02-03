import '../models/payment_intent.dart';
import '../models/payment_method.dart';
import '../models/payment_result.dart';

abstract class PaymentService {
  /// Create/prepare a payment intent. Real implementations should call your backend.
  Future<PaymentIntentModel> createPayment({
    required int amountMinor,
    required String currency,
    String? description,
  });

  /// Confirm/present the payment to the user (e.g., Stripe PaymentSheet).
  Future<PaymentResult> confirmPayment(PaymentIntentModel intent);

  /// Poll payment status until terminal state.
  Future<PaymentResult> pollStatus({
    required String intentId,
    Duration interval,
    Duration timeout,
  });

  /// Cancel the payment if supported by the provider/backend.
  Future<void> cancel(String intentId);
}
