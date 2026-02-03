import 'package:flutter/services.dart';

class ScreenshotProtection {
  static const _channel = MethodChannel('foundation_security/screenshot');

  static Future<void> enable() async {
    await _channel.invokeMethod('enable');
  }

  static Future<void> disable() async {
    await _channel.invokeMethod('disable');
  }
}
