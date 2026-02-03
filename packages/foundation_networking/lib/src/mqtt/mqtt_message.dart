import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// MQTT Quality of Service levels.
enum MqttQos {
  /// At most once (fire and forget).
  atMostOnce,

  /// At least once (acknowledged delivery).
  atLeastOnce,

  /// Exactly once (assured delivery).
  exactlyOnce,
}

/// Represents an MQTT message.
class MqttMessage extends Equatable {
  /// The topic.
  final String topic;

  /// The payload as bytes.
  final Uint8List payload;

  /// The QoS level.
  final MqttQos qos;

  /// Whether the message should be retained.
  final bool retain;

  /// When the message was received/sent.
  final DateTime timestamp;

  const MqttMessage({
    required this.topic,
    required this.payload,
    this.qos = MqttQos.atMostOnce,
    this.retain = false,
    required this.timestamp,
  });

  /// Creates a message with string payload.
  factory MqttMessage.string(
    String topic,
    String message, {
    MqttQos qos = MqttQos.atMostOnce,
    bool retain = false,
  }) =>
      MqttMessage(
        topic: topic,
        payload: Uint8List.fromList(utf8.encode(message)),
        qos: qos,
        retain: retain,
        timestamp: DateTime.now(),
      );

  /// Creates a message with JSON payload.
  factory MqttMessage.json(
    String topic,
    Map<String, dynamic> json, {
    MqttQos qos = MqttQos.atMostOnce,
    bool retain = false,
  }) =>
      MqttMessage.string(
        topic,
        jsonEncode(json),
        qos: qos,
        retain: retain,
      );

  /// Creates a message with binary payload.
  factory MqttMessage.binary(
    String topic,
    List<int> bytes, {
    MqttQos qos = MqttQos.atMostOnce,
    bool retain = false,
  }) =>
      MqttMessage(
        topic: topic,
        payload: Uint8List.fromList(bytes),
        qos: qos,
        retain: retain,
        timestamp: DateTime.now(),
      );

  /// Gets the payload as a string.
  String get asString => utf8.decode(payload);

  /// Gets the payload as JSON.
  Map<String, dynamic>? get asJson {
    try {
      return jsonDecode(asString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Gets the payload size in bytes.
  int get size => payload.length;

  @override
  List<Object?> get props => [topic, payload, qos, retain, timestamp];

  @override
  String toString() =>
      'MqttMessage(topic: $topic, size: $size, qos: ${qos.name})';
}

/// MQTT subscription.
class MqttSubscription extends Equatable {
  /// The topic filter.
  final String topic;

  /// The QoS level.
  final MqttQos qos;

  const MqttSubscription({
    required this.topic,
    this.qos = MqttQos.atMostOnce,
  });

  @override
  List<Object?> get props => [topic, qos];
}
