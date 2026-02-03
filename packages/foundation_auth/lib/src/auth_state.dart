import 'package:meta/meta.dart';

/// High-level auth phases.
enum AuthPhase {
  unauthenticated,
  authenticating,
  requiresOrgSelection,
  requiresMfa,
  authenticated,
}

/// Minimal organization option (mirrors proto fields used in LoginResponse).
@immutable
class OrganizationOption {
  final String id;
  final String slug;
  final String name;
  final String? logoUrl;
  final String role;

  const OrganizationOption({
    required this.id,
    required this.slug,
    required this.name,
    this.logoUrl,
    required this.role,
  });

  @override
  String toString() => 'OrganizationOption(slug: $slug, name: $name)';
}

/// Auth state model used by the app/router.
@immutable
class AuthState {
  final AuthPhase phase;

  /// Present only when phase == requiresOrgSelection
  final String? orgSelectionToken;
  final List<OrganizationOption> organizations;

  /// Present only when phase == requiresMfa
  final String? mfaToken;
  final List<String> mfaMethods;

  /// Present only when phase == authenticated
  final String? userId;
  final String? orgSlug;
  final List<String> features;
  final String? role;

  final String? accessToken;
  final String? refreshToken;

  final String? message;

  const AuthState._({
    required this.phase,
    this.orgSelectionToken,
    this.organizations = const [],
    this.mfaToken,
    this.mfaMethods = const [],
    this.userId,
    this.orgSlug,
    this.features = const [],
    this.role,
    this.accessToken,
    this.refreshToken,
    this.message,
  });

  const AuthState.unauthenticated({String? message})
      : this._(phase: AuthPhase.unauthenticated, message: message);

  const AuthState.authenticating() : this._(phase: AuthPhase.authenticating);

  const AuthState.requiresOrgSelection({
    required String orgSelectionToken,
    required List<OrganizationOption> organizations,
    String? message,
  }) : this._(
          phase: AuthPhase.requiresOrgSelection,
          orgSelectionToken: orgSelectionToken,
          organizations: organizations,
          message: message,
        );

  const AuthState.requiresMfa({
    required String mfaToken,
    required List<String> methods,
    String? message,
  }) : this._(
          phase: AuthPhase.requiresMfa,
          mfaToken: mfaToken,
          mfaMethods: methods,
          message: message,
        );

  const AuthState.authenticated({
    required String userId,
    required String? orgSlug,
    required List<String> features,
    required String role,
    required String accessToken,
    required String refreshToken,
  }) : this._(
          phase: AuthPhase.authenticated,
          userId: userId,
          orgSlug: orgSlug,
          features: features,
          role: role,
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

  bool get isAuthenticated => phase == AuthPhase.authenticated;

  @override
  String toString() =>
      'AuthState(phase: $phase, userId: $userId, orgSlug: $orgSlug)';
}
