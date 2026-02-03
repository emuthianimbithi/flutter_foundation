import 'payment_intent.dart';

/// Backend contract for creating payment intents (server-side secret generation).
abstract class PaymentBackend {
  Future<PaymentIntentModel> createPaymentIntent({
    required int amountMinor,
    required String currency,
    Map<String, dynamic>? metadata,
    String? description,
  });
}

/// Demo backend that fakes a client secret so the UI flow can run without a server.
class FakePaymentBackend implements PaymentBackend {
  final bool succeed;
  const FakePaymentBackend({this.succeed = true});

  @override
  Future<PaymentIntentModel> createPaymentIntent({
    required int amountMinor,
    required String currency,
    Map<String, dynamic>? metadata,
    String? description,
  }) async {
    final id = 'demo_pi_${DateTime.now().millisecondsSinceEpoch}';
    final secret = 'demo_secret_$id';
    return PaymentIntentModel(
      id: id,
      amountMinor: amountMinor,
      currency: currency,
      description: description ?? 'Demo payment',
      clientSecret: secret,
    );
  }
}
