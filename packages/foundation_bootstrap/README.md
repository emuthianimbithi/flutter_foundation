# foundation_bootstrap

Single entrypoint to wire foundation_config → foundation_storage → networking (gRPC) → foundation_auth → foundation_routing → foundation_payments.

## 15-line startup
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FoundationBootstrap.initialize(
    config: AppConfig(
      environment: Environment.development,
      appId: 'com.example.app',
      appName: 'Example',
      grpcConfig: const GrpcConfig(host: 'api.dev.example.com', useTls: false),
    ),
    environment: 'dev',
  );

  runApp(ProviderScope(
    overrides: FoundationBootstrap.overrides(),
    child: const MyApp(),
  ));
}
```
Inside `MyApp`:
```dart
class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = FoundationBootstrap.router(
      ref: ref,
      homeBuilder: (_) => const HomePage(),
    );
    return MaterialApp.router(routerConfig: router);
  }
}
```

## What initialize() does (order)
1) FoundationConfig.initializeWithConfig
2) StorageInitializer.initialize (secure storage, prefs, Drift DB, file cache)
3) gRPC channel factory build (or injected)
4) Auth wiring + optional session restore
5) Router ready (auth-driven by default)

## Overriding subsystems
```dart
await FoundationBootstrap.initialize(
  config: config,
  environment: 'stg',
  options: FoundationBootstrapOptions(
    storage: BootstrapStorageOptions(
      options: const StorageOptions(dbName: 'custom.db'),
    ),
    networking: BootstrapNetworkingOptions(
      configureGrpc: (builder) => builder.withLogging(logRequest: true, logResponse: true),
    ),
    auth: BootstrapAuthOptions(
      authOptions: const AuthOptions(refreshLeeway: Duration(seconds: 10)),
    ),
    payments: BootstrapPaymentsOptions(
      paymentService: StripePaymentService(backend: MyBackend()),
    ),
    routing: const BootstrapRoutingOptions(
      mode: RoutingMode.simple, // skip auth redirects
      initialRoute: '/',
    ),
  ),
);
```

## Router helpers
- `FoundationBootstrap.router` returns a GoRouter wired to auth states.
- Provide custom builders for splash/login/org/mfa/forbidden if you need your own UI.

## See also
- `apps/example_bootstrap_app` for a runnable starter.
- `apps/example_payments_app` for payments demo.
