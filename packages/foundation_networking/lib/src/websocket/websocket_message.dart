import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Types of WebSocket messages.
enum WebSocketMessageType {
  /// Text message.
  text,

  /// JSON message.
  json,

  /// Binary message.
  binary,

  /// Ping message.
  ping,

  /// Pong message.
  pong,

  /// Connection opened.
  connected,

  /// Connection closed.
  disconnected,

  /// Error occurred.
  error,
}

/// Represents a WebSocket message.
class WebSocketMessage extends Equatable {
  /// The message type.
  final WebSocketMessageType type;

  /// The raw data.
  final dynamic data;

  /// The topic/channel (if applicable).
  final String? topic;

  /// The event name (if applicable).
  final String? event;

  /// When the message was received/sent.
  final DateTime timestamp;

  /// Error message (for error type).
  final String? error;

  const WebSocketMessage({
    required this.type,
    this.data,
    this.topic,
    this.event,
    required this.timestamp,
    this.error,
  });

  /// Creates a text message.
  factory WebSocketMessage.text(String text, {String? topic, String? event}) =>
      WebSocketMessage(
        type: WebSocketMessageType.text,
        data: text,
        topic: topic,
        event: event,
        timestamp: DateTime.now(),
      );

  /// Creates a JSON message.
  factory WebSocketMessage.json(
    Map<String, dynamic> json, {
    String? topic,
    String? event,
  }) =>
      WebSocketMessage(
        type: WebSocketMessageType.json,
        data: json,
        topic: topic,
        event: event,
        timestamp: DateTime.now(),
      );

  /// Creates a binary message.
  factory WebSocketMessage.binary(List<int> bytes, {String? topic}) =>
      WebSocketMessage(
        type: WebSocketMessageType.binary,
        data: bytes,
        topic: topic,
        timestamp: DateTime.now(),
      );

  /// Creates a connected message.
  factory WebSocketMessage.connected() => WebSocketMessage(
        type: WebSocketMessageType.connected,
        timestamp: DateTime.now(),
      );

  /// Creates a disconnected message.
  factory WebSocketMessage.disconnected({String? reason}) => WebSocketMessage(
        type: WebSocketMessageType.disconnected,
        data: reason,
        timestamp: DateTime.now(),
      );

  /// Creates an error message.
  factory WebSocketMessage.error(String error) => WebSocketMessage(
        type: WebSocketMessageType.error,
        error: error,
        timestamp: DateTime.now(),
      );

  /// Parses a raw WebSocket message.
  factory WebSocketMessage.parse(dynamic rawData) {
    if (rawData is String) {
      // Try to parse as JSON
      try {
        final json = jsonDecode(rawData) as Map<String, dynamic>;
        return WebSocketMessage(
          type: WebSocketMessageType.json,
          data: json,
          topic: json['topic'] as String?,
          event: json['event'] as String?,
          timestamp: DateTime.now(),
        );
      } catch (_) {
        // Plain text
        return WebSocketMessage.text(rawData);
      }
    } else if (rawData is List<int>) {
      return WebSocketMessage.binary(rawData);
    }

    return WebSocketMessage(
      type: WebSocketMessageType.text,
      data: rawData?.toString(),
      timestamp: DateTime.now(),
    );
  }

  /// Gets data as a string.
  String? get asString {
    if (data is String) return data as String;
    if (data is Map) return jsonEncode(data);
    return data?.toString();
  }

  /// Gets data as JSON.
  Map<String, dynamic>? get asJson {
    if (data is Map<String, dynamic>) return data as Map<String, dynamic>;
    if (data is String) {
      try {
        return jsonDecode(data as String) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Gets data as bytes.
  List<int>? get asBytes {
    if (data is List<int>) return data as List<int>;
    if (data is String) return (data as String).codeUnits;
    return null;
  }

  /// Converts to wire format.
  dynamic toWireFormat() {
    if (type == WebSocketMessageType.json && data is Map) {
      return jsonEncode(data);
    }
    return data;
  }

  @override
  List<Object?> get props => [type, data, topic, event, timestamp, error];

  @override
  String toString() =>
      'WebSocketMessage($type${topic != null ? ', topic: $topic' : ''}${event != null ? ', event: $event' : ''})';
}
