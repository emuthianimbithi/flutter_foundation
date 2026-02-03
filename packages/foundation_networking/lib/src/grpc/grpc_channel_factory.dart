import 'package:foundation_config/foundation_config.dart';
import 'package:foundation_core/foundation_core.dart';
import 'package:grpc/grpc.dart';

import 'grpc_interceptors.dart';

/// Factory for creating gRPC channels with proper configuration.
class GrpcChannelFactory {
  final GrpcConfig _config;
  final List<ClientInterceptor> _interceptors;
  final AppLogger _log = AppLogger('GrpcChannelFactory');

  ClientChannel? _channel;

  GrpcChannelFactory({
    required GrpcConfig config,
    List<ClientInterceptor>? interceptors,
  })  : _config = config,
        _interceptors = interceptors ?? [];

  /// The gRPC configuration.
  GrpcConfig get config => _config;

  /// The list of interceptors.
  List<ClientInterceptor> get interceptors => List.unmodifiable(_interceptors);

  /// Adds an interceptor.
  void addInterceptor(ClientInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  /// Adds an auth interceptor.
  void addAuthInterceptor(TokenProvider tokenProvider) {
    addInterceptor(GrpcAuthInterceptor(tokenProvider));
  }

  /// Adds a refresh interceptor.
  void addRefreshInterceptor({
    required TokenProvider tokenProvider,
    required TokenRefresher tokenRefresher,
  }) {
    addInterceptor(GrpcRefreshInterceptor(
      tokenProvider: tokenProvider,
      tokenRefresher: tokenRefresher,
    ));
  }

  /// Adds a logging interceptor.
  void addLoggingInterceptor({
    bool logMetadata = false,
    bool logRequest = false,
    bool logResponse = false,
  }) {
    addInterceptor(GrpcLoggingInterceptor(
      logMetadata: logMetadata,
      logRequest: logRequest,
      logResponse: logResponse,
    ));
  }

  /// Adds a metadata interceptor.
  void addMetadataInterceptor(Map<String, String> Function() provider) {
    addInterceptor(GrpcMetadataInterceptor(provider));
  }

  /// Creates or returns the existing channel.
  ClientChannel getChannel() {
    if (_channel != null) return _channel!;

    _log.info('Creating gRPC channel to ${_config.url}');

    final options = ChannelOptions(
      credentials: _config.useTls
          ? const ChannelCredentials.secure()
          : const ChannelCredentials.insecure(),
      connectionTimeout: _config.connectionTimeout,
      idleTimeout: _config.idleTimeout,
      codecRegistry:
          CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
    );

    _channel = ClientChannel(
      _config.host,
      port: _config.port,
      options: options,
    );

    return _channel!;
  }

  /// Creates default call options.
  CallOptions get defaultCallOptions => CallOptions(
        timeout: _config.connectionTimeout,
        metadata: {
          if (_config.userAgent != null) 'user-agent': _config.userAgent!,
        },
      );

  /// Creates call options with custom timeout.
  CallOptions callOptionsWithTimeout(Duration timeout) => CallOptions(
        timeout: timeout,
        metadata: {
          if (_config.userAgent != null) 'user-agent': _config.userAgent!,
        },
      );

  /// Shuts down the channel.
  Future<void> shutdown() async {
    if (_channel != null) {
      _log.info('Shutting down gRPC channel');
      await _channel!.shutdown();
      _channel = null;
    }
  }

  /// Terminates the channel immediately.
  Future<void> terminate() async {
    if (_channel != null) {
      _log.info('Terminating gRPC channel');
      await _channel!.terminate();
      _channel = null;
    }
  }
}

/// Builder for creating configured [GrpcChannelFactory].
class GrpcChannelFactoryBuilder {
  GrpcConfig? _config;
  final List<ClientInterceptor> _interceptors = [];
  TokenProvider? _tokenProvider;
  TokenRefresher? _tokenRefresher;
  bool _enableLogging = false;
  bool _logMetadata = false;
  bool _logRequest = false;
  bool _logResponse = false;
  Map<String, String> Function()? _metadataProvider;

  /// Sets the gRPC configuration.
  GrpcChannelFactoryBuilder withConfig(GrpcConfig config) {
    _config = config;
    return this;
  }

  /// Sets the host and port.
  GrpcChannelFactoryBuilder withHost(String host,
      {int port = 443, bool useTls = true}) {
    _config = GrpcConfig(host: host, port: port, useTls: useTls);
    return this;
  }

  /// Adds authentication.
  GrpcChannelFactoryBuilder withAuth(TokenProvider tokenProvider) {
    _tokenProvider = tokenProvider;
    return this;
  }

  /// Adds token refresh.
  GrpcChannelFactoryBuilder withRefresh({
    required TokenProvider tokenProvider,
    required TokenRefresher tokenRefresher,
  }) {
    _tokenProvider = tokenProvider;
    _tokenRefresher = tokenRefresher;
    return this;
  }

  /// Enables logging.
  GrpcChannelFactoryBuilder withLogging({
    bool logMetadata = false,
    bool logRequest = false,
    bool logResponse = false,
  }) {
    _enableLogging = true;
    _logMetadata = logMetadata;
    _logRequest = logRequest;
    _logResponse = logResponse;
    return this;
  }

  /// Adds custom metadata.
  GrpcChannelFactoryBuilder withMetadata(
      Map<String, String> Function() provider) {
    _metadataProvider = provider;
    return this;
  }

  /// Adds static metadata.
  GrpcChannelFactoryBuilder withStaticMetadata(Map<String, String> metadata) {
    _metadataProvider = () => metadata;
    return this;
  }

  /// Adds a custom interceptor.
  GrpcChannelFactoryBuilder withInterceptor(ClientInterceptor interceptor) {
    _interceptors.add(interceptor);
    return this;
  }

  /// Builds the factory.
  GrpcChannelFactory build() {
    if (_config == null) {
      throw StateError('GrpcConfig is required');
    }

    final factory = GrpcChannelFactory(config: _config!);

    // Add logging first (to capture all requests)
    if (_enableLogging) {
      factory.addLoggingInterceptor(
        logMetadata: _logMetadata,
        logRequest: _logRequest,
        logResponse: _logResponse,
      );
    }

    // Add metadata
    if (_metadataProvider != null) {
      factory.addMetadataInterceptor(_metadataProvider!);
    }

    // Add auth (with or without refresh)
    if (_tokenRefresher != null && _tokenProvider != null) {
      factory.addRefreshInterceptor(
        tokenProvider: _tokenProvider!,
        tokenRefresher: _tokenRefresher!,
      );
    } else if (_tokenProvider != null) {
      factory.addAuthInterceptor(_tokenProvider!);
    }

    // Add custom interceptors
    for (final interceptor in _interceptors) {
      factory.addInterceptor(interceptor);
    }

    return factory;
  }
}
