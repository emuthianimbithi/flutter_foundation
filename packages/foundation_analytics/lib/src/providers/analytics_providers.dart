import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics/analytics_client.dart';
import '../analytics/analytics_service.dart';
import '../crash/crash_reporter.dart';
import '../crash/crash_service.dart';
import '../logging/logger.dart';
import '../logging/log_sink.dart';

/// Override these in the app to plug in Firebase, Sentry, Segment, etc.
final analyticsClientProvider = Provider<AnalyticsClient>((ref) => const NoopAnalyticsClient());

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService(ref.watch(analyticsClientProvider));
});

final crashReporterProvider = Provider<CrashReporter>((ref) => const NoopCrashReporter());

final crashServiceProvider = Provider<CrashService>((ref) {
  return CrashService(ref.watch(crashReporterProvider));
});

final loggerProvider = Provider<Logger>((ref) {
  // App can override with additional sinks (file, remote, etc.)
  return Logger(sinks: const [ConsoleLogSink()]);
});