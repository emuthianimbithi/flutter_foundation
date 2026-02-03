import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/payment_service.dart';
import '../stripe/stripe_payment_service_placeholder.dart';
import '../models/payment_method.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  // Default to Stripe placeholder; apps should override with real impl.
  return StripePaymentServicePlaceholder();
});

final availablePaymentMethodsProvider = Provider<List<PaymentMethod>>((ref) {
  return const [
    PaymentMethod(PaymentMethodType.card, 'Card'),
    PaymentMethod(PaymentMethodType.paypal, 'PayPal'),
    PaymentMethod(PaymentMethodType.inAppPurchase, 'In‑App Purchase'),
  ];
});