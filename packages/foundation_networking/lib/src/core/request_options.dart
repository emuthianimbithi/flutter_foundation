import 'cache_policy.dart';
import 'retry_policy.dart';

/// Options for a network request.
class NetworkRequestOptions {
  /// Request timeout.
  final Duration? timeout;

  /// Whether to require authentication.
  final bool requiresAuth;

  /// Custom headers.
  final Map<String, String>? headers;

  /// Retry policy override.
  final RetryPolicy? retryPolicy;

  /// Cache policy override.
  final CachePolicy? cachePolicy;

  /// Whether to skip cache for this request.
  final bool skipCache;

  /// Whether to force refresh from network.
  final bool forceRefresh;

  /// Tags for categorizing the request.
  final Set<String>? tags;

  /// Custom metadata.
  final Map<String, dynamic>? metadata;

  const NetworkRequestOptions({
    this.timeout,
    this.requiresAuth = true,
    this.headers,
    this.retryPolicy,
    this.cachePolicy,
    this.skipCache = false,
    this.forceRefresh = false,
    this.tags,
    this.metadata,
  });

  /// Default options.
  factory NetworkRequestOptions.defaults() => const NetworkRequestOptions();

  /// Options for unauthenticated requests.
  factory NetworkRequestOptions.noAuth() => const NetworkRequestOptions(
        requiresAuth: false,
      );

  /// Options for requests that should skip cache.
  factory NetworkRequestOptions.noCache() => const NetworkRequestOptions(
        skipCache: true,
      );

  /// Options for forced refresh.
  factory NetworkRequestOptions.refresh() => const NetworkRequestOptions(
        forceRefresh: true,
        skipCache: true,
      );

  /// Creates a copy with modified settings.
  NetworkRequestOptions copyWith({
    Duration? timeout,
    bool? requiresAuth,
    Map<String, String>? headers,
    RetryPolicy? retryPolicy,
    CachePolicy? cachePolicy,
    bool? skipCache,
    bool? forceRefresh,
    Set<String>? tags,
    Map<String, dynamic>? metadata,
  }) =>
      NetworkRequestOptions(
        timeout: timeout ?? this.timeout,
        requiresAuth: requiresAuth ?? this.requiresAuth,
        headers: headers ?? this.headers,
        retryPolicy: retryPolicy ?? this.retryPolicy,
        cachePolicy: cachePolicy ?? this.cachePolicy,
        skipCache: skipCache ?? this.skipCache,
        forceRefresh: forceRefresh ?? this.forceRefresh,
        tags: tags ?? this.tags,
        metadata: metadata ?? this.metadata,
      );

  /// Merges headers with additional headers.
  NetworkRequestOptions withHeaders(Map<String, String> additionalHeaders) =>
      copyWith(headers: {...?headers, ...additionalHeaders});

  /// Adds a tag.
  NetworkRequestOptions withTag(String tag) => copyWith(tags: {...?tags, tag});
}
