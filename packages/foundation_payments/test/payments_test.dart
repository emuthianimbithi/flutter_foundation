import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_payments/foundation_payments.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _FakeBackend implements PaymentBackend {
  final PaymentStatus status;
  _FakeBackend({this.status = PaymentStatus.succeeded});

  @override
  Future<PaymentIntentModel> createPaymentIntent({
    required int amountMinor,
    required String currency,
    Map<String, dynamic>? metadata,
    String? description,
  }) async {
    final secretPrefix =
        status == PaymentStatus.succeeded ? 'demo_' : 'demo_fail_';
    return PaymentIntentModel(
      id: 'pi_${DateTime.now().millisecondsSinceEpoch}',
      amountMinor: amountMinor,
      currency: currency,
      description: description,
      clientSecret: '${secretPrefix}secret',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('StripePaymentService demo flow transitions to success', () async {
    final svc = StripePaymentService(
      backend: _FakeBackend(status: PaymentStatus.succeeded),
    );

    expect(svc.flowState.value, PaymentFlowState.idle);
    final intent = await svc.createPayment(amountMinor: 500, currency: 'usd');
    expect(svc.flowState.value, PaymentFlowState.creatingIntent);

    final res = await svc.confirmPayment(intent);
    expect(svc.flowState.value, PaymentFlowState.success);
    expect(res.status, PaymentStatus.succeeded);
  });

  test('NotConfiguredPaymentService returns failure not throw', () async {
    final svc = const NotConfiguredPaymentService(
      message: 'Missing payment backend. Configure Stripe backend.',
    );
    final intent = await svc.createPayment(amountMinor: 100, currency: 'usd');
    final res = await svc.confirmPayment(intent);
    expect(res.status, PaymentStatus.failed);
    expect(res.message, contains('Configure'));
  });

  test('default provider uses StripePaymentService with fake backend', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final svc = container.read(paymentServiceProvider);
    expect(svc, isA<StripePaymentService>());
  });
}
