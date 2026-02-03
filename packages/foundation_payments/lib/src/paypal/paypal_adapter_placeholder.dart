import '../models/payment_adapter.dart';
import '../models/payment_intent.dart';
import '../models/payment_result.dart';

class PayPalPaymentAdapter implements PaymentAdapter {
  @override
  Future<PaymentResult> pay(PaymentIntentModel intent) async {
    throw UnimplementedError('Implement PayPal payment flow');
  }
}
