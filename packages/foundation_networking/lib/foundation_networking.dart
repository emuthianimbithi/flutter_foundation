/// Networking layer for Flutter Foundation.
///
/// This library provides:
///
/// - [GrpcClientManager] - gRPC channel management and client wrapper
/// - [RestClient] - Dio-based REST client with interceptors
/// - [WebSocketClient] - WebSocket client for real-time communication
/// - [MqttClient] - MQTT client for pub/sub messaging
/// - [GraphQLClient] - GraphQL client
/// - [FirestoreClient] - Firestore wrapper with offline support
/// - Various interceptors for auth, retry, logging, caching
library foundation_networking;

// Core
export 'src/core/network_info.dart';
export 'src/core/network_exceptions.dart';
export 'src/core/retry_policy.dart';
export 'src/core/cache_policy.dart';
export 'src/core/request_options.dart';

// Interceptors
export 'src/interceptors/auth_interceptor.dart';
export 'src/interceptors/refresh_interceptor.dart';
export 'src/interceptors/logging_interceptor.dart';
export 'src/interceptors/retry_interceptor.dart';
export 'src/interceptors/cache_interceptor.dart';

// gRPC
export 'src/grpc/grpc_client_manager.dart';
export 'src/grpc/grpc_channel_factory.dart';
export 'src/grpc/grpc_interceptors.dart';
export 'src/grpc/grpc_error_mapper.dart';

// REST
export 'src/rest/rest_client.dart';
export 'src/rest/dio_factory.dart';
export 'src/rest/api_response.dart';

// WebSocket
export 'src/websocket/websocket_client.dart';
export 'src/websocket/websocket_message.dart';

// MQTT
export 'src/mqtt/mqtt_client_wrapper.dart';
export 'src/mqtt/mqtt_message.dart';

// GraphQL
export 'src/graphql/graphql_client_wrapper.dart';

// Firestore
export 'src/firestore/firestore_client.dart';

// Providers
export 'src/providers.dart';
