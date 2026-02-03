import '../models/payment_result.dart';

class IapServicePlaceholder {
  Future<PaymentResult> purchase(String productId) async {
    return const PaymentResult(
      status: PaymentStatus.failed,
      message: 'IAP not configured. Integrate in_app_purchase or RevenueCat.',
    );
  }
}
