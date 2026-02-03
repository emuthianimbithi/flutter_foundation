import 'package:dio/dio.dart';
import 'package:foundation_config/foundation_config.dart';
import 'package:foundation_core/foundation_core.dart';
import 'package:foundation_storage/foundation_storage.dart';

import '../core/cache_policy.dart';
import '../core/retry_policy.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/cache_interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../interceptors/refresh_interceptor.dart';
import '../interceptors/retry_interceptor.dart';

/// Factory for creating configured Dio instances.
class DioFactory {
  DioFactory._();

  static final AppLogger _log = AppLogger('DioFactory');

  /// Creates a basic Dio instance with configuration.
  static Dio create(RestConfig config) {
    _log.debug('Creating Dio instance for ${config.baseUrl}');

    final dio = Dio(
      BaseOptions(
        baseUrl: config.baseUrl,
        connectTimeout: config.connectionTimeout,
        receiveTimeout: config.receiveTimeout,
        sendTimeout: config.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...config.headers,
        },
        followRedirects: config.followRedirects,
        maxRedirects: config.maxRedirects,
      ),
    );

    return dio;
  }

  /// Creates a fully configured Dio instance with all interceptors.
  static Dio createWithInterceptors({
    required RestConfig config,
    required SecureStorage secureStorage,
    required AppDatabase database,
    void Function()? onAuthFailure,
    Future<String?> Function()? onTokenRefresh,
    RetryPolicy? retryPolicy,
    CachePolicy? cachePolicy,
    bool enableLogging = false,
  }) {
    final dio = create(config);

    // Add logging first (to capture everything)
    if (enableLogging || config.enableLogging) {
      dio.interceptors.add(
        LoggingInterceptor(
          logRequest: true,
          logResponse: true,
          logErrors: true,
          logRequestHeaders: true,
          logResponseBody: false, // Can be verbose
        ),
      );
    }

    // Add cache interceptor
    if (cachePolicy?.enabled ?? true) {
      dio.interceptors.add(
        CacheInterceptor(
          database: database,
          policy: cachePolicy,
        ),
      );
    }

    // Add retry interceptor
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        policy: retryPolicy,
      ),
    );

    // Add auth interceptor
    dio.interceptors.add(
      AuthInterceptor(
        tokenProvider: () => secureStorage.getAccessToken(),
      ),
    );

    // Add refresh interceptor if refresh handler provided
    if (onTokenRefresh != null) {
      dio.interceptors.add(
        RefreshInterceptor(
          dio: dio,
          tokenProvider: () => secureStorage.getAccessToken(),
          tokenRefresher: onTokenRefresh,
          onAuthFailure: onAuthFailure,
        ),
      );
    }

    return dio;
  }
}

/// Builder for creating configured Dio instances.
class DioBuilder {
  RestConfig? _config;
  SecureStorage? _secureStorage;
  AppDatabase? _database;
  void Function()? _onAuthFailure;
  Future<String?> Function()? _onTokenRefresh;
  RetryPolicy? _retryPolicy;
  CachePolicy? _cachePolicy;
  bool _enableLogging = false;
  final List<Interceptor> _customInterceptors = [];
  final Map<String, String> _additionalHeaders = {};

  /// Sets the REST configuration.
  DioBuilder withConfig(RestConfig config) {
    _config = config;
    return this;
  }

  /// Sets the base URL.
  DioBuilder withBaseUrl(String baseUrl) {
    _config = RestConfig(baseUrl: baseUrl);
    return this;
  }

  /// Sets the secure storage for tokens.
  DioBuilder withSecureStorage(SecureStorage storage) {
    _secureStorage = storage;
    return this;
  }

  /// Sets the database for caching.
  DioBuilder withDatabase(AppDatabase database) {
    _database = database;
    return this;
  }

  /// Sets the auth failure callback.
  DioBuilder withAuthFailureHandler(void Function() handler) {
    _onAuthFailure = handler;
    return this;
  }

  /// Sets the token refresh callback.
  DioBuilder withTokenRefresh(Future<String?> Function() refresher) {
    _onTokenRefresh = refresher;
    return this;
  }

  /// Sets the retry policy.
  DioBuilder withRetryPolicy(RetryPolicy policy) {
    _retryPolicy = policy;
    return this;
  }

  /// Sets the cache policy.
  DioBuilder withCachePolicy(CachePolicy policy) {
    _cachePolicy = policy;
    return this;
  }

  /// Enables logging.
  DioBuilder withLogging([bool enable = true]) {
    _enableLogging = enable;
    return this;
  }

  /// Adds a custom interceptor.
  DioBuilder withInterceptor(Interceptor interceptor) {
    _customInterceptors.add(interceptor);
    return this;
  }

  /// Adds additional headers.
  DioBuilder withHeaders(Map<String, String> headers) {
    _additionalHeaders.addAll(headers);
    return this;
  }

  /// Builds the Dio instance.
  Dio build() {
    if (_config == null) {
      throw StateError('RestConfig is required');
    }

    // Add additional headers to config
    final config = _additionalHeaders.isEmpty
        ? _config!
        : _config!.withHeaders(_additionalHeaders);

    // If we have storage and database, use full interceptors
    if (_secureStorage != null && _database != null) {
      final dio = DioFactory.createWithInterceptors(
        config: config,
        secureStorage: _secureStorage!,
        database: _database!,
        onAuthFailure: _onAuthFailure,
        onTokenRefresh: _onTokenRefresh,
        retryPolicy: _retryPolicy,
        cachePolicy: _cachePolicy,
        enableLogging: _enableLogging,
      );

      // Add custom interceptors
      for (final interceptor in _customInterceptors) {
        dio.interceptors.add(interceptor);
      }

      return dio;
    }

    // Otherwise create basic Dio
    final dio = DioFactory.create(config);

    if (_enableLogging) {
      dio.interceptors.add(LoggingInterceptor());
    }

    for (final interceptor in _customInterceptors) {
      dio.interceptors.add(interceptor);
    }

    return dio;
  }
}
