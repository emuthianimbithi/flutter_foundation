import 'package:equatable/equatable.dart';

/// Configuration for gRPC connections.
class GrpcConfig extends Equatable {
  /// The gRPC server host.
  final String host;

  /// The gRPC server port.
  final int port;

  /// Whether to use TLS.
  final bool useTls;

  /// The connection timeout.
  final Duration connectionTimeout;

  /// The idle timeout.
  final Duration idleTimeout;

  /// Custom authority (for TLS SNI).
  final String? authority;

  /// User agent string.
  final String? userAgent;

  /// Maximum message size in bytes.
  final int maxMessageSize;

  /// Whether to enable keepalive.
  final bool enableKeepalive;

  /// Keepalive interval.
  final Duration keepaliveInterval;

  /// Keepalive timeout.
  final Duration keepaliveTimeout;

  const GrpcConfig({
    required this.host,
    this.port = 443,
    this.useTls = true,
    this.connectionTimeout = const Duration(seconds: 30),
    this.idleTimeout = const Duration(minutes: 5),
    this.authority,
    this.userAgent,
    this.maxMessageSize = 4 * 1024 * 1024, // 4MB
    this.enableKeepalive = true,
    this.keepaliveInterval = const Duration(seconds: 30),
    this.keepaliveTimeout = const Duration(seconds: 10),
  });

  /// Creates a config for localhost development.
  factory GrpcConfig.localhost({
    int port = 50051,
    bool useTls = false,
  }) =>
      GrpcConfig(
        host: 'localhost',
        port: port,
        useTls: useTls,
      );

  /// The full address (host:port).
  String get address => '$host:$port';

  /// The scheme (http or https).
  String get scheme => useTls ? 'https' : 'http';

  /// The full URL.
  String get url => '$scheme://$address';

  /// Creates a copy with modified properties.
  GrpcConfig copyWith({
    String? host,
    int? port,
    bool? useTls,
    Duration? connectionTimeout,
    Duration? idleTimeout,
    String? authority,
    String? userAgent,
    int? maxMessageSize,
    bool? enableKeepalive,
    Duration? keepaliveInterval,
    Duration? keepaliveTimeout,
  }) =>
      GrpcConfig(
        host: host ?? this.host,
        port: port ?? this.port,
        useTls: useTls ?? this.useTls,
        connectionTimeout: connectionTimeout ?? this.connectionTimeout,
        idleTimeout: idleTimeout ?? this.idleTimeout,
        authority: authority ?? this.authority,
        userAgent: userAgent ?? this.userAgent,
        maxMessageSize: maxMessageSize ?? this.maxMessageSize,
        enableKeepalive: enableKeepalive ?? this.enableKeepalive,
        keepaliveInterval: keepaliveInterval ?? this.keepaliveInterval,
        keepaliveTimeout: keepaliveTimeout ?? this.keepaliveTimeout,
      );

  @override
  List<Object?> get props => [
        host,
        port,
        useTls,
        connectionTimeout,
        idleTimeout,
        authority,
        userAgent,
        maxMessageSize,
        enableKeepalive,
        keepaliveInterval,
        keepaliveTimeout,
      ];

  @override
  String toString() => 'GrpcConfig($url)';
}
