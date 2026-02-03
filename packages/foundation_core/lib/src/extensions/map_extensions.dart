/// Extension methods for [Map].
extension MapExtensions<K, V> on Map<K, V> {
  /// Returns the value for [key] or null if not present.
  V? getOrNull(K key) => this[key];

  /// Returns the value for [key] or [defaultValue] if not present.
  V getOrDefault(K key, V defaultValue) => this[key] ?? defaultValue;

  /// Returns the value for [key] or computes it using [ifAbsent].
  V getOrPut(K key, V Function() ifAbsent) {
    if (containsKey(key)) return this[key] as V;
    final value = ifAbsent();
    this[key] = value;
    return value;
  }

  /// Maps values using [transform] while keeping the keys.
  Map<K, V2> mapValues<V2>(V2 Function(V value) transform) =>
      map((key, value) => MapEntry(key, transform(value)));

  /// Maps keys using [transform] while keeping the values.
  Map<K2, V> mapKeys<K2>(K2 Function(K key) transform) =>
      map((key, value) => MapEntry(transform(key), value));

  /// Maps entries using [transform].
  Map<K2, V2> mapEntries<K2, V2>(
    MapEntry<K2, V2> Function(K key, V value) transform,
  ) =>
      map(transform);

  /// Filters entries matching [predicate].
  Map<K, V> where(bool Function(K key, V value) predicate) {
    final result = <K, V>{};
    forEach((key, value) {
      if (predicate(key, value)) result[key] = value;
    });
    return result;
  }

  /// Filters entries not matching [predicate].
  Map<K, V> whereNot(bool Function(K key, V value) predicate) =>
      where((key, value) => !predicate(key, value));

  /// Returns whether any entry matches [predicate].
  bool any(bool Function(K key, V value) predicate) {
    for (final entry in entries) {
      if (predicate(entry.key, entry.value)) return true;
    }
    return false;
  }

  /// Returns whether all entries match [predicate].
  bool all(bool Function(K key, V value) predicate) {
    for (final entry in entries) {
      if (!predicate(entry.key, entry.value)) return false;
    }
    return true;
  }

  /// Returns whether no entry matches [predicate].
  bool none(bool Function(K key, V value) predicate) => !any(predicate);

  /// Merges this map with [other], with [other]'s values taking precedence.
  Map<K, V> mergedWith(Map<K, V> other) => {...this, ...other};

  /// Returns a new map with [key] removed.
  Map<K, V> without(K key) => Map.from(this)..remove(key);

  /// Returns a new map with [keys] removed.
  Map<K, V> withoutAll(Iterable<K> keys) {
    final keysSet = keys.toSet();
    return where((key, _) => !keysSet.contains(key));
  }

  /// Returns a new map with only [keys].
  Map<K, V> withOnly(Iterable<K> keys) {
    final keysSet = keys.toSet();
    return where((key, _) => keysSet.contains(key));
  }

  /// Returns whether this map contains all [keys].
  bool containsAllKeys(Iterable<K> keys) => keys.every(containsKey);

  /// Returns whether this map contains any of [keys].
  bool containsAnyKey(Iterable<K> keys) => keys.any(containsKey);

  /// Returns the first entry matching [predicate] or null.
  MapEntry<K, V>? firstWhereOrNull(bool Function(K key, V value) predicate) {
    for (final entry in entries) {
      if (predicate(entry.key, entry.value)) return entry;
    }
    return null;
  }

  /// Converts to an unmodifiable map.
  Map<K, V> toUnmodifiable() => Map.unmodifiable(this);

  /// Deep gets a value from a nested map using dot notation.
  /// Example: map.deepGet('a.b.c') returns map['a']['b']['c'].
  dynamic deepGet(String path) {
    final keys = path.split('.');
    dynamic current = this;
    for (final key in keys) {
      if (current is! Map) return null;
      current = current[key];
      if (current == null) return null;
    }
    return current;
  }

  /// Deep sets a value in a nested map using dot notation.
  void deepSet(String path, dynamic value) {
    final keys = path.split('.');
    dynamic current = this;
    for (var i = 0; i < keys.length - 1; i++) {
      final key = keys[i];
      if (current is! Map) return;
      if (!current.containsKey(key) || current[key] is! Map) {
        current[key] = <String, dynamic>{};
      }
      current = current[key];
    }
    if (current is Map) {
      current[keys.last] = value;
    }
  }
}

/// Extension methods for nullable [Map].
extension NullableMapExtensions<K, V> on Map<K, V>? {
  /// Returns this map or an empty map if null.
  Map<K, V> get orEmpty => this ?? {};

  /// Returns whether this map is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns whether this map is not null and not empty.
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;
}

/// Extension methods for [Map] with String keys (JSON-like maps).
extension JsonMapExtensions on Map<String, dynamic> {
  /// Gets a string value or null.
  String? getString(String key) {
    final value = this[key];
    return value is String ? value : null;
  }

  /// Gets an int value or null.
  int? getInt(String key) {
    final value = this[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Gets a double value or null.
  double? getDouble(String key) {
    final value = this[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Gets a bool value or null.
  bool? getBool(String key) {
    final value = this[key];
    if (value is bool) return value;
    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }
    if (value is num) return value != 0;
    return null;
  }

  /// Gets a DateTime value or null (from ISO string or timestamp).
  DateTime? getDateTime(String key) {
    final value = this[key];
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    return null;
  }

  /// Gets a list value or null.
  List<T>? getList<T>(String key) {
    final value = this[key];
    if (value is List) return value.cast<T>();
    return null;
  }

  /// Gets a map value or null.
  Map<String, dynamic>? getMap(String key) {
    final value = this[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  /// Removes null values from this map.
  Map<String, dynamic> withoutNulls() =>
      Map.fromEntries(entries.where((e) => e.value != null));

  /// Removes null and empty values from this map.
  Map<String, dynamic> compact() => Map.fromEntries(
        entries.where((e) {
          final value = e.value;
          if (value == null) return false;
          if (value is String && value.isEmpty) return false;
          if (value is List && value.isEmpty) return false;
          if (value is Map && value.isEmpty) return false;
          return true;
        }),
      );
}
