import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_bootstrap/foundation_bootstrap.dart';
import 'package:foundation_config/foundation_config.dart';
import 'package:foundation_payments/foundation_payments.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig(
    environment: Environment.development,
    appId: 'com.example.payments',
    appName: 'Payments Demo',
    grpcConfig: const GrpcConfig(host: 'demo', port: 50051, useTls: false),
  );

  await FoundationBootstrap.initialize(
    config: config,
    environment: 'dev',
    options: FoundationBootstrapOptions(
      payments: BootstrapPaymentsOptions(paymentService: _DemoPaymentService()),
      routing: const BootstrapRoutingOptions(
          mode: RoutingMode.simple, initialRoute: '/'),
    ),
  );

  runApp(
    ProviderScope(
      overrides: FoundationBootstrap.overrides(),
      child: const PaymentsDemoApp(),
    ),
  );
}

class PaymentsDemoApp extends ConsumerWidget {
  const PaymentsDemoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = FoundationBootstrap.router(
      ref: ref,
      homeBuilder: (_) => const PaymentHomePage(),
    );
    return MaterialApp.router(
      title: 'Payments Demo',
      routerConfig: router,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
    );
  }
}

class PaymentHomePage extends ConsumerStatefulWidget {
  const PaymentHomePage({super.key});

  @override
  ConsumerState<PaymentHomePage> createState() => _PaymentHomePageState();
}

class _PaymentHomePageState extends ConsumerState<PaymentHomePage> {
  int _amount = 1200;
  PaymentStatus _status = PaymentStatus.initiated;
  String? _message;
  bool _simulateFailure = false;
  bool _simulateCancel = false;

  @override
  Widget build(BuildContext context) {
    final svc = ref.watch(paymentServiceProvider);
    if (svc is _DemoPaymentService) {
      svc.backend.simulateFailure = _simulateFailure;
      svc.backend.simulateCancel = _simulateCancel;
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Payments Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Amount: ${(_amount / 100).toStringAsFixed(2)} USD'),
            Slider(
              value: _amount.toDouble(),
              min: 100,
              max: 5000,
              onChanged: (v) => setState(() => _amount = v.toInt()),
            ),
            Row(
              children: [
                Checkbox(
                  value: _simulateFailure,
                  onChanged: (v) =>
                      setState(() => _simulateFailure = v ?? false),
                ),
                const Text('Simulate failure'),
              ],
            ),
            Row(
              children: [
                Checkbox(
                  value: _simulateCancel,
                  onChanged: (v) =>
                      setState(() => _simulateCancel = v ?? false),
                ),
                const Text('Simulate cancel'),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                setState(() {
                  _status = PaymentStatus.processing;
                  _message = null;
                });
                final intent = await svc.createPayment(
                    amountMinor: _amount, currency: 'usd');
                final res = await svc.confirmPayment(intent);
                final finalRes = await svc.pollStatus(intentId: intent.id);
                setState(() {
                  _status = finalRes.status;
                  _message = finalRes.message;
                });
              },
              icon: const Icon(Icons.payments),
              label: const Text('Pay now'),
            ),
            const SizedBox(height: 24),
            Text('Status: ${_status.name}'),
            if (_message != null)
              Text(_message!, style: const TextStyle(color: Colors.red)),
            const Spacer(),
            const Text(
                'Using demo backend. Provide real backend to process live payments.'),
          ],
        ),
      ),
    );
  }
}

/// Demo payment service that can simulate success/failure/cancel without hitting Stripe.
class _DemoPaymentService extends StripePaymentService {
  final _DemoBackend backend;
  _DemoPaymentService._(this.backend) : super(backend: backend);
  factory _DemoPaymentService() {
    final backend = _DemoBackend();
    return _DemoPaymentService._(backend);
  }
}

class _DemoBackend implements PaymentBackend {
  bool simulateFailure = false;
  bool simulateCancel = false;
  @override
  Future<PaymentIntentModel> createPaymentIntent({
    required int amountMinor,
    required String currency,
    Map<String, dynamic>? metadata,
    String? description,
  }) async {
    if (simulateCancel) {
      return PaymentIntentModel(
        id: 'demo_cancel',
        amountMinor: amountMinor,
        currency: currency,
        description: description ?? 'Demo',
        clientSecret: 'demo_cancel',
      );
    }
    if (simulateFailure) {
      return PaymentIntentModel(
        id: 'demo_fail',
        amountMinor: amountMinor,
        currency: currency,
        description: description ?? 'Demo',
        clientSecret: 'demo_fail',
      );
    }
    return PaymentIntentModel(
      id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      amountMinor: amountMinor,
      currency: currency,
      description: description ?? 'Demo',
      clientSecret: 'demo_secret',
    );
  }
}
