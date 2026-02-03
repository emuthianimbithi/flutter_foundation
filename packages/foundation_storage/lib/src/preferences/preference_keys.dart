/// Keys for preferences storage.
abstract class PreferenceKeys {
  // ─────────────────────────────────────────────────────────────
  // THEME & APPEARANCE
  // ─────────────────────────────────────────────────────────────

  /// Theme mode: 'light', 'dark', 'system'.
  static const themeMode = 'theme_mode';

  /// Whether high contrast mode is enabled.
  static const highContrast = 'high_contrast';

  /// Text scale factor.
  static const textScale = 'text_scale';

  // ─────────────────────────────────────────────────────────────
  // LOCALIZATION
  // ─────────────────────────────────────────────────────────────

  /// Locale code (e.g., 'en_US').
  static const locale = 'locale';

  // ─────────────────────────────────────────────────────────────
  // ONBOARDING
  // ─────────────────────────────────────────────────────────────

  /// Whether onboarding has been completed.
  static const onboardingComplete = 'onboarding_complete';

  /// Last onboarding step shown.
  static const lastOnboardingStep = 'last_onboarding_step';

  /// Dismissed tooltips/coach marks.
  static const dismissedTooltips = 'dismissed_tooltips';

  // ─────────────────────────────────────────────────────────────
  // NOTIFICATIONS
  // ─────────────────────────────────────────────────────────────

  /// Whether notifications are enabled.
  static const notificationsEnabled = 'notifications_enabled';

  /// Whether push notifications are enabled.
  static const pushNotificationsEnabled = 'push_notifications_enabled';

  /// Whether email notifications are enabled.
  static const emailNotificationsEnabled = 'email_notifications_enabled';

  /// Notification topics subscribed to.
  static const notificationTopics = 'notification_topics';

  // ─────────────────────────────────────────────────────────────
  // AUTH
  // ─────────────────────────────────────────────────────────────

  /// Whether biometric login is enabled.
  static const biometricLoginEnabled = 'biometric_login_enabled';

  /// Whether to remember the user's email.
  static const rememberEmail = 'remember_email';

  /// The remembered email address.
  static const rememberedEmail = 'remembered_email';

  /// Last organization slug used.
  static const lastOrganizationSlug = 'last_organization_slug';

  /// Auto-logout timeout in minutes.
  static const autoLogoutTimeout = 'auto_logout_timeout';

  // ─────────────────────────────────────────────────────────────
  // APP STATE
  // ─────────────────────────────────────────────────────────────

  /// Last app version seen.
  static const lastAppVersion = 'last_app_version';

  /// When the app was first launched.
  static const firstLaunchDate = 'first_launch_date';

  /// Number of app launches.
  static const launchCount = 'launch_count';

  /// Whether app review has been requested.
  static const appReviewRequested = 'app_review_requested';

  /// When app review was last requested.
  static const lastReviewRequestDate = 'last_review_request_date';

  // ─────────────────────────────────────────────────────────────
  // SYNC
  // ─────────────────────────────────────────────────────────────

  /// When the last sync occurred.
  static const lastSyncDate = 'last_sync_date';

  /// Whether auto-sync is enabled.
  static const autoSyncEnabled = 'auto_sync_enabled';

  /// Sync interval in minutes.
  static const syncInterval = 'sync_interval';

  /// Whether to sync on wifi only.
  static const syncOnWifiOnly = 'sync_on_wifi_only';

  // ─────────────────────────────────────────────────────────────
  // DEVELOPER / DEBUG
  // ─────────────────────────────────────────────────────────────

  /// Whether developer mode is enabled.
  static const developerModeEnabled = 'developer_mode_enabled';

  /// Whether to show network logs.
  static const showNetworkLogs = 'show_network_logs';

  /// Custom API endpoint (for debugging).
  static const debugApiEndpoint = 'debug_api_endpoint';
}
