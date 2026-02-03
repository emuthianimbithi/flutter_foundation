import 'package:foundation_storage/foundation_storage.dart';
import 'package:meta/meta.dart';

/// Keys used for token persistence.
class AuthStorageKeys {
  static const accessToken = 'auth.access_token';
  static const refreshToken = 'auth.refresh_token';
  static const accessExpiryIso = 'auth.access_expiry_iso';
  static const refreshExpiryIso = 'auth.refresh_expiry_iso';
  static const orgSlug = 'auth.org_slug';
  static const userId = 'auth.user_id';
  static const role = 'auth.role';
}

/// Stores and retrieves auth tokens and session metadata.
@immutable
class TokenManager {
  final SecureStorage secureStorage;
  final PreferencesStorage prefs;

  const TokenManager({
    required this.secureStorage,
    required this.prefs,
  });

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime accessExpiry,
    required DateTime refreshExpiry,
    String? orgSlug,
    String? userId,
    String? role,
  }) async {
    await secureStorage.write(AuthStorageKeys.accessToken, accessToken);
    await secureStorage.write(AuthStorageKeys.refreshToken, refreshToken);
    await prefs.setString(
        AuthStorageKeys.accessExpiryIso, accessExpiry.toIso8601String());
    await prefs.setString(
        AuthStorageKeys.refreshExpiryIso, refreshExpiry.toIso8601String());
    if (orgSlug != null)
      await prefs.setString(AuthStorageKeys.orgSlug, orgSlug);
    if (userId != null) await prefs.setString(AuthStorageKeys.userId, userId);
    if (role != null) await prefs.setString(AuthStorageKeys.role, role);
  }

  Future<String?> getAccessToken() async {
    final res = await secureStorage.read(AuthStorageKeys.accessToken);
    return res.valueOrNull;
  }

  Future<String?> getRefreshToken() async {
    final res = await secureStorage.read(AuthStorageKeys.refreshToken);
    return res.valueOrNull;
  }

  DateTime? _readIso(String? v) => v == null ? null : DateTime.tryParse(v);

  Future<DateTime?> getAccessExpiry() async =>
      _readIso(prefs.getString(AuthStorageKeys.accessExpiryIso));

  Future<DateTime?> getRefreshExpiry() async =>
      _readIso(prefs.getString(AuthStorageKeys.refreshExpiryIso));

  Future<String?> getOrgSlug() async =>
      prefs.getString(AuthStorageKeys.orgSlug);
  Future<String?> getUserId() async => prefs.getString(AuthStorageKeys.userId);
  Future<String?> getRole() async => prefs.getString(AuthStorageKeys.role);

  Future<void> clear() async {
    await secureStorage.delete(AuthStorageKeys.accessToken);
    await secureStorage.delete(AuthStorageKeys.refreshToken);
    await prefs.remove(AuthStorageKeys.accessExpiryIso);
    await prefs.remove(AuthStorageKeys.refreshExpiryIso);
    await prefs.remove(AuthStorageKeys.orgSlug);
    await prefs.remove(AuthStorageKeys.userId);
    await prefs.remove(AuthStorageKeys.role);
  }

  Future<bool> hasValidAccessToken(
      {Duration leeway = const Duration(seconds: 30)}) async {
    final token = await getAccessToken();
    final exp = await getAccessExpiry();
    if (token == null || exp == null) return false;
    return exp.isAfter(DateTime.now().add(leeway));
  }

  Future<bool> hasValidRefreshToken({Duration leeway = Duration.zero}) async {
    final token = await getRefreshToken();
    final exp = await getRefreshExpiry();
    if (token == null || exp == null) return false;
    return exp.isAfter(DateTime.now().add(leeway));
  }

  /// Convenience snapshot for restore flows.
  Future<TokenSnapshot> loadSnapshot() async {
    return TokenSnapshot(
      accessToken: await getAccessToken(),
      refreshToken: await getRefreshToken(),
      accessExpiry: await getAccessExpiry(),
      refreshExpiry: await getRefreshExpiry(),
      orgSlug: await getOrgSlug(),
      userId: await getUserId(),
      role: await getRole(),
    );
  }
}

class TokenSnapshot {
  final String? accessToken;
  final String? refreshToken;
  final DateTime? accessExpiry;
  final DateTime? refreshExpiry;
  final String? orgSlug;
  final String? userId;
  final String? role;

  const TokenSnapshot({
    required this.accessToken,
    required this.refreshToken,
    required this.accessExpiry,
    required this.refreshExpiry,
    required this.orgSlug,
    required this.userId,
    required this.role,
  });
}
