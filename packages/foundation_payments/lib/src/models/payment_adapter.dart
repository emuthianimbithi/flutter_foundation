import 'payment_intent.dart';
import 'payment_result.dart';

abstract class PaymentAdapter {
  Future<PaymentResult> pay(PaymentIntentModel intent);
}
