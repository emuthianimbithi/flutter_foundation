import 'dart:math' as math;

/// Extension methods for [Iterable].
extension IterableExtensions<T> on Iterable<T> {
  /// Returns the first element or null if empty.
  T? get firstOrNull => isEmpty ? null : first;

  /// Returns the last element or null if empty.
  T? get lastOrNull => isEmpty ? null : last;

  /// Returns the single element or null if empty or has multiple elements.
  T? get singleOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    final result = iterator.current;
    if (iterator.moveNext()) return null;
    return result;
  }

  /// Returns the first element matching [predicate] or null.
  T? firstWhereOrNull(bool Function(T element) predicate) {
    for (final element in this) {
      if (predicate(element)) return element;
    }
    return null;
  }

  /// Returns the last element matching [predicate] or null.
  T? lastWhereOrNull(bool Function(T element) predicate) {
    T? result;
    for (final element in this) {
      if (predicate(element)) result = element;
    }
    return result;
  }

  /// Returns the element at [index] or null if out of bounds.
  T? elementAtOrNull(int index) {
    if (index < 0) return null;
    var i = 0;
    for (final element in this) {
      if (i == index) return element;
      i++;
    }
    return null;
  }

  /// Returns a random element or null if empty.
  T? get randomOrNull {
    if (isEmpty) return null;
    return elementAt(math.Random().nextInt(length));
  }

  /// Returns whether none of the elements match [predicate].
  bool none(bool Function(T element) predicate) => !any(predicate);

  /// Returns whether all elements are equal.
  bool get allEqual {
    if (isEmpty) return true;
    final first = this.first;
    return every((element) => element == first);
  }

  /// Returns this iterable with duplicates removed.
  Iterable<T> get distinct => toSet();

  /// Returns this iterable with duplicates removed based on [selector].
  Iterable<T> distinctBy<K>(K Function(T element) selector) {
    final seen = <K>{};
    return where((element) => seen.add(selector(element)));
  }

  /// Groups elements by a key.
  Map<K, List<T>> groupBy<K>(K Function(T element) keySelector) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keySelector(element);
      (map[key] ??= []).add(element);
    }
    return map;
  }

  /// Counts elements matching [predicate].
  int count([bool Function(T element)? predicate]) {
    if (predicate == null) return length;
    var count = 0;
    for (final element in this) {
      if (predicate(element)) count++;
    }
    return count;
  }

  /// Returns the sum of elements mapped by [selector].
  num sumBy(num Function(T element) selector) {
    num sum = 0;
    for (final element in this) {
      sum += selector(element);
    }
    return sum;
  }

  /// Returns the average of elements mapped by [selector].
  double averageBy(num Function(T element) selector) {
    if (isEmpty) return 0;
    return sumBy(selector) / length;
  }

  /// Returns the minimum element or null if empty.
  T? minOrNull([Comparator<T>? compare]) {
    if (isEmpty) return null;
    final comparator = compare ?? _defaultCompare;
    return reduce((a, b) => comparator(a, b) < 0 ? a : b);
  }

  /// Returns the maximum element or null if empty.
  T? maxOrNull([Comparator<T>? compare]) {
    if (isEmpty) return null;
    final comparator = compare ?? _defaultCompare;
    return reduce((a, b) => comparator(a, b) > 0 ? a : b);
  }

  /// Returns the minimum element by [selector] or null if empty.
  T? minByOrNull<K extends Comparable>(K Function(T element) selector) {
    if (isEmpty) return null;
    return reduce((a, b) => selector(a).compareTo(selector(b)) < 0 ? a : b);
  }

  /// Returns the maximum element by [selector] or null if empty.
  T? maxByOrNull<K extends Comparable>(K Function(T element) selector) {
    if (isEmpty) return null;
    return reduce((a, b) => selector(a).compareTo(selector(b)) > 0 ? a : b);
  }

  int _defaultCompare(T a, T b) {
    if (a is Comparable) return a.compareTo(b);
    throw ArgumentError('Elements must be Comparable or provide a comparator');
  }

  /// Separates elements with [separator].
  Iterable<T> separatedBy(T separator) sync* {
    var first = true;
    for (final element in this) {
      if (!first) yield separator;
      first = false;
      yield element;
    }
  }

  /// Chunks the iterable into lists of size [chunkSize].
  Iterable<List<T>> chunked(int chunkSize) sync* {
    assert(chunkSize > 0, 'chunkSize must be positive');
    final iterator = this.iterator;
    while (iterator.moveNext()) {
      final chunk = <T>[iterator.current];
      for (var i = 1; i < chunkSize && iterator.moveNext(); i++) {
        chunk.add(iterator.current);
      }
      yield chunk;
    }
  }

  /// Returns pairs of adjacent elements.
  Iterable<(T, T)> get windowed sync* {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return;
    var previous = iterator.current;
    while (iterator.moveNext()) {
      yield (previous, iterator.current);
      previous = iterator.current;
    }
  }

  /// Zips this iterable with [other].
  Iterable<(T, U)> zip<U>(Iterable<U> other) sync* {
    final iter1 = iterator;
    final iter2 = other.iterator;
    while (iter1.moveNext() && iter2.moveNext()) {
      yield (iter1.current, iter2.current);
    }
  }

  /// Flattens a nested iterable one level.
  Iterable<E> flatten<E>() sync* {
    for (final element in this) {
      if (element is Iterable<E>) {
        yield* element;
      } else {
        yield element as E;
      }
    }
  }

  /// Maps and flattens in one operation.
  Iterable<R> flatMap<R>(Iterable<R> Function(T element) transform) sync* {
    for (final element in this) {
      yield* transform(element);
    }
  }

  /// Sorts this iterable by [selector] in ascending order.
  List<T> sortedBy<K extends Comparable>(K Function(T element) selector) {
    final list = toList();
    list.sort((a, b) => selector(a).compareTo(selector(b)));
    return list;
  }

  /// Sorts this iterable by [selector] in descending order.
  List<T> sortedByDescending<K extends Comparable>(
    K Function(T element) selector,
  ) {
    final list = toList();
    list.sort((a, b) => selector(b).compareTo(selector(a)));
    return list;
  }

  /// Converts this iterable to an unmodifiable list.
  List<T> toUnmodifiableList() => List.unmodifiable(this);

  /// Converts this iterable to an unmodifiable set.
  Set<T> toUnmodifiableSet() => Set.unmodifiable(toSet());
}

