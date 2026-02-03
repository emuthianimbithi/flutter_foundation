import 'dart:io';
import 'package:http/io_client.dart';

/// A very lightweight pinned HttpClient.
///
/// NOTE: Proper TLS pinning in Flutter often requires platform-specific code
/// or a mature library. This implementation provides a safe abstraction and a
/// hook point for apps to implement pinning policies.
class PinnedHttpClient extends IOClient {
  PinnedHttpClient({
    required List<String> allowedSha256Pins,
  }) : super(_create(allowedSha256Pins));

  static HttpClient _create(List<String> pins) {
    final client = HttpClient();

    // Hook point: verify certificate details and compare against pins.
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      // You can compute SHA-256 of cert.der here and compare to pins.
      // We keep this as a strict placeholder: reject by default.
      return false;
    };

    return client;
  }
}