import 'dart:async';

import 'package:foundation_core/foundation_core.dart';
import 'package:graphql/client.dart';

/// Configuration for GraphQL client.
class GraphQLConfig {
  /// The GraphQL endpoint URL.
  final String endpoint;

  /// WebSocket endpoint for subscriptions.
  final String? wsEndpoint;

  /// Default fetch policy.
  final FetchPolicy defaultFetchPolicy;

  /// Request timeout.
  final Duration timeout;

  const GraphQLConfig({
    required this.endpoint,
    this.wsEndpoint,
    this.defaultFetchPolicy = FetchPolicy.cacheFirst,
    this.timeout = const Duration(seconds: 30),
  });
}

/// GraphQL client wrapper with simplified API.
///
/// Example:
/// ```dart
/// final client = GraphQLClientWrapper(
///   config: GraphQLConfig(endpoint: 'https://api.example.com/graphql'),
///   tokenProvider: () => secureStorage.getAccessToken(),
/// );
///
/// // Query
/// final result = await client.query(
///   'query GetUser(\$id: ID!) { user(id: \$id) { id name email } }',
///   variables: {'id': '123'},
/// );
///
/// // Mutation
/// final mutationResult = await client.mutate(
///   'mutation CreateUser(\$input: CreateUserInput!) { createUser(input: \$input) { id } }',
///   variables: {'input': {'name': 'John', 'email': 'john@example.com'}},
/// );
///
/// // Subscription
/// client.subscribe(
///   'subscription OnMessage { messageAdded { id content } }',
/// ).listen((result) {
///   print('New message: ${result.data}');
/// });
/// ```
class GraphQLClientWrapper {
  final GraphQLConfig _config;
  final Future<String?> Function()? _tokenProvider;
  final AppLogger _log = AppLogger('GraphQLClient');

  late final GraphQLClient _client;
  GraphQLClient? _wsClient;

  GraphQLClientWrapper({
    required GraphQLConfig config,
    Future<String?> Function()? tokenProvider,
  })  : _config = config,
        _tokenProvider = tokenProvider {
    _initClient();
  }

  void _initClient() {
    final httpLink = HttpLink(_config.endpoint);

    Link link = httpLink;

    // Add auth link if token provider is available
    if (_tokenProvider != null) {
      final authLink = AuthLink(getToken: () async {
        final token = await _tokenProvider!();
        return token != null ? 'Bearer $token' : null;
      });
      link = authLink.concat(httpLink);
    }

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(),
      defaultPolicies: DefaultPolicies(
        query: Policies(fetch: _config.defaultFetchPolicy),
        mutate: Policies(fetch: FetchPolicy.noCache),
      ),
    );
  }

  void _initWsClient() {
    if (_config.wsEndpoint == null || _wsClient != null) return;

    final wsLink = WebSocketLink(
      _config.wsEndpoint!,
      config: SocketClientConfig(
        autoReconnect: true,
        initialPayload: () async {
          if (_tokenProvider != null) {
            final token = await _tokenProvider!();
            if (token != null) {
              return {'Authorization': 'Bearer $token'};
            }
          }
          return null;
        },
      ),
    );

    _wsClient = GraphQLClient(
      link: wsLink,
      cache: GraphQLCache(),
    );
  }

  /// Executes a GraphQL query.
  Future<Result<Map<String, dynamic>>> query(
    String query, {
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
    String? operationName,
  }) async {
    try {
      _log.debug('Query: ${operationName ?? query.substring(0, 50)}...');

      final options = QueryOptions(
        document: gql(query),
        variables: variables ?? {},
        fetchPolicy: fetchPolicy ?? _config.defaultFetchPolicy,
        operationName: operationName,
      );

      final result = await _client.query(options).timeout(_config.timeout);

      if (result.hasException) {
        _log.error('Query failed', result.exception);
        return Result.failure(_mapException(result.exception!));
      }

      return Result.success(result.data ?? {});
    } catch (e, s) {
      _log.error('Query error', e, s);
      return Result.failure(Failure.unexpected(e.toString(), stackTrace: s));
    }
  }

  /// Executes a GraphQL mutation.
  Future<Result<Map<String, dynamic>>> mutate(
    String mutation, {
    Map<String, dynamic>? variables,
    String? operationName,
  }) async {
    try {
      _log.debug('Mutation: ${operationName ?? mutation.substring(0, 50)}...');

      final options = MutationOptions(
        document: gql(mutation),
        variables: variables ?? {},
        operationName: operationName,
      );

      final result = await _client.mutate(options).timeout(_config.timeout);

      if (result.hasException) {
        _log.error('Mutation failed', result.exception);
        return Result.failure(_mapException(result.exception!));
      }

      return Result.success(result.data ?? {});
    } catch (e, s) {
      _log.error('Mutation error', e, s);
      return Result.failure(Failure.unexpected(e.toString(), stackTrace: s));
    }
  }

  /// Creates a GraphQL subscription stream.
  Stream<Result<Map<String, dynamic>>> subscribe(
    String subscription, {
    Map<String, dynamic>? variables,
    String? operationName,
  }) {
    _initWsClient();

    if (_wsClient == null) {
      return Stream.value(
        Result.failure(Failure.unexpected('WebSocket endpoint not configured')),
      );
    }

    _log.debug(
        'Subscribe: ${operationName ?? subscription.substring(0, 50)}...');

    final options = SubscriptionOptions(
      document: gql(subscription),
      variables: variables ?? {},
      operationName: operationName,
    );

    return _wsClient!.subscribe(options).map((result) {
      if (result.hasException) {
        _log.error('Subscription error', result.exception);
        return Result.failure(_mapException(result.exception!));
      }
      return Result.success(result.data ?? {});
    });
  }

  /// Clears the cache.
  void clearCache() {
    _client.cache.store.reset();
    _log.debug('Cache cleared');
  }

  /// Reads from cache.
  Map<String, dynamic>? readQuery(
    String query, {
    Map<String, dynamic>? variables,
  }) {
    final request = Request(
      operation: Operation(document: gql(query)),
      variables: variables ?? {},
    );
    return _client.cache.readQuery(request);
  }

  /// Writes to cache.
  void writeQuery(
    String query, {
    required Map<String, dynamic> data,
    Map<String, dynamic>? variables,
  }) {
    final request = Request(
      operation: Operation(document: gql(query)),
      variables: variables ?? {},
    );
    _client.cache.writeQuery(request, data: data);
  }

  Failure _mapException(OperationException exception) {
    // Check for network errors
    if (exception.linkException != null) {
      final linkException = exception.linkException;
      if (linkException is NetworkException) {
        return Failure.network(linkException.message ?? 'Network error');
      }
      return Failure.network(linkException.toString());
    }

    // Check for GraphQL errors
    if (exception.graphqlErrors.isNotEmpty) {
      final error = exception.graphqlErrors.first;
      final message = error.message;
      final code = error.extensions?['code'] as String?;

      // Map common error codes
      return switch (code) {
        'UNAUTHENTICATED' => Failure.authentication(message),
        'FORBIDDEN' => Failure.authorization(message),
        'NOT_FOUND' => Failure.notFound(message),
        'BAD_USER_INPUT' => Failure.validation(message),
        _ => Failure.server(message, code: code),
      };
    }

    return Failure.unexpected(exception.toString());
  }

  /// Disposes the client.
  void dispose() {
    _wsClient?.cache.store.reset();
  }
}
