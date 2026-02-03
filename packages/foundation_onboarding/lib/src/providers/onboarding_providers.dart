import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../feature_flags/feature_flag.dart';

final hasCompletedOnboardingProvider = StateProvider<bool>((ref) => false);

/// Provide your flags list from app; override this provider.
final featureFlagsCatalogProvider =
    Provider<List<FeatureFlag>>((ref) => const []);

/// Key -> enabled
final featureFlagsStateProvider = StateProvider<Map<String, bool>>((ref) {
  final catalog = ref.watch(featureFlagsCatalogProvider);
  return {for (final f in catalog) f.key: f.enabledByDefault};
});
