import 'package:foundation_core/foundation_core.dart';

/// Domain-level auth failures (suitable for UI messaging).
sealed class AuthFailure extends Failure {
  const AuthFailure({
    required super.type,
    required super.message,
    super.code,
    super.details,
    super.originalException,
  });

  const factory AuthFailure.invalidCredentials() = InvalidCredentialsFailure;
  const factory AuthFailure.emailVerificationRequired() =
      EmailVerificationRequiredFailure;
  const factory AuthFailure.accountSuspended() = AccountSuspendedFailure;
  const factory AuthFailure.accountInactive() = AccountInactiveFailure;
  const factory AuthFailure.noOrganizationAccess() =
      NoOrganizationAccessFailure;
  const factory AuthFailure.organizationNotFound() =
      OrganizationNotFoundFailure;
  const factory AuthFailure.mfaRequired() = MfaRequiredFailure;
  const factory AuthFailure.network(String message,
      {String? code, Object? originalException}) = NetworkAuthFailure;
  const factory AuthFailure.unknown(String message,
      {Object? originalException}) = UnknownAuthFailure;
}

final class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure()
      : super(
          type: FailureType.authentication,
          message: 'Invalid credentials',
          code: 'invalid_credentials',
        );
}

final class EmailVerificationRequiredFailure extends AuthFailure {
  const EmailVerificationRequiredFailure()
      : super(
          type: FailureType.authentication,
          message: 'Email verification required',
          code: 'email_verification_required',
        );
}

final class AccountSuspendedFailure extends AuthFailure {
  const AccountSuspendedFailure()
      : super(
          type: FailureType.authorization,
          message: 'Account suspended',
          code: 'account_suspended',
        );
}

final class AccountInactiveFailure extends AuthFailure {
  const AccountInactiveFailure()
      : super(
          type: FailureType.authorization,
          message: 'Account inactive',
          code: 'account_inactive',
        );
}

final class NoOrganizationAccessFailure extends AuthFailure {
  const NoOrganizationAccessFailure()
      : super(
          type: FailureType.authorization,
          message: 'No organization access for this app',
          code: 'no_organization_access',
        );
}

final class OrganizationNotFoundFailure extends AuthFailure {
  const OrganizationNotFoundFailure()
      : super(
          type: FailureType.notFound,
          message: 'Organization not found',
          code: 'organization_not_found',
        );
}

final class MfaRequiredFailure extends AuthFailure {
  const MfaRequiredFailure()
      : super(
          type: FailureType.authentication,
          message: 'MFA required',
          code: 'mfa_required',
        );
}

final class NetworkAuthFailure extends AuthFailure {
  const NetworkAuthFailure(String message,
      {super.code, super.originalException})
      : super(type: FailureType.network, message: message);
}

final class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure(String message, {super.originalException})
      : super(type: FailureType.unexpected, message: message, code: 'unknown');
}
