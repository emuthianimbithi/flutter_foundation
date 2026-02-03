import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_analytics/foundation_analytics.dart';
import 'package:foundation_ui/foundation_ui.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = FoundationTheme.tokensOf(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Fire a demo analytics event and crash report.'),
            SizedBox(height: tokens.space12),
            FoundationButton(
              label: 'Log event',
              onPressed: () {
                ref.read(analyticsServiceProvider).track(AnalyticsEvent('demo_event', params: {'source': 'showcase'}));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event logged')));
              },
            ),
            SizedBox(height: tokens.space12),
            FoundationButton(
              label: 'Simulate non-fatal crash',
              variant: FoundationButtonVariant.secondary,
              onPressed: () {
                ref.read(crashServiceProvider).record('demo_error', StackTrace.current, reason: 'demo_non_fatal', fatal: false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Crash recorded')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
