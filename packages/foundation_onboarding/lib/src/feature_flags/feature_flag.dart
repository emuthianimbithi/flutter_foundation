class FeatureFlag {
  final String key;
  final String name;
  final String description;
  final bool enabledByDefault;

  const FeatureFlag({
    required this.key,
    required this.name,
    required this.description,
    this.enabledByDefault = false,
  });
}
