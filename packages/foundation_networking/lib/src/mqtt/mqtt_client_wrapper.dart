import 'dart:async';
import 'dart:typed_data';

import 'package:foundation_core/foundation_core.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'mqtt_message.dart';

/// MQTT connection state.
enum MqttConnectionState {
  /// Not connected.
  disconnected,

  /// Connecting.
  connecting,

  /// Connected.
  connected,

  /// Disconnecting.
  disconnecting,

  /// Faulted.
  faulted,
}

/// Configuration for MQTT client.
class MqttConfig {
  /// The broker host.
  final String host;

  /// The broker port.
  final int port;

  /// The client identifier.
  final String clientId;

  /// Whether to use secure connection.
  final bool secure;

  /// Username for authentication.
  final String? username;

  /// Password for authentication.
  final String? password;

  /// Keep alive period.
  final int keepAlivePeriod;

  /// Whether to auto-reconnect.
  final bool autoReconnect;

  /// Connection timeout.
  final Duration connectTimeout;

  /// Last will message.
  final MqttMessage? lastWill;

  const MqttConfig({
    required this.host,
    this.port = 1883,
    required this.clientId,
    this.secure = false,
    this.username,
    this.password,
    this.keepAlivePeriod = 60,
    this.autoReconnect = true,
    this.connectTimeout = const Duration(seconds: 30),
    this.lastWill,
  });

  /// Creates a config for a secure connection.
  factory MqttConfig.secure({
    required String host,
    int port = 8883,
    required String clientId,
    String? username,
    String? password,
  }) =>
      MqttConfig(
        host: host,
        port: port,
        clientId: clientId,
        secure: true,
        username: username,
        password: password,
      );
}

/// MQTT client wrapper with simplified API.
///
/// Example:
/// ```dart
/// final client = MqttClientWrapper(
///   config: MqttConfig(
///     host: 'broker.example.com',
///     clientId: 'my-app',
///   ),
/// );
///
/// // Connect
/// await client.connect();
///
/// // Subscribe
/// client.subscribe('sensors/#');
///
/// // Listen to messages
/// client.messages.listen((msg) {
///   print('${msg.topic}: ${msg.asString}');
/// });
///
/// // Publish
/// client.publish(MqttMessage.json('commands/light', {'state': 'on'}));
/// ```
class MqttClientWrapper {
  final MqttConfig _config;
  final AppLogger _log = AppLogger('MqttClient');

  late final MqttServerClient _client;
  final Set<String> _subscriptions = {};

  final _messageController = StreamController<MqttMessage>.broadcast();
  final _stateController = StreamController<MqttConnectionState>.broadcast();

  MqttConnectionState _state = MqttConnectionState.disconnected;

  MqttClientWrapper({required MqttConfig config}) : _config = config {
    _client = MqttServerClient.withPort(
      _config.host,
      _config.clientId,
      _config.port,
    );

    _client.logging(on: false);
    _client.keepAlivePeriod = _config.keepAlivePeriod;
    _client.autoReconnect = _config.autoReconnect;
    _client.resubscribeOnAutoReconnect = true;
    _client.connectTimeoutPeriod = _config.connectTimeout.inMilliseconds;

    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onAutoReconnect = _onAutoReconnect;
    _client.onAutoReconnected = _onAutoReconnected;
    _client.onSubscribed = _onSubscribed;
    _client.onUnsubscribed = _onUnsubscribed;
  }

  /// The current connection state.
  MqttConnectionState get state => _state;

  /// Whether currently connected.
  bool get isConnected => _state == MqttConnectionState.connected;

  /// Stream of incoming messages.
  Stream<MqttMessage> get messages => _messageController.stream;

  /// Stream of state changes.
  Stream<MqttConnectionState> get stateChanges => _stateController.stream;

  /// Current subscriptions.
  Set<String> get subscriptions => Set.unmodifiable(_subscriptions);

