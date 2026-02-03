import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_ui/foundation_ui.dart';
import '../providers/onboarding_providers.dart';

class FeatureFlagsPage extends ConsumerWidget {
  const FeatureFlagsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(featureFlagsCatalogProvider);
    final flags = ref.watch(featureFlagsStateProvider);
    final tokens = FoundationTheme.tokensOf(context);
    final t = FoundationTheme.typeOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Feature Flags')),
      body: ListView.separated(
        padding: EdgeInsets.all(tokens.space16),
        itemCount: catalog.length,
        separatorBuilder: (_, __) => SizedBox(height: tokens.space12),
        itemBuilder: (context, i) {
          final f = catalog[i];
          final enabled = flags[f.key] ?? f.enabledByDefault;

          return FoundationCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.name, style: t.bodyStrong),
                      SizedBox(height: tokens.space4),
                      Text(f.description, style: t.caption),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: (v) {
                    ref.read(featureFlagsStateProvider.notifier).state = {
                      ...flags,
                      f.key: v
                    };
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
