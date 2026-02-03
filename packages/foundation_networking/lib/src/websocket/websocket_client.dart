import 'dart:async';
import 'dart:convert';

import 'package:foundation_core/foundation_core.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'websocket_message.dart';

/// WebSocket connection state.
enum WebSocketState {
  /// Not connected.
  disconnected,

  /// Connecting.
  connecting,

  /// Connected.
  connected,

  /// Reconnecting after disconnect.
  reconnecting,

  /// Permanently closed.
  closed,
}

/// Configuration for WebSocket client.
class WebSocketConfig {
  /// The WebSocket URL.
  final String url;

  /// Headers to include in connection.
  final Map<String, String>? headers;

  /// Protocols to request.
  final List<String>? protocols;

  /// Ping interval for keepalive.
  final Duration pingInterval;

  /// Connection timeout.
  final Duration connectTimeout;

  /// Whether to auto-reconnect on disconnect.
  final bool autoReconnect;

  /// Maximum reconnect attempts.
  final int maxReconnectAttempts;

  /// Initial reconnect delay.
  final Duration reconnectDelay;

  /// Maximum reconnect delay.
  final Duration maxReconnectDelay;

  const WebSocketConfig({
    required this.url,
    this.headers,
    this.protocols,
    this.pingInterval = const Duration(seconds: 30),
    this.connectTimeout = const Duration(seconds: 10),
    this.autoReconnect = true,
    this.maxReconnectAttempts = 5,
    this.reconnectDelay = const Duration(seconds: 1),
    this.maxReconnectDelay = const Duration(seconds: 30),
  });
}

/// WebSocket client with auto-reconnect and message handling.
///
/// Example:
/// ```dart
/// final client = WebSocketClient(
///   config: WebSocketConfig(url: 'wss://api.example.com/ws'),
/// );
///
/// // Listen to messages
/// client.messages.listen((message) {
///   print('Received: ${message.asJson}');
/// });
///
/// // Connect
/// await client.connect();
///
/// // Send message
/// client.send(WebSocketMessage.json({'type': 'subscribe', 'topic': 'updates'}));
///
/// // Disconnect
/// await client.disconnect();
/// ```
class WebSocketClient {
  final WebSocketConfig _config;
  final AppLogger _log = AppLogger('WebSocketClient');

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _pingTimer;
  Timer? _reconnectTimer;

  int _reconnectAttempts = 0;
  WebSocketState _state = WebSocketState.disconnected;

  final _messageController = StreamController<WebSocketMessage>.broadcast();
  final _stateController = StreamController<WebSocketState>.broadcast();

  /// Callback for getting auth token.
  Future<String?> Function()? tokenProvider;

  WebSocketClient({
    required WebSocketConfig config,
    this.tokenProvider,
  }) : _config = config;

  /// The current connection state.
  WebSocketState get state => _state;

  /// Whether currently connected.
  bool get isConnected => _state == WebSocketState.connected;

  /// Stream of incoming messages.
  Stream<WebSocketMessage> get messages => _messageController.stream;

  /// Stream of state changes.
  Stream<WebSocketState> get stateChanges => _stateController.stream;

  /// Connects to the WebSocket server.
  Future<bool> connect() async {
    if (_state == WebSocketState.connected) {
      _log.debug('Already connected');
      return true;
    }

    _setState(WebSocketState.connecting);

    try {
      // Build URL with token if available
      var url = _config.url;
      if (tokenProvider != null) {
        final token = await tokenProvider!();
        if (token != null) {
          url = '$url?token=$token';
        }
      }

      _log.info('Connecting to WebSocket: ${_config.url}');

      _channel = WebSocketChannel.connect(
        Uri.parse(url),
        protocols: _config.protocols,
      );

      // Wait for connection
      await _channel!.ready.timeout(_config.connectTimeout);

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      _startPingTimer();
      _setState(WebSocketState.connected);
      _reconnectAttempts = 0;

      _messageController.add(WebSocketMessage.connected());
      _log.info('WebSocket connected');

      return true;
    } catch (e, s) {
      _log.error('WebSocket connection failed', e, s);
      _setState(WebSocketState.disconnected);

      if (_config.autoReconnect) {
        _scheduleReconnect();
      }

      return false;
    }
  }

  /// Disconnects from the WebSocket server.
  Future<void> disconnect({int? closeCode, String? closeReason}) async {
    _log.info('Disconnecting WebSocket');

    _stopPingTimer();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    await _subscription?.cancel();
    _subscription = null;

    await _channel?.sink.close(closeCode ?? 1000, closeReason);
    _channel = null;

    _setState(WebSocketState.closed);
    _messageController.add(WebSocketMessage.disconnected(reason: closeReason));
  }

  /// Sends a message.
  void send(WebSocketMessage message) {
    if (!isConnected) {
      _log.warning('Cannot send, not connected');
      return;
    }

    final data = message.toWireFormat();
    _channel!.sink.add(data);
    _log.debug('Sent: ${message.type}');
  }

  /// Sends a JSON message.
  void sendJson(Map<String, dynamic> data) {
    send(WebSocketMessage.json(data));
  }

  /// Sends a text message.
  void sendText(String text) {
    send(WebSocketMessage.text(text));
  }

  /// Sends raw data.
  void sendRaw(dynamic data) {
    if (!isConnected) return;
    _channel!.sink.add(data);
  }

  void _onMessage(dynamic data) {
    final message = WebSocketMessage.parse(data);
    _log.debug('Received: ${message.type}');
    _messageController.add(message);
  }

  void _onError(Object error, StackTrace stackTrace) {
    _log.error('WebSocket error', error, stackTrace);
    _messageController.add(WebSocketMessage.error(error.toString()));
  }

  void _onDone() {
    _log.info('WebSocket connection closed');
    _stopPingTimer();
    _setState(WebSocketState.disconnected);
    _messageController.add(WebSocketMessage.disconnected());

    if (_config.autoReconnect && _state != WebSocketState.closed) {
      _scheduleReconnect();
    }
  }

  void _startPingTimer() {
    _pingTimer = Timer.periodic(_config.pingInterval, (_) {
      if (isConnected) {
        try {
          // Send ping (as JSON for compatibility)
          sendJson({'type': 'ping'});
        } catch (e) {
          _log.warning('Ping failed: $e');
        }
      }
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _config.maxReconnectAttempts) {
      _log.warning('Max reconnect attempts reached');
      _setState(WebSocketState.closed);
      return;
    }

    _setState(WebSocketState.reconnecting);
    _reconnectAttempts++;

    // Exponential backoff
    final delay = Duration(
      milliseconds: (_config.reconnectDelay.inMilliseconds *
              (1 << (_reconnectAttempts - 1)))
          .clamp(0, _config.maxReconnectDelay.inMilliseconds),
    );

    _log.info('Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)');

    _reconnectTimer = Timer(delay, () {
      connect();
    });
  }

  void _setState(WebSocketState state) {
    if (_state != state) {
      _state = state;
      _stateController.add(state);
    }
  }

  /// Disposes the client.
  void dispose() {
    disconnect();
    _messageController.close();
    _stateController.close();
  }
}
