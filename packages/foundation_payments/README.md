# foundation_payments

Abstractions and UI helpers for payments (Stripe first), with safe defaults and demo backend.

## Stripe setup
1. Add `flutter_stripe` platform setup (iOS/Android init per plugin docs).
2. Provide a backend implementing `PaymentBackend.createPaymentIntent` that returns a client secret.
3. Wire the service:
```dart
final payments = StripePaymentService(backend: MyBackend());
ProviderScope(overrides: [paymentServiceProvider.overrideWithValue(payments)], child: MyApp());
```

## Demo / NotConfigured
- Default provider uses `StripePaymentService` with a fake backend so flows don’t crash.
- `NotConfiguredPaymentService` returns `PaymentStatus.failed` with guidance (never throws).

## Backend contract
```dart
abstract class PaymentBackend {
  Future<PaymentIntentModel> createPaymentIntent({
    required int amountMinor,
    required String currency,
    Map<String, dynamic>? metadata,
    String? description,
  });
}
```

## Minimal UI
```dart
final svc = ref.read(paymentServiceProvider);
final intent = await svc.createPayment(amountMinor: 1200, currency: 'usd');
final result = await svc.confirmPayment(intent);
if (result.isSuccess) { /* show success */ }
```

## Tests
- `test/payments_test.dart` covers state transitions, not-configured path, and default provider wiring.

## Example app
Run `apps/example_payments_app` for a runnable demo with success/fail/cancel toggles.
