import 'package:flutter/services.dart';

/// Screenshot prevention abstraction.
///
/// For Android: FLAG_SECURE.
/// For iOS: UIView secure text field overlay tricks.
/// Implement via platform channels in your app if needed.
class ScreenshotPreventionService {
  static const MethodChannel _channel =
      MethodChannel('foundation_security/screenshot');

  Future<void> enable() async {
    try {
      await _channel.invokeMethod('enable');
    } catch (_) {
      // no-op if not implemented by platform layer
    }
  }

  Future<void> disable() async {
    try {
      await _channel.invokeMethod('disable');
    } catch (_) {
      // no-op if not implemented by platform layer
    }
  }
}
