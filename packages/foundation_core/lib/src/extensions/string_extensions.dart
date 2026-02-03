/// Extension methods for [String].
extension StringExtensions on String {
  /// Whether this string is null or empty.
  bool get isNullOrEmpty => isEmpty;

  /// Whether this string is not null and not empty.
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Whether this string is null, empty, or contains only whitespace.
  bool get isNullOrBlank => trim().isEmpty;

  /// Whether this string is not null, not empty, and contains non-whitespace.
  bool get isNotNullOrBlank => trim().isNotEmpty;

  /// Returns this string or null if empty.
  String? get orNull => isEmpty ? null : this;

  /// Returns this string or null if blank.
  String? get orNullIfBlank => isNullOrBlank ? null : this;

  /// Capitalizes the first letter of this string.
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of each word.
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalized).join(' ');
  }

  /// Converts to camelCase.
  String get camelCase {
    if (isEmpty) return this;
    final words = _splitIntoWords();
    if (words.isEmpty) return this;
    return words.first.toLowerCase() +
        words.skip(1).map((w) => w.capitalized).join();
  }

  /// Converts to PascalCase.
  String get pascalCase {
    if (isEmpty) return this;
    return _splitIntoWords().map((w) => w.capitalized).join();
  }

  /// Converts to snake_case.
  String get snakeCase {
    if (isEmpty) return this;
    return _splitIntoWords().map((w) => w.toLowerCase()).join('_');
  }

  /// Converts to kebab-case.
  String get kebabCase {
    if (isEmpty) return this;
    return _splitIntoWords().map((w) => w.toLowerCase()).join('-');
  }

  /// Converts to CONSTANT_CASE.
  String get constantCase {
    if (isEmpty) return this;
    return _splitIntoWords().map((w) => w.toUpperCase()).join('_');
  }

  List<String> _splitIntoWords() {
    return replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m[1]} ${m[2]}',
    )
        .replaceAll(RegExp(r'[_\-]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  /// Truncates this string to [maxLength], adding [ellipsis] if truncated.
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Removes all whitespace from this string.
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Removes leading and trailing whitespace and collapses internal whitespace.
  String get normalizeWhitespace => trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Reverses this string.
  String get reversed => split('').reversed.join();

  /// Returns the initials of words in this string.
  String get initials {
    final words = trim().split(RegExp(r'\s+'));
    return words.map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
  }

  /// Masks this string, showing only [visibleChars] characters at the end.
  String mask({int visibleChars = 4, String maskChar = '*'}) {
    if (length <= visibleChars) return maskChar * length;
    return maskChar * (length - visibleChars) + substring(length - visibleChars);
  }

  /// Checks if this string contains only digits.
  bool get isNumeric => RegExp(r'^\d+$').hasMatch(this);

  /// Checks if this string contains only letters.
  bool get isAlpha => RegExp(r'^[a-zA-Z]+$').hasMatch(this);

  /// Checks if this string contains only letters and digits.
  bool get isAlphanumeric => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);

  /// Checks if this string is a valid email format.
  bool get isEmail => RegExp(
        r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$',
      ).hasMatch(this);

  /// Checks if this string is a valid URL.
  bool get isUrl {
    final uri = Uri.tryParse(this);
    return uri != null && uri.hasScheme && uri.hasAuthority;
  }

  /// Checks if this string is a valid UUID.
  bool get isUuid => RegExp(
        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
      ).hasMatch(this);

  /// Parses this string as an int, returning null if invalid.
  int? toIntOrNull() => int.tryParse(this);

  /// Parses this string as a double, returning null if invalid.
  double? toDoubleOrNull() => double.tryParse(this);

  /// Parses this string as a DateTime, returning null if invalid.
  DateTime? toDateTimeOrNull() => DateTime.tryParse(this);

  /// Parses this string as a bool.
  bool? toBoolOrNull() {
    final lower = toLowerCase();
    if (lower == 'true' || lower == '1' || lower == 'yes') return true;
    if (lower == 'false' || lower == '0' || lower == 'no') return false;
    return null;
  }

  /// Parses this string as a Uri, returning null if invalid.
  Uri? toUriOrNull() => Uri.tryParse(this);

  /// Returns the levenshtein distance to [other].
  int levenshteinDistance(String other) {
    if (this == other) return 0;
    if (isEmpty) return other.length;
    if (other.isEmpty) return length;

    final matrix = List.generate(
      length + 1,
      (i) => List.generate(other.length + 1, (j) => 0),
    );

    for (var i = 0; i <= length; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= other.length; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= length; i++) {
      for (var j = 1; j <= other.length; j++) {
        final cost = this[i - 1] == other[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[length][other.length];
  }

  /// Returns similarity to [other] as a percentage (0-1).
  double similarityTo(String other) {
    final maxLen = length > other.length ? length : other.length;
    if (maxLen == 0) return 1.0;
    return 1.0 - (levenshteinDistance(other) / maxLen);
  }
}

/// Extension methods for nullable [String].
extension NullableStringExtensions on String? {
  /// Whether this string is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Whether this string is not null and not empty.
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Whether this string is null, empty, or contains only whitespace.
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  /// Whether this string is not null, not empty, and contains non-whitespace.
  bool get isNotNullOrBlank => this != null && this!.trim().isNotEmpty;

  /// Returns this string or an empty string if null.
  String get orEmpty => this ?? '';

  /// Returns this string or [defaultValue] if null or empty.
  String orDefault(String defaultValue) =>
      isNullOrEmpty ? defaultValue : this!;
}
