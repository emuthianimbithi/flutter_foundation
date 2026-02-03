import 'package:foundation_core/foundation_core.dart';

/// Domain-level auth failures (suitable for UI messaging).
sealed class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code,
    super.details,
    super.cause,
  });

  const factory AuthFailure.invalidCredentials() = InvalidCredentialsFailure;
  const factory AuthFailure.emailVerificationRequired() = EmailVerificationRequiredFailure;
  const factory AuthFailure.accountSuspended() = AccountSuspendedFailure;
  const factory AuthFailure.accountInactive() = AccountInactiveFailure;
  const factory AuthFailure.noOrganizationAccess() = NoOrganizationAccessFailure;
  const factory AuthFailure.organizationNotFound() = OrganizationNotFoundFailure;
  const factory AuthFailure.mfaRequired() = MfaRequiredFailure;
  const factory AuthFailure.network(String message, {String? code, Object? cause}) = NetworkAuthFailure;
  const factory AuthFailure.unknown(String message, {Object? cause}) = UnknownAuthFailure;
}

final class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super(message: 'Invalid credentials', code: 'invalid_credentials');
}

final class EmailVerificationRequiredFailure extends AuthFailure {
  const EmailVerificationRequiredFailure()
      : super(message: 'Email verification required', code: 'email_verification_required');
}

final class AccountSuspendedFailure extends AuthFailure {
  const AccountSuspendedFailure() : super(message: 'Account suspended', code: 'account_suspended');
}

final class AccountInactiveFailure extends AuthFailure {
  const AccountInactiveFailure() : super(message: 'Account inactive', code: 'account_inactive');
}

final class NoOrganizationAccessFailure extends AuthFailure {
  const NoOrganizationAccessFailure()
      : super(message: 'No organization access for this app', code: 'no_organization_access');
}

final class OrganizationNotFoundFailure extends AuthFailure {
  const OrganizationNotFoundFailure()
      : super(message: 'Organization not found', code: 'organization_not_found');
}

final class MfaRequiredFailure extends AuthFailure {
  const MfaRequiredFailure() : super(message: 'MFA required', code: 'mfa_required');
}

final class NetworkAuthFailure extends AuthFailure {
  const NetworkAuthFailure(String message, {super.code, super.cause}) : super(message: message);
}

final class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure(String message, {super.cause}) : super(message: message, code: 'unknown');
}
