import 'dart:io';
import 'package:http/io_client.dart';

class CertificatePinning {
  static IOClient createPinnedClient(List<String> allowedSha256) {
    final context = SecurityContext(withTrustedRoots: true);

    final httpClient = HttpClient(context: context);
    httpClient.badCertificateCallback = (cert, host, port) {
      final sha = cert.sha256;
      return allowedSha256.contains(sha);
    };

    return IOClient(httpClient);
  }
}