  /// Connects to the MQTT broker.
  Future<bool> connect() async {
    if (isConnected) return true;

    _setState(MqttConnectionState.connecting);

    try {
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(_config.clientId)
          .startClean();

      if (_config.username != null) {
        connMessage.authenticateAs(_config.username, _config.password);
      }

      if (_config.lastWill != null) {
        connMessage.withWillTopic(_config.lastWill!.topic);
        connMessage.withWillMessage(_config.lastWill!.asString);
        connMessage.withWillQos(_mapQos(_config.lastWill!.qos));
        if (_config.lastWill!.retain) {
          connMessage.withWillRetain();
        }
      }

      _client.connectionMessage = connMessage;

      _log.info('Connecting to MQTT broker: ${_config.host}:${_config.port}');

      await _client.connect();

      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        // Listen to updates
        _client.updates?.listen(_onMessage);
        return true;
      }

      _setState(MqttConnectionState.faulted);
      return false;
    } catch (e, s) {
      _log.error('MQTT connection failed', e, s);
      _setState(MqttConnectionState.faulted);
      return false;
    }
  }

  /// Disconnects from the broker.
  Future<void> disconnect() async {
    _setState(MqttConnectionState.disconnecting);
    _client.disconnect();
    _subscriptions.clear();
    _setState(MqttConnectionState.disconnected);
  }

  /// Subscribes to a topic.
  void subscribe(String topic, {MqttQos qos = MqttQos.atMostOnce}) {
    if (!isConnected) {
      _log.warning('Cannot subscribe, not connected');
      return;
    }

    _client.subscribe(topic, _mapQos(qos));
    _subscriptions.add(topic);
    _log.debug('Subscribed to: $topic');
  }

  /// Unsubscribes from a topic.
  void unsubscribe(String topic) {
    if (!isConnected) return;

    _client.unsubscribe(topic);
    _subscriptions.remove(topic);
    _log.debug('Unsubscribed from: $topic');
  }

  /// Publishes a message.
  void publish(MqttMessage message) {
    if (!isConnected) {
      _log.warning('Cannot publish, not connected');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addBuffer(message.payload);

    _client.publishMessage(
      message.topic,
      _mapQos(message.qos),
      builder.payload!,
      retain: message.retain,
    );

    _log.debug('Published to: ${message.topic}');
  }

  /// Publishes a string message.
  void publishString(String topic, String message, {MqttQos qos = MqttQos.atMostOnce}) {
    publish(MqttMessage.string(topic, message, qos: qos));
  }

  /// Publishes a JSON message.
  void publishJson(String topic, Map<String, dynamic> json, {MqttQos qos = MqttQos.atMostOnce}) {
    publish(MqttMessage.json(topic, json, qos: qos));
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage?>>? messages) {
    if (messages == null) return;

    for (final msg in messages) {
      final payload = msg.payload as MqttPublishMessage;
      final topic = msg.topic;
      final data = payload.payload.message;

      final mqttMessage = MqttMessage(
        topic: topic,
        payload: Uint8List.fromList(data),
        qos: _reverseMapQos(payload.header?.qos ?? MqttQos.atMostOnce as MqttQos),
        retain: payload.header?.retain ?? false,
        timestamp: DateTime.now(),
      );

      _messageController.add(mqttMessage);
    }
  }

  void _onConnected() {
    _log.info('MQTT connected');
    _setState(MqttConnectionState.connected);
  }

  void _onDisconnected() {
    _log.info('MQTT disconnected');
    _setState(MqttConnectionState.disconnected);
  }

  void _onAutoReconnect() {
    _log.info('MQTT auto-reconnecting');
    _setState(MqttConnectionState.connecting);
  }

  void _onAutoReconnected() {
    _log.info('MQTT auto-reconnected');
    _setState(MqttConnectionState.connected);
  }

  void _onSubscribed(String topic) {
    _log.debug('Subscribed: $topic');
  }

  void _onUnsubscribed(String? topic) {
    _log.debug('Unsubscribed: $topic');
  }

  void _setState(MqttConnectionState state) {
    if (_state != state) {
      _state = state;
      _stateController.add(state);
    }
  }

  MqttQos _mapQos(MqttQos qos) {
    return switch (qos) {
      MqttQos.atMostOnce => MqttQos.atMostOnce,
      MqttQos.atLeastOnce => MqttQos.atLeastOnce,
      MqttQos.exactlyOnce => MqttQos.exactlyOnce,
    };
  }

  MqttQos _reverseMapQos(MqttQos qos) {
    return switch (qos) {
      MqttQos.atMostOnce => MqttQos.atMostOnce,
      MqttQos.atLeastOnce => MqttQos.atLeastOnce,
      MqttQos.exactlyOnce => MqttQos.exactlyOnce,
      _ => MqttQos.atMostOnce,
    };
  }

  /// Disposes the client.
  void dispose() {
    disconnect();
    _messageController.close();
    _stateController.close();
  }
}
