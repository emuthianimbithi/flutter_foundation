import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_config/foundation_config.dart';
import 'package:foundation_storage/foundation_storage.dart';

import 'core/cache_policy.dart';
import 'core/network_info.dart';
import 'core/retry_policy.dart';
import 'grpc/grpc_client_manager.dart';
import 'rest/rest_client.dart';
import 'websocket/websocket_client.dart';

// ─────────────────────────────────────────────────────────────
// NETWORK INFO
// ─────────────────────────────────────────────────────────────

/// Provider for network info.
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  final networkInfo = NetworkInfo();
  ref.onDispose(() => networkInfo.dispose());
  return networkInfo;
});

/// Provider for network status.
final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.onStatusChanged;
});

/// Provider for checking if connected.
final isNetworkConnectedProvider = Provider<bool>((ref) {
  final networkInfo = ref.watch(networkInfoProvider);
  return networkInfo.isConnected;
});

// ─────────────────────────────────────────────────────────────
// POLICIES
// ─────────────────────────────────────────────────────────────

/// Provider for retry policy.
final retryPolicyProvider = Provider<RetryPolicy>((ref) {
  return RetryPolicy.defaults();
});

/// Provider for cache policy.
final cachePolicyProvider = Provider<CachePolicy>((ref) {
  final isOfflineEnabled = ref.watch(offlineModeEnabledProvider);
  return isOfflineEnabled ? CachePolicy.offlineFirst() : CachePolicy.defaults();
});

// ─────────────────────────────────────────────────────────────
// GRPC
// ─────────────────────────────────────────────────────────────

/// Provider for gRPC client manager.
final grpcClientManagerProvider = Provider<GrpcClientManager?>((ref) {
  final grpcConfig = ref.watch(grpcConfigProvider);
  if (grpcConfig == null) return null;

  final secureStorage = ref.watch(secureStorageProvider);
  final isDebug = ref.watch(isDebugProvider);

  final manager = GrpcClientManager(
    config: grpcConfig,
    secureStorage: secureStorage,
    enableLogging: isDebug,
  );

  ref.onDispose(() => manager.shutdown());
  return manager;
});

// ─────────────────────────────────────────────────────────────
// REST
// ─────────────────────────────────────────────────────────────

/// Provider for REST client.
final restClientProvider = Provider<RestClient?>((ref) {
  final restConfig = ref.watch(restConfigProvider);
  if (restConfig == null) return null;

  final secureStorage = ref.watch(secureStorageProvider);
  final database = ref.watch(appDatabaseProvider);
  final retryPolicy = ref.watch(retryPolicyProvider);
  final cachePolicy = ref.watch(cachePolicyProvider);
  final isDebug = ref.watch(isDebugProvider);

  return RestClient(
    config: restConfig,
    secureStorage: secureStorage,
    database: database,
    retryPolicy: retryPolicy,
    cachePolicy: cachePolicy,
    enableLogging: isDebug,
  );
});

// ─────────────────────────────────────────────────────────────
// WEBSOCKET
// ─────────────────────────────────────────────────────────────

/// Provider for WebSocket configuration.
final webSocketConfigProvider = Provider<WebSocketConfig?>((ref) {
  // Override this in your app to provide WebSocket config
  return null;
});

/// Provider for WebSocket client.
final webSocketClientProvider = Provider<WebSocketClient?>((ref) {
  final config = ref.watch(webSocketConfigProvider);
  if (config == null) return null;

  final secureStorage = ref.watch(secureStorageProvider);

  final client = WebSocketClient(
    config: config,
    tokenProvider: () => secureStorage.getAccessToken(),
  );

  ref.onDispose(() => client.dispose());
  return client;
});

/// Provider for WebSocket connection state.
final webSocketStateProvider = StreamProvider<WebSocketState>((ref) {
  final client = ref.watch(webSocketClientProvider);
  if (client == null) return Stream.value(WebSocketState.disconnected);
  return client.stateChanges;
});

/// Provider for WebSocket messages.
final webSocketMessagesProvider = StreamProvider<WebSocketMessage>((ref) {
  final client = ref.watch(webSocketClientProvider);
  if (client == null) return const Stream.empty();
  return client.messages;
});
