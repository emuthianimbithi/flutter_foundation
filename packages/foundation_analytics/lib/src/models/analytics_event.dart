class AnalyticsEvent {
  final String name;
  final Map<String, Object?> params;

  const AnalyticsEvent(this.name, {this.params = const {}});

  @override
  String toString() => 'AnalyticsEvent(name: $name, params: $params)';
}
