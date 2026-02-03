import 'package:uuid/uuid.dart';

/// UUID generation utilities.
class UuidGenerator {
  UuidGenerator._();

  static const _uuid = Uuid();

  /// Generates a random UUID v4.
  static String v4() => _uuid.v4();

  /// Generates a UUID v1 (time-based).
  static String v1() => _uuid.v1();

  /// Generates a UUID v5 (namespace-based with SHA-1).
  static String v5(String namespace, String name) => _uuid.v5(namespace, name);

  /// Generates a short ID (first 8 characters of UUID v4).
  static String shortId() => _uuid.v4().substring(0, 8);

  /// Generates a compact ID (UUID v4 without hyphens).
  static String compactId() => _uuid.v4().replaceAll('-', '');

  /// Validates that a string is a valid UUID.
  static bool isValid(String uuid) {
    final regex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return regex.hasMatch(uuid);
  }

  /// Parses a UUID string, returning null if invalid.
  static String? parse(String uuid) {
    if (isValid(uuid)) return uuid.toLowerCase();
    // Try to parse compact format
    final compact = uuid.replaceAll('-', '').toLowerCase();
    if (compact.length == 32 && RegExp(r'^[0-9a-f]{32}$').hasMatch(compact)) {
      return '${compact.substring(0, 8)}-${compact.substring(8, 12)}-${compact.substring(12, 16)}-${compact.substring(16, 20)}-${compact.substring(20)}';
    }
    return null;
  }

  /// Common namespaces for v5 UUIDs.
  static const namespaceUrl = '6ba7b811-9dad-11d1-80b4-00c04fd430c8';
  static const namespaceDns = '6ba7b810-9dad-11d1-80b4-00c04fd430c8';
  static const namespaceOid = '6ba7b812-9dad-11d1-80b4-00c04fd430c8';
  static const namespaceX500 = '6ba7b814-9dad-11d1-80b4-00c04fd430c8';
}
