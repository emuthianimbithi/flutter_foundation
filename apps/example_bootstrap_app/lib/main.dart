import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_auth/foundation_auth.dart';
import 'package:foundation_bootstrap/foundation_bootstrap.dart';
import 'package:foundation_config/foundation_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig(
    environment: Environment.development,
    appId: 'com.example.bootstrap',
    appName: 'Bootstrap Demo',
    grpcConfig:
        const GrpcConfig(host: 'demo.api.local', port: 50051, useTls: false),
  );

  await FoundationBootstrap.initialize(config: config, environment: 'dev');

  runApp(
    ProviderScope(
      overrides: FoundationBootstrap.overrides(),
      child: const BootstrapDemoApp(),
    ),
  );
}

class BootstrapDemoApp extends ConsumerWidget {
  const BootstrapDemoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = FoundationBootstrap.router(
      ref: ref,
      homeBuilder: (_) => const _HomePage(),
    );

    return MaterialApp.router(
      title: 'Foundation Bootstrap Demo',
      routerConfig: router,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
    );
  }
}

class _HomePage extends ConsumerWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome! Phase: ${authState.phase.name}'),
            const SizedBox(height: 12),
            Text('User: ${authState.userId ?? 'anonymous'}'),
            Text('Org: ${authState.orgSlug ?? '-'}'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
