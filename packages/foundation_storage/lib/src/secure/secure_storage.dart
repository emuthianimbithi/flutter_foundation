import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:foundation_core/foundation_core.dart';

import 'secure_storage_keys.dart';

/// Secure storage for sensitive data like tokens and secrets.
///
/// Uses platform-specific secure storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences / Keystore
///
/// Example:
/// ```dart
/// final storage = SecureStorage();
///
/// // Store token
/// await storage.setAccessToken('eyJhbG...');
///
/// // Retrieve token
/// final token = await storage.getAccessToken();
///
/// // Clear all auth data
/// await storage.clearAuthData();
/// ```
class SecureStorage {
  final FlutterSecureStorage _storage;
  final AppLogger _log = AppLogger('SecureStorage');

  /// Creates a secure storage instance.
  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
                sharedPreferencesName: 'foundation_secure_prefs',
                preferencesKeyPrefix: 'foundation_',
              ),
              iOptions: IOSOptions(
                groupId: null,
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  // ─────────────────────────────────────────────────────────────
  // GENERIC OPERATIONS
  // ─────────────────────────────────────────────────────────────

  /// Writes a string value.
  Future<Result<Unit>> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
      _log.debug('Written key: $key');
      return Result.success(unit);
    } catch (e, s) {
      _log.error('Failed to write key: $key', e, s);
      return Result.failure(Failure.storage('Failed to write to secure storage',
          originalException: e));
    }
  }

  /// Reads a string value.
  Future<Result<String?>> read(String key) async {
    try {
      final value = await _storage.read(key: key);
      return Result.success(value);
    } catch (e, s) {
      _log.error('Failed to read key: $key', e, s);
      return Result.failure(Failure.storage(
          'Failed to read from secure storage',
          originalException: e));
    }
  }

  /// Deletes a value.
  Future<Result<Unit>> delete(String key) async {
    try {
      await _storage.delete(key: key);
      _log.debug('Deleted key: $key');
      return Result.success(unit);
    } catch (e, s) {
      _log.error('Failed to delete key: $key', e, s);
      return Result.failure(Failure.storage(
          'Failed to delete from secure storage',
          originalException: e));
    }
  }

  /// Checks if a key exists.
  Future<Result<bool>> containsKey(String key) async {
    try {
      final exists = await _storage.containsKey(key: key);
      return Result.success(exists);
    } catch (e, s) {
      _log.error('Failed to check key: $key', e, s);
      return Result.failure(Failure.storage('Failed to check secure storage',
          originalException: e));
    }
  }

  /// Reads all keys.
  Future<Result<Map<String, String>>> readAll() async {
    try {
      final all = await _storage.readAll();
      return Result.success(all);
    } catch (e, s) {
      _log.error('Failed to read all', e, s);
      return Result.failure(Failure.storage(
          'Failed to read all from secure storage',
          originalException: e));
    }
  }

  /// Deletes all values.
  Future<Result<Unit>> deleteAll() async {
    try {
      await _storage.deleteAll();
      _log.debug('Deleted all keys');
      return Result.success(unit);
    } catch (e, s) {
      _log.error('Failed to delete all', e, s);
      return Result.failure(Failure.storage('Failed to clear secure storage',
          originalException: e));
    }
  }

  // ─────────────────────────────────────────────────────────────
  // JSON OPERATIONS
  // ─────────────────────────────────────────────────────────────

  /// Writes a JSON object.
  Future<Result<Unit>> writeJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      return write(key, jsonString);
    } catch (e, s) {
      _log.error('Failed to encode JSON for key: $key', e, s);
      return Result.failure(
          Failure.storage('Failed to encode JSON', originalException: e));
    }
  }

  /// Reads a JSON object.
  Future<Result<Map<String, dynamic>?>> readJson(String key) async {
    final result = await read(key);
    return result.fold(
      Result.failure,
      (value) {
        if (value == null) return Result.success(null);
        try {
          final json = jsonDecode(value) as Map<String, dynamic>;
          return Result.success(json);
        } catch (e, s) {
          _log.error('Failed to decode JSON for key: $key', e, s);
          return Result.failure(
              Failure.storage('Failed to decode JSON', originalException: e));
        }
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // AUTH TOKEN OPERATIONS
  // ─────────────────────────────────────────────────────────────

  /// Sets the access token.
  Future<Result<Unit>> setAccessToken(String token) =>
      write(SecureStorageKeys.accessToken, token);

  /// Gets the access token.
  Future<String?> getAccessToken() async {
    final result = await read(SecureStorageKeys.accessToken);
    return result.valueOrNull;
  }

  /// Sets the refresh token.
  Future<Result<Unit>> setRefreshToken(String token) =>
      write(SecureStorageKeys.refreshToken, token);

  /// Gets the refresh token.
  Future<String?> getRefreshToken() async {
    final result = await read(SecureStorageKeys.refreshToken);
    return result.valueOrNull;
  }

  /// Sets token expiry times.
  Future<Result<Unit>> setTokenExpiry({
    DateTime? accessExpiry,
    DateTime? refreshExpiry,
  }) async {
    if (accessExpiry != null) {
      await write(
          SecureStorageKeys.accessTokenExpiry, accessExpiry.toIso8601String());
    }
    if (refreshExpiry != null) {
      await write(SecureStorageKeys.refreshTokenExpiry,
          refreshExpiry.toIso8601String());
    }
    return Result.success(unit);
  }

  /// Gets the access token expiry.
  Future<DateTime?> getAccessTokenExpiry() async {
    final result = await read(SecureStorageKeys.accessTokenExpiry);
    final value = result.valueOrNull;
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  /// Gets the refresh token expiry.
  Future<DateTime?> getRefreshTokenExpiry() async {
    final result = await read(SecureStorageKeys.refreshTokenExpiry);
    final value = result.valueOrNull;
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  /// Checks if the access token is expired.
  Future<bool> isAccessTokenExpired() async {
    final expiry = await getAccessTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  /// Checks if the refresh token is expired.
  Future<bool> isRefreshTokenExpired() async {
    final expiry = await getRefreshTokenExpiry();
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  /// Stores all auth tokens at once.
  Future<Result<Unit>> setAuthTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? accessExpiry,
    DateTime? refreshExpiry,
  }) async {
    await setAccessToken(accessToken);
    await setRefreshToken(refreshToken);
    if (accessExpiry != null || refreshExpiry != null) {
      await setTokenExpiry(
          accessExpiry: accessExpiry, refreshExpiry: refreshExpiry);
    }
    return Result.success(unit);
  }

  /// Clears all auth-related data.
  Future<Result<Unit>> clearAuthData() async {
    await delete(SecureStorageKeys.accessToken);
    await delete(SecureStorageKeys.refreshToken);
    await delete(SecureStorageKeys.accessTokenExpiry);
    await delete(SecureStorageKeys.refreshTokenExpiry);
    await delete(SecureStorageKeys.userId);
    await delete(SecureStorageKeys.organizationId);
    await delete(SecureStorageKeys.sessionId);
    _log.info('Cleared all auth data');
    return Result.success(unit);
  }

  // ─────────────────────────────────────────────────────────────
  // USER/ORG OPERATIONS
  // ─────────────────────────────────────────────────────────────

  /// Sets the current user ID.
  Future<Result<Unit>> setUserId(String userId) =>
      write(SecureStorageKeys.userId, userId);

  /// Gets the current user ID.
  Future<String?> getUserId() async {
    final result = await read(SecureStorageKeys.userId);
    return result.valueOrNull;
  }

  /// Sets the current organization ID.
  Future<Result<Unit>> setOrganizationId(String orgId) =>
      write(SecureStorageKeys.organizationId, orgId);

  /// Gets the current organization ID.
  Future<String?> getOrganizationId() async {
    final result = await read(SecureStorageKeys.organizationId);
    return result.valueOrNull;
  }

  /// Sets the current session ID.
  Future<Result<Unit>> setSessionId(String sessionId) =>
      write(SecureStorageKeys.sessionId, sessionId);

  /// Gets the current session ID.
  Future<String?> getSessionId() async {
    final result = await read(SecureStorageKeys.sessionId);
    return result.valueOrNull;
  }

  // ─────────────────────────────────────────────────────────────
  // BIOMETRIC
  // ─────────────────────────────────────────────────────────────

  /// Sets the biometric secret (for biometric auth).
  Future<Result<Unit>> setBiometricSecret(String secret) =>
      write(SecureStorageKeys.biometricSecret, secret);

  /// Gets the biometric secret.
  Future<String?> getBiometricSecret() async {
    final result = await read(SecureStorageKeys.biometricSecret);
    return result.valueOrNull;
  }

  /// Clears the biometric secret.
  Future<Result<Unit>> clearBiometricSecret() =>
      delete(SecureStorageKeys.biometricSecret);
}
