import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'file/file_cache.dart';
import 'file/file_storage.dart';
import 'preferences/preferences_storage.dart';
import 'scoped/scoped_storage.dart';
import 'scoped/storage_scope.dart';
import 'secure/secure_storage.dart';

/// Provider for secure storage.
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

/// Provider for preferences storage.
final preferencesStorageProvider = Provider<PreferencesStorage>((ref) {
  return PreferencesStorage();
});

/// Provider for the app database.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// Provider for file storage.
final fileStorageProvider = Provider<FileStorage>((ref) {
  return FileStorage();
});

/// Provider for file cache.
final fileCacheProvider = Provider<FileCache>((ref) {
  final fileStorage = ref.watch(fileStorageProvider);
  return FileCache(fileStorage);
});

/// Provider for scoped storage.
final scopedStorageProvider = Provider<ScopedStorage>((ref) {
  return ScopedStorage(
    secureStorage: ref.watch(secureStorageProvider),
    preferences: ref.watch(preferencesStorageProvider),
    database: ref.watch(appDatabaseProvider),
  );
});

/// Provider for the current storage scope.
final storageScopeProvider = StateProvider<StorageScope?>((ref) {
  return null;
});

/// Provider for the current user ID from scope.
final currentUserIdProvider = Provider<String?>((ref) {
  return ref.watch(storageScopeProvider)?.userId;
});

/// Provider for the current organization ID from scope.
final currentOrganizationIdProvider = Provider<String?>((ref) {
  return ref.watch(storageScopeProvider)?.organizationId;
});

/// Provider for checking if there's an active scope.
final hasScopeProvider = Provider<bool>((ref) {
  return ref.watch(storageScopeProvider) != null;
});

/// Provider for checking if there's an organization in scope.
final hasOrganizationProvider = Provider<bool>((ref) {
  return ref.watch(storageScopeProvider)?.organizationId != null;
});

// ─────────────────────────────────────────────────────────────
// CONVENIENCE PROVIDERS
// ─────────────────────────────────────────────────────────────

/// Provider for getting the access token.
final accessTokenProvider = FutureProvider<String?>((ref) async {
  final secureStorage = ref.watch(secureStorageProvider);
  return secureStorage.getAccessToken();
});

/// Provider for checking if access token is expired.
final isAccessTokenExpiredProvider = FutureProvider<bool>((ref) async {
  final secureStorage = ref.watch(secureStorageProvider);
  return secureStorage.isAccessTokenExpired();
});

/// Provider for theme mode preference.
final themeModePreferenceProvider = Provider<String>((ref) {
  final prefs = ref.watch(preferencesStorageProvider);
  return prefs.getThemeMode();
});

/// Provider for locale preference.
final localePreferenceProvider = Provider<String?>((ref) {
  final prefs = ref.watch(preferencesStorageProvider);
  return prefs.getLocale();
});

/// Provider for checking if onboarding is complete.
final isOnboardingCompleteProvider = Provider<bool>((ref) {
  final prefs = ref.watch(preferencesStorageProvider);
  return prefs.isOnboardingComplete();
});

/// Provider for checking if biometric login is enabled.
final isBiometricLoginEnabledProvider = Provider<bool>((ref) {
  final prefs = ref.watch(preferencesStorageProvider);
  return prefs.isBiometricLoginEnabled();
});

/// Provider for the cache size.
final cacheSizeProvider = FutureProvider<String>((ref) async {
  final fileCache = ref.watch(fileCacheProvider);
  return fileCache.getFormattedSize();
});