/// Extension methods for [Iterable] of nullable elements.
extension IterableNullableExtensions<T> on Iterable<T?> {
  /// Returns this iterable with null values removed.
  Iterable<T> whereNotNull() => whereType<T>();
}

/// Extension methods for [Iterable] of [Comparable] elements.
extension IterableComparableExtensions<T extends Comparable<T>> on Iterable<T> {
  /// Returns the minimum element or null if empty.
  T? get minOrNull => isEmpty ? null : reduce((a, b) => a.compareTo(b) < 0 ? a : b);

  /// Returns the maximum element or null if empty.
  T? get maxOrNull => isEmpty ? null : reduce((a, b) => a.compareTo(b) > 0 ? a : b);

  /// Returns a sorted list in ascending order.
  List<T> sorted() => toList()..sort();

  /// Returns a sorted list in descending order.
  List<T> sortedDescending() => toList()..sort((a, b) => b.compareTo(a));
}

/// Extension methods for [Iterable] of [num].
extension IterableNumExtensions on Iterable<num> {
  /// Returns the sum of all elements.
  num get sum => fold<num>(0, (a, b) => a + b);

  /// Returns the average of all elements.
  double get average => isEmpty ? 0 : sum / length;

  /// Returns the minimum element or null if empty.
  num? get minOrNull => isEmpty ? null : reduce((a, b) => a < b ? a : b);

  /// Returns the maximum element or null if empty.
  num? get maxOrNull => isEmpty ? null : reduce((a, b) => a > b ? a : b);
}
