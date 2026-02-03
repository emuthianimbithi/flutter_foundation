import '../models/payment_adapter.dart';
import '../models/payment_intent.dart';
import '../models/payment_result.dart';

class InAppPurchaseAdapter implements PaymentAdapter {
  @override
  Future<PaymentResult> pay(PaymentIntentModel intent) async {
    throw UnimplementedError('Implement in-app purchase flow');
  }
}
