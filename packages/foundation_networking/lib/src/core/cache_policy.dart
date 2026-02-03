/// Policy for caching network responses.
class CachePolicy {
  /// Whether caching is enabled.
  final bool enabled;

  /// Time-to-live for cached responses.
  final Duration ttl;

  /// Maximum cache size in bytes (0 = unlimited).
  final int maxSize;

  /// Whether to cache GET requests.
  final bool cacheGet;

  /// Whether to cache POST requests.
  final bool cachePost;

  /// HTTP status codes that should be cached.
  final Set<int> cacheableStatusCodes;

  /// Paths that should always be cached.
  final Set<String> forceCachePaths;

  /// Paths that should never be cached.
  final Set<String> neverCachePaths;

  /// Whether to use stale cache when network fails.
  final bool useStaleOnError;

  /// How long stale cache can be used.
  final Duration staleWhileRevalidate;

  const CachePolicy({
    this.enabled = true,
    this.ttl = const Duration(minutes: 5),
    this.maxSize = 50 * 1024 * 1024, // 50MB
    this.cacheGet = true,
    this.cachePost = false,
    this.cacheableStatusCodes = const {200, 201, 204, 301, 304},
    this.forceCachePaths = const {},
    this.neverCachePaths = const {},
    this.useStaleOnError = true,
    this.staleWhileRevalidate = const Duration(hours: 1),
  });

  /// No caching.
  factory CachePolicy.none() => const CachePolicy(enabled: false);

  /// Default cache policy.
  factory CachePolicy.defaults() => const CachePolicy();

  /// Aggressive caching for offline-first.
  factory CachePolicy.offlineFirst() => const CachePolicy(
        ttl: Duration(hours: 24),
        useStaleOnError: true,
        staleWhileRevalidate: Duration(days: 7),
      );

  /// Short-lived cache.
  factory CachePolicy.shortLived() => const CachePolicy(
        ttl: Duration(seconds: 30),
        useStaleOnError: false,
      );

  /// Whether a request should be cached.
  bool shouldCache(String method, String path, int statusCode) {
    if (!enabled) return false;

    // Check never-cache paths
    if (neverCachePaths.any((p) => path.startsWith(p))) {
      return false;
    }

    // Check force-cache paths
    if (forceCachePaths.any((p) => path.startsWith(p))) {
      return true;
    }

    // Check method
    if (method.toUpperCase() == 'GET' && !cacheGet) return false;
    if (method.toUpperCase() == 'POST' && !cachePost) return false;

    // Only cache GET and POST (if enabled)
    if (method.toUpperCase() != 'GET' && method.toUpperCase() != 'POST') {
      return false;
    }

    // Check status code
    return cacheableStatusCodes.contains(statusCode);
  }

  /// Creates a cache key for a request.
  String createCacheKey(String method, String url, {Map<String, dynamic>? body}) {
    var key = '${method.toUpperCase()}:$url';
    if (body != null && body.isNotEmpty) {
      key += ':${body.hashCode}';
    }
    return key;
  }

  /// Creates a copy with modified settings.
  CachePolicy copyWith({
    bool? enabled,
    Duration? ttl,
    int? maxSize,
    bool? cacheGet,
    bool? cachePost,
    Set<int>? cacheableStatusCodes,
    Set<String>? forceCachePaths,
    Set<String>? neverCachePaths,
    bool? useStaleOnError,
    Duration? staleWhileRevalidate,
  }) =>
      CachePolicy(
        enabled: enabled ?? this.enabled,
        ttl: ttl ?? this.ttl,
        maxSize: maxSize ?? this.maxSize,
        cacheGet: cacheGet ?? this.cacheGet,
        cachePost: cachePost ?? this.cachePost,
        cacheableStatusCodes: cacheableStatusCodes ?? this.cacheableStatusCodes,
        forceCachePaths: forceCachePaths ?? this.forceCachePaths,
        neverCachePaths: neverCachePaths ?? this.neverCachePaths,
        useStaleOnError: useStaleOnError ?? this.useStaleOnError,
        staleWhileRevalidate: staleWhileRevalidate ?? this.staleWhileRevalidate,
      );
}

/// Cached response data.
class CachedResponse {
  /// The response data.
  final dynamic data;

  /// The status code.
  final int statusCode;

  /// Response headers.
  final Map<String, String> headers;

  /// When the response was cached.
  final DateTime cachedAt;

  /// When the cache expires.
  final DateTime expiresAt;

  const CachedResponse({
    required this.data,
    required this.statusCode,
    required this.headers,
    required this.cachedAt,
    required this.expiresAt,
  });

  /// Whether the cache has expired.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Whether the cache is stale but usable.
  bool isStaleWithin(Duration duration) {
    return DateTime.now().isBefore(expiresAt.add(duration));
  }

  /// Age of the cached response.
  Duration get age => DateTime.now().difference(cachedAt);
}
