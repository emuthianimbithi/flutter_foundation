/// Keys for secure storage.
abstract class SecureStorageKeys {
  // ─────────────────────────────────────────────────────────────
  // AUTH TOKENS
  // ─────────────────────────────────────────────────────────────

  /// Access token key.
  static const accessToken = 'access_token';

  /// Refresh token key.
  static const refreshToken = 'refresh_token';

  /// Access token expiry key.
  static const accessTokenExpiry = 'access_token_expiry';

  /// Refresh token expiry key.
  static const refreshTokenExpiry = 'refresh_token_expiry';

  // ─────────────────────────────────────────────────────────────
  // USER/SESSION
  // ─────────────────────────────────────────────────────────────

  /// Current user ID key.
  static const userId = 'user_id';

  /// Current organization ID key.
  static const organizationId = 'organization_id';

  /// Current organization slug key.
  static const organizationSlug = 'organization_slug';

  /// Current session ID key.
  static const sessionId = 'session_id';

  // ─────────────────────────────────────────────────────────────
  // BIOMETRIC
  // ─────────────────────────────────────────────────────────────

  /// Biometric secret key.
  static const biometricSecret = 'biometric_secret';

  /// Whether biometric is enabled.
  static const biometricEnabled = 'biometric_enabled';

  // ─────────────────────────────────────────────────────────────
  // MFA
  // ─────────────────────────────────────────────────────────────

  /// MFA token key (temporary during MFA flow).
  static const mfaToken = 'mfa_token';

  /// Org selection token key (temporary during org selection flow).
  static const orgSelectionToken = 'org_selection_token';

  // ─────────────────────────────────────────────────────────────
  // ENCRYPTION
  // ─────────────────────────────────────────────────────────────

  /// Database encryption key.
  static const dbEncryptionKey = 'db_encryption_key';

  /// General encryption key.
  static const encryptionKey = 'encryption_key';

  // ─────────────────────────────────────────────────────────────
  // API KEYS (for external services)
  // ─────────────────────────────────────────────────────────────

  /// Firebase token key.
  static const firebaseToken = 'firebase_token';

  /// Push notification token key.
  static const pushToken = 'push_token';
}
