import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:foundation_core/foundation_core.dart';
import 'package:foundation_storage/foundation_storage.dart';

import '../core/cache_policy.dart';

/// Dio interceptor that caches responses based on a cache policy.
class CacheInterceptor extends Interceptor {
  final AppDatabase _database;
  final CachePolicy _policy;
  final AppLogger _log = AppLogger('CacheInterceptor');

  CacheInterceptor({
    required AppDatabase database,
    CachePolicy? policy,
  })  : _database = database,
        _policy = policy ?? CachePolicy.defaults();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_policy.enabled) {
      return handler.next(options);
    }

    // Skip cache if requested
    if (options.extra['skipCache'] == true ||
        options.extra['forceRefresh'] == true) {
      return handler.next(options);
    }

    // Only cache GET requests (by default)
    if (options.method.toUpperCase() != 'GET' && !_policy.cachePost) {
      return handler.next(options);
    }

    // Check cache
    final cacheKey = _createCacheKey(options);
    final cached = await _getFromCache(cacheKey);

    if (cached != null) {
      _log.debug('Cache hit: ${options.uri.path}');
      return handler.resolve(
        Response(
          requestOptions: options,
          data: cached.data,
          statusCode: cached.statusCode,
          headers: Headers.fromMap(
            cached.headers.map((k, v) => MapEntry(k, [v])),
          ),
          extra: {'fromCache': true, 'cachedAt': cached.cachedAt.toIso8601String()},
        ),
      );
    }

    _log.debug('Cache miss: ${options.uri.path}');
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (!_policy.enabled) {
      return handler.next(response);
    }

    // Don't cache if already from cache
    if (response.extra['fromCache'] == true) {
      return handler.next(response);
    }

    // Check if should cache
    final shouldCache = _policy.shouldCache(
      response.requestOptions.method,
      response.requestOptions.uri.path,
      response.statusCode ?? 0,
    );

    if (shouldCache) {
      final cacheKey = _createCacheKey(response.requestOptions);
      await _saveToCache(cacheKey, response);
      _log.debug('Cached: ${response.requestOptions.uri.path}');
    }

    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Try to return stale cache on error
    if (_policy.useStaleOnError && _isNetworkError(err)) {
      final cacheKey = _createCacheKey(err.requestOptions);
      final cached = await _getFromCache(cacheKey, allowStale: true);

      if (cached != null && cached.isStaleWithin(_policy.staleWhileRevalidate)) {
        _log.warning('Network error, returning stale cache: ${err.requestOptions.uri.path}');
        return handler.resolve(
          Response(
            requestOptions: err.requestOptions,
            data: cached.data,
            statusCode: cached.statusCode,
            headers: Headers.fromMap(
              cached.headers.map((k, v) => MapEntry(k, [v])),
            ),
            extra: {
              'fromCache': true,
              'isStale': true,
              'cachedAt': cached.cachedAt.toIso8601String(),
            },
          ),
        );
      }
    }

    handler.next(err);
  }

  String _createCacheKey(RequestOptions options) {
    return _policy.createCacheKey(
      options.method,
      options.uri.toString(),
      body: options.data is Map ? options.data as Map<String, dynamic> : null,
    );
  }

  Future<CachedResponse?> _getFromCache(String key, {bool allowStale = false}) async {
    final value = await _database.getCachedValue(key);
    if (value == null) return null;

    try {
      final json = jsonDecode(value) as Map<String, dynamic>;
      final cached = CachedResponse(
        data: json['data'],
        statusCode: json['statusCode'] as int,
        headers: Map<String, String>.from(json['headers'] as Map),
        cachedAt: DateTime.parse(json['cachedAt'] as String),
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );

      if (!allowStale && cached.isExpired) {
        return null;
      }

      return cached;
    } catch (e) {
      _log.warning('Failed to parse cached response: $e');
      return null;
    }
  }

  Future<void> _saveToCache(String key, Response response) async {
    final now = DateTime.now();
    final expiresAt = now.add(_policy.ttl);

    final cacheData = {
      'data': response.data,
      'statusCode': response.statusCode,
      'headers': response.headers.map.map((k, v) => MapEntry(k, v.first)),
      'cachedAt': now.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };

    await _database.setCachedValue(
      key,
      jsonEncode(cacheData),
      ttl: _policy.ttl,
    );
  }

  bool _isNetworkError(DioException err) {
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        true,
      _ => false,
    };
  }

  /// Clears all cached responses.
  Future<void> clearCache() async {
    await _database.deleteExpiredCache();
    _log.info('Cache cleared');
  }
}
