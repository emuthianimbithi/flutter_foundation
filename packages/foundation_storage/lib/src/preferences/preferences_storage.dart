import 'dart:convert';

import 'package:foundation_core/foundation_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'preference_keys.dart';

/// Key-value storage for app preferences and settings.
///
/// Uses SharedPreferences for persistent storage of non-sensitive data.
///
/// Example:
/// ```dart
/// final prefs = PreferencesStorage();
/// await prefs.init();
///
/// // Store settings
/// await prefs.setThemeMode('dark');
/// await prefs.setLocale('en_US');
///
/// // Retrieve settings
/// final theme = prefs.getThemeMode();
/// ```
class PreferencesStorage {
  SharedPreferences? _prefs;
  final AppLogger _log = AppLogger('PreferencesStorage');

  /// Whether the storage has been initialized.
  bool get isInitialized => _prefs != null;

  /// Initializes the preferences storage.
  Future<void> init() async {
    if (_prefs != null) return;
    _prefs = await SharedPreferences.getInstance();
    _log.debug('PreferencesStorage initialized');
  }

  /// Ensures the storage is initialized.
  void _ensureInitialized() {
    if (_prefs == null) {
      throw StateError(
          'PreferencesStorage not initialized. Call init() first.');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // GENERIC OPERATIONS
  // ─────────────────────────────────────────────────────────────

  /// Gets a string value.
  String? getString(String key) {
    _ensureInitialized();
    return _prefs!.getString(key);
  }

  /// Sets a string value.
  Future<bool> setString(String key, String value) {
    _ensureInitialized();
    return _prefs!.setString(key, value);
  }

  /// Gets an int value.
  int? getInt(String key) {
    _ensureInitialized();
    return _prefs!.getInt(key);
  }

  /// Sets an int value.
  Future<bool> setInt(String key, int value) {
    _ensureInitialized();
    return _prefs!.setInt(key, value);
  }

  /// Gets a double value.
  double? getDouble(String key) {
    _ensureInitialized();
    return _prefs!.getDouble(key);
  }

  /// Sets a double value.
  Future<bool> setDouble(String key, double value) {
    _ensureInitialized();
    return _prefs!.setDouble(key, value);
  }

  /// Gets a bool value.
  bool? getBool(String key) {
    _ensureInitialized();
    return _prefs!.getBool(key);
  }

  /// Sets a bool value.
  Future<bool> setBool(String key, bool value) {
    _ensureInitialized();
    return _prefs!.setBool(key, value);
  }

  /// Gets a string list.
  List<String>? getStringList(String key) {
    _ensureInitialized();
    return _prefs!.getStringList(key);
  }

  /// Sets a string list.
  Future<bool> setStringList(String key, List<String> value) {
    _ensureInitialized();
    return _prefs!.setStringList(key, value);
  }

  /// Gets a JSON object.
  Map<String, dynamic>? getJson(String key) {
    _ensureInitialized();
    final value = _prefs!.getString(key);
    if (value == null) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Sets a JSON object.
  Future<bool> setJson(String key, Map<String, dynamic> value) {
    _ensureInitialized();
    return _prefs!.setString(key, jsonEncode(value));
  }

  /// Gets a DateTime value.
  DateTime? getDateTime(String key) {
    final value = getString(key);
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  /// Sets a DateTime value.
  Future<bool> setDateTime(String key, DateTime value) {
    return setString(key, value.toIso8601String());
  }

  /// Removes a value.
  Future<bool> remove(String key) {
    _ensureInitialized();
    return _prefs!.remove(key);
  }

  /// Clears all values.
  Future<bool> clear() {
    _ensureInitialized();
    _log.info('Clearing all preferences');
    return _prefs!.clear();
  }

  /// Whether a key exists.
  bool containsKey(String key) {
    _ensureInitialized();
    return _prefs!.containsKey(key);
  }

  /// Gets all keys.
  Set<String> getKeys() {
    _ensureInitialized();
    return _prefs!.getKeys();
  }

  // ─────────────────────────────────────────────────────────────
  // THEME & APPEARANCE
  // ─────────────────────────────────────────────────────────────

  /// Gets the theme mode ('light', 'dark', 'system').
  String getThemeMode() => getString(PreferenceKeys.themeMode) ?? 'system';

  /// Sets the theme mode.
  Future<bool> setThemeMode(String mode) =>
      setString(PreferenceKeys.themeMode, mode);

  /// Whether high contrast is enabled.
  bool isHighContrastEnabled() => getBool(PreferenceKeys.highContrast) ?? false;

  /// Sets high contrast mode.
  Future<bool> setHighContrastEnabled(bool enabled) =>
      setBool(PreferenceKeys.highContrast, enabled);

  // ─────────────────────────────────────────────────────────────
  // LOCALIZATION
  // ─────────────────────────────────────────────────────────────

  /// Gets the locale code.
  String? getLocale() => getString(PreferenceKeys.locale);

  /// Sets the locale code.
  Future<bool> setLocale(String locale) =>
      setString(PreferenceKeys.locale, locale);

  // ─────────────────────────────────────────────────────────────
  // ONBOARDING
  // ─────────────────────────────────────────────────────────────

  /// Whether onboarding has been completed.
  bool isOnboardingComplete() =>
      getBool(PreferenceKeys.onboardingComplete) ?? false;

  /// Sets onboarding completion status.
  Future<bool> setOnboardingComplete(bool complete) =>
      setBool(PreferenceKeys.onboardingComplete, complete);

  /// Gets the last onboarding step shown.
  int getLastOnboardingStep() => getInt(PreferenceKeys.lastOnboardingStep) ?? 0;

  /// Sets the last onboarding step shown.
  Future<bool> setLastOnboardingStep(int step) =>
      setInt(PreferenceKeys.lastOnboardingStep, step);

  // ─────────────────────────────────────────────────────────────
  // NOTIFICATIONS
  // ─────────────────────────────────────────────────────────────

  /// Whether notifications are enabled.
  bool areNotificationsEnabled() =>
      getBool(PreferenceKeys.notificationsEnabled) ?? true;

  /// Sets notifications enabled status.
  Future<bool> setNotificationsEnabled(bool enabled) =>
      setBool(PreferenceKeys.notificationsEnabled, enabled);

  /// Whether push notifications are enabled.
  bool arePushNotificationsEnabled() =>
      getBool(PreferenceKeys.pushNotificationsEnabled) ?? true;

  /// Sets push notifications enabled status.
  Future<bool> setPushNotificationsEnabled(bool enabled) =>
      setBool(PreferenceKeys.pushNotificationsEnabled, enabled);

  // ─────────────────────────────────────────────────────────────
  // AUTH PREFERENCES
  // ─────────────────────────────────────────────────────────────

  /// Whether biometric login is enabled.
  bool isBiometricLoginEnabled() =>
      getBool(PreferenceKeys.biometricLoginEnabled) ?? false;

  /// Sets biometric login enabled status.
  Future<bool> setBiometricLoginEnabled(bool enabled) =>
      setBool(PreferenceKeys.biometricLoginEnabled, enabled);

  /// Whether to remember the user's email.
  bool isRememberEmailEnabled() =>
      getBool(PreferenceKeys.rememberEmail) ?? false;

  /// Sets remember email status.
  Future<bool> setRememberEmailEnabled(bool enabled) =>
      setBool(PreferenceKeys.rememberEmail, enabled);

  /// Gets the remembered email.
  String? getRememberedEmail() => getString(PreferenceKeys.rememberedEmail);

  /// Sets the remembered email.
  Future<bool> setRememberedEmail(String? email) {
    if (email == null) return remove(PreferenceKeys.rememberedEmail);
    return setString(PreferenceKeys.rememberedEmail, email);
  }

  /// Gets the last organization slug.
  String? getLastOrganizationSlug() =>
      getString(PreferenceKeys.lastOrganizationSlug);

  /// Sets the last organization slug.
  Future<bool> setLastOrganizationSlug(String slug) =>
      setString(PreferenceKeys.lastOrganizationSlug, slug);

  // ─────────────────────────────────────────────────────────────
  // APP STATE
  // ─────────────────────────────────────────────────────────────

  /// Gets the last app version seen.
  String? getLastAppVersion() => getString(PreferenceKeys.lastAppVersion);

  /// Sets the last app version seen.
  Future<bool> setLastAppVersion(String version) =>
      setString(PreferenceKeys.lastAppVersion, version);

  /// Gets when the app was first launched.
  DateTime? getFirstLaunchDate() => getDateTime(PreferenceKeys.firstLaunchDate);

  /// Sets when the app was first launched.
  Future<bool> setFirstLaunchDate(DateTime date) =>
      setDateTime(PreferenceKeys.firstLaunchDate, date);

  /// Gets the launch count.
  int getLaunchCount() => getInt(PreferenceKeys.launchCount) ?? 0;

  /// Increments the launch count.
  Future<bool> incrementLaunchCount() =>
      setInt(PreferenceKeys.launchCount, getLaunchCount() + 1);
}
