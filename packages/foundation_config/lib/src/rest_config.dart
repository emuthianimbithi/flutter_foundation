import 'package:equatable/equatable.dart';

/// Configuration for REST API connections.
class RestConfig extends Equatable {
  /// The base URL for REST API requests.
  final String baseUrl;

  /// The connection timeout.
  final Duration connectionTimeout;

  /// The receive timeout.
  final Duration receiveTimeout;

  /// The send timeout.
  final Duration sendTimeout;

  /// Custom headers to include with every request.
  final Map<String, String> headers;

  /// Whether to enable logging.
  final bool enableLogging;

  /// Whether to follow redirects.
  final bool followRedirects;

  /// Maximum number of redirects to follow.
  final int maxRedirects;

  /// Whether to validate SSL certificates.
  final bool validateCertificates;

  const RestConfig({
    required this.baseUrl,
    this.connectionTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.headers = const {},
    this.enableLogging = false,
    this.followRedirects = true,
    this.maxRedirects = 5,
    this.validateCertificates = true,
  });

  /// Creates a config for localhost development.
  factory RestConfig.localhost({
    int port = 8080,
    String path = '/api/v1',
  }) =>
      RestConfig(
        baseUrl: 'http://localhost:$port$path',
        enableLogging: true,
        validateCertificates: false,
      );

  /// Creates a copy with modified properties.
  RestConfig copyWith({
    String? baseUrl,
    Duration? connectionTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Map<String, String>? headers,
    bool? enableLogging,
    bool? followRedirects,
    int? maxRedirects,
    bool? validateCertificates,
  }) =>
      RestConfig(
        baseUrl: baseUrl ?? this.baseUrl,
        connectionTimeout: connectionTimeout ?? this.connectionTimeout,
        receiveTimeout: receiveTimeout ?? this.receiveTimeout,
        sendTimeout: sendTimeout ?? this.sendTimeout,
        headers: headers ?? this.headers,
        enableLogging: enableLogging ?? this.enableLogging,
        followRedirects: followRedirects ?? this.followRedirects,
        maxRedirects: maxRedirects ?? this.maxRedirects,
        validateCertificates: validateCertificates ?? this.validateCertificates,
      );

  /// Adds headers to the config.
  RestConfig withHeaders(Map<String, String> additionalHeaders) => copyWith(
        headers: {...headers, ...additionalHeaders},
      );

  @override
  List<Object?> get props => [
        baseUrl,
        connectionTimeout,
        receiveTimeout,
        sendTimeout,
        headers,
        enableLogging,
        followRedirects,
        maxRedirects,
        validateCertificates,
      ];

  @override
  String toString() => 'RestConfig($baseUrl)';
}
