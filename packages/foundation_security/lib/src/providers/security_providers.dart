import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cert_pinning/pinned_http_client.dart';
import '../root_detection/root_detection_service.dart';
import '../screenshot_prevention/screenshot_prevention_service.dart';

final rootDetectionServiceProvider = Provider<RootDetectionService>((ref) {
  return RootDetectionService();
});

final screenshotPreventionServiceProvider = Provider<ScreenshotPreventionService>((ref) {
  return ScreenshotPreventionService();
});

/// Override this in your app with actual pinning policy / certificate hashes.
final pinnedHttpClientProvider = Provider<PinnedHttpClient>((ref) {
  return PinnedHttpClient(allowedSha256Pins: const []);
});