import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/payment_service.dart';
import '../models/payment_method.dart';
import '../models/payment_backend.dart';
import '../stripe/stripe_payment_service.dart';

final paymentServiceProvider = Provider<PaymentService>((ref) {
  // Default to Stripe service with a fake backend for demo flows.
  return StripePaymentService(
    backend: const FakePaymentBackend(),
    merchantDisplayName: 'Demo Store',
  );
});

final availablePaymentMethodsProvider = Provider<List<PaymentMethod>>((ref) {
  return const [
    PaymentMethod(PaymentMethodType.card, 'Card'),
    PaymentMethod(PaymentMethodType.paypal, 'PayPal'),
    PaymentMethod(PaymentMethodType.inAppPurchase, 'In‑App Purchase'),
  ];
});

/// Expose payment flow state when using Stripe.
final paymentFlowStateProvider = Provider<ValueListenable<dynamic>>((ref) {
  final svc = ref.watch(paymentServiceProvider);
  if (svc is StripePaymentService) return svc.flowState;
  return ValueNotifier(PaymentFlowState.idle);
});
