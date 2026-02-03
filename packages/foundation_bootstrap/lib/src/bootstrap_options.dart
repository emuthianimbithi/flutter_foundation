import 'package:foundation_auth/foundation_auth.dart';
import 'package:foundation_networking/foundation_networking.dart';
import 'package:foundation_payments/foundation_payments.dart';
import 'package:foundation_storage/foundation_storage.dart';
import 'package:foundation_routing/foundation_routing.dart';

/// Options controlling how FoundationBootstrap wires subsystems.
class FoundationBootstrapOptions {
  final BootstrapStorageOptions storage;
  final BootstrapNetworkingOptions networking;
  final BootstrapAuthOptions auth;
  final BootstrapPaymentsOptions payments;
  final BootstrapRoutingOptions routing;

  const FoundationBootstrapOptions({
    this.storage = const BootstrapStorageOptions(),
    this.networking = const BootstrapNetworkingOptions(),
    this.auth = const BootstrapAuthOptions(),
    this.payments = const BootstrapPaymentsOptions(),
    this.routing = const BootstrapRoutingOptions(),
  });
}

/// Overrides for storage initialization.
class BootstrapStorageOptions {
  final SecureStorage? secureStorage;
  final PreferencesStorage? preferencesStorage;
  final AppDatabase? database;
  final FileStorage? fileStorage;
  final StorageOptions? options;

  const BootstrapStorageOptions({
    this.secureStorage,
    this.preferencesStorage,
    this.database,
    this.fileStorage,
    this.options,
  });
}

/// Overrides/hooks for networking initialization.
class BootstrapNetworkingOptions {
  /// Provide a fully constructed gRPC channel factory.
  final GrpcChannelFactory? grpcChannelFactory;

  /// Hook to customize the builder before we build the channel factory.
  final void Function(GrpcChannelFactoryBuilder builder)? configureGrpc;

  const BootstrapNetworkingOptions({
    this.grpcChannelFactory,
    this.configureGrpc,
  });
}

/// Auth wiring options.
class BootstrapAuthOptions {
  /// Whether to restore session (load tokens + refresh if needed) automatically.
  final bool autoRestoreSession;

  /// Optional hook to run after restore completes (success or failure).
  final void Function(AuthState state)? onRestored;

  /// Override the default [AuthOptions] used by foundation_auth.
  final AuthOptions? authOptions;

  const BootstrapAuthOptions({
    this.autoRestoreSession = true,
    this.onRestored,
    this.authOptions,
  });
}

/// Payments wiring options.
class BootstrapPaymentsOptions {
  /// Provide a ready PaymentService; otherwise the default provider is used.
  final PaymentService? paymentService;

  const BootstrapPaymentsOptions({this.paymentService});
}

/// Routing defaults (placeholder for upcoming routing modes/deep link options).
class BootstrapRoutingOptions {
  final String? initialRoute;
  final bool enableDeepLinks;
  final RoutingMode mode;
  final bool deepLinkQueueUntilAuthReady;

  const BootstrapRoutingOptions({
    this.initialRoute,
    this.enableDeepLinks = true,
    this.mode = RoutingMode.authDriven,
    this.deepLinkQueueUntilAuthReady = true,
  });
}
