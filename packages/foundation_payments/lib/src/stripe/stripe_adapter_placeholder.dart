import '../models/payment_intent.dart';
import '../models/payment_result.dart';
import '../models/payment_adapter.dart';

class StripePaymentAdapter implements PaymentAdapter {
  @override
  Future<PaymentResult> pay(PaymentIntentModel intent) async {
    throw UnimplementedError('Implement Stripe payment flow');
  }
}
