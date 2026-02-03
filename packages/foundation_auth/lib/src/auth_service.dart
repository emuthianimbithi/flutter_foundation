import 'package:foundation_config/foundation_config.dart';
import 'package:foundation_networking/foundation_networking.dart';
import 'package:foundation_auth/src/auth_state.dart';
import 'package:foundation_auth/src/token_manager.dart';
import 'package:grpc/grpc.dart';

/// Your generated Dart stubs.
/// Adjust the import path to match how `protos/gen/dart` is structured.
import 'package:marulla_protos/marulla/sso/v1/auth.pbgrpc.dart' as pb;
import 'package:marulla_protos/marulla/sso/v1/mfa.pbgrpc.dart' as mfa_pb;

/// Simple DTOs for MFA feature management.
class TotpSetupData {
  final String secret;
  final String qrCodeUri;
  final String issuer;
  final String accountName;

  const TotpSetupData({
    required this.secret,
    required this.qrCodeUri,
    required this.issuer,
    required this.accountName,
  });
}

class MfaStatusData {
  final bool totpEnabled;
  final int recoveryCodesRemaining;
  final DateTime? totpEnabledAt;
  final DateTime? recoveryCodesGeneratedAt;

  const MfaStatusData({
    required this.totpEnabled,
    required this.recoveryCodesRemaining,
    this.totpEnabledAt,
    this.recoveryCodesGeneratedAt,
  });
}

/// Wraps the generated gRPC AuthServiceClient + MFAServiceClient with app-level semantics.
class AuthService {
  final pb.AuthServiceClient _authClient;
  final mfa_pb.MFAServiceClient _mfaClient;
  final TokenManager _tokenManager;
  final AppConfig _appConfig;
  Future<AuthState>? _refreshInFlight;
  final DateTime Function() _now;
  final Future<AuthState> Function()? _refreshOverride;

  AuthService({
    required GrpcChannelFactory channelFactory,
    required TokenManager tokenManager,
    required AppConfig appConfig,
    DateTime Function()? now,
    Future<AuthState> Function()? refreshOverride,
  })  : _tokenManager = tokenManager,
        _appConfig = appConfig,
        _now = now ?? DateTime.now,
        _refreshOverride = refreshOverride,
        _authClient = pb.AuthServiceClient(
          channelFactory.getChannel(),
          options: channelFactory.defaultCallOptions,
        ),
        _mfaClient = mfa_pb.MFAServiceClient(
          channelFactory.getChannel(),
          options: channelFactory.defaultCallOptions,
        );

  // ---------------------------------------------------------------------------
  // AUTH (login/session)
  // ---------------------------------------------------------------------------

  /// Login flow:
  /// - may return org selection requirement
  /// - may return MFA requirement
  /// - otherwise stores tokens and returns authenticated state
  Future<AuthState> login({
    required String email,
    required String password,
    String? orgSlug,
  }) async {
    final req = pb.LoginRequest()
      ..email = email
      ..password = password
      ..appId = _appConfig.appId;
    if (orgSlug != null && orgSlug.isNotEmpty) {
      req.orgSlug = orgSlug;
    }

    final resp = await _authClient.login(req);

    if (resp.requiresOrgSelection) {
      final orgs = resp.organizations
          .map((o) => OrganizationOption(
                id: o.id,
                slug: o.slug,
                name: o.name,
                logoUrl: o.hasLogoUrl() ? o.logoUrl : null,
                role: o.role,
              ))
          .toList(growable: false);
      return AuthState.requiresOrgSelection(
        orgSelectionToken: resp.orgSelectionToken,
        organizations: orgs,
      );
    }

    if (resp.requiresMfa) {
      return AuthState.requiresMfa(
        mfaToken: resp.mfaToken,
        methods: resp.mfaMethods,
      );
    }

    // Success
    await _persistLoginResponse(resp);

    return AuthState.authenticated(
      userId: resp.user.id,
      orgSlug: resp.organization.slug,
      features: resp.features,
      role: resp.role,
      accessToken: resp.accessToken,
      refreshToken: resp.refreshToken,
    );
  }

  /// Completes the org selection step when login required it.
  Future<AuthState> selectOrganization({
    required String orgSelectionToken,
    required String orgSlug,
  }) async {
    final req = pb.SelectOrganizationRequest()
      ..orgSelectionToken = orgSelectionToken
      ..orgSlug = orgSlug
      ..appId = _appConfig.appId;

    final resp = await _authClient.selectOrganization(req);

    if (resp.requiresMfa) {
      return AuthState.requiresMfa(
        mfaToken: resp.mfaToken,
        methods: resp.mfaMethods,
      );
    }

    await _persistLoginResponse(resp);

    return AuthState.authenticated(
      userId: resp.user.id,
      orgSlug: resp.organization.slug,
      features: resp.features,
      role: resp.role,
      accessToken: resp.accessToken,
      refreshToken: resp.refreshToken,
    );
  }

  /// Switch org while already authenticated.
  Future<AuthState> switchOrganization({required String orgSlug}) async {
    final req = pb.SwitchOrganizationRequest()
      ..orgSlug = orgSlug
      ..appId = _appConfig.appId;

    final resp = await _authClient.switchOrganization(req);

    await _persistLoginResponse(resp);

    return AuthState.authenticated(
      userId: resp.user.id,
      orgSlug: resp.organization.slug,
      features: resp.features,
      role: resp.role,
      accessToken: resp.accessToken,
      refreshToken: resp.refreshToken,
    );
  }

  Future<void> logout({String? refreshToken}) async {
    final req = pb.LogoutRequest();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      req.refreshToken = refreshToken;
    }
    await _authClient.logout(req);
    await _tokenManager.clear();
  }

  /// Refresh tokens using RefreshToken RPC.
  Future<AuthState> refresh() async {
    if (_refreshInFlight != null) return _refreshInFlight!;
    _refreshInFlight = _refreshInternal();
    try {
      return await _refreshInFlight!;
    } finally {
      _refreshInFlight = null;
    }
  }

  /// Verify MFA to complete login.
  ///
  /// Your backend splits MFA by method:
  /// - TOTP: MFAService.VerifyMFA(mfa_token, code) -> LoginResponse
  /// - Recovery codes: MFAService.UseRecoveryCode(mfa_token, recovery_code) -> LoginResponse
  Future<AuthState> verifyMfa({
    required String mfaToken,
    required String method,
    required String code,
  }) async {
    late final pb.LoginResponse resp;

    switch (method) {
      case 'totp':
        final req = mfa_pb.VerifyMFARequest()
          ..mfaToken = mfaToken
          ..code = code;
        resp = await _mfaClient.verifyMFA(req);
        break;
      case 'recovery_code':
        final req = mfa_pb.UseRecoveryCodeRequest()
          ..mfaToken = mfaToken
          ..recoveryCode = code;
        resp = await _mfaClient.useRecoveryCode(req);
        break;
      default:
        throw GrpcError.invalidArgument('Unsupported MFA method: $method');
    }

    await _persistLoginResponse(resp);

    return AuthState.authenticated(
      userId: resp.user.id,
      orgSlug: resp.organization.slug,
      features: resp.features,
      role: resp.role,
      accessToken: resp.accessToken,
      refreshToken: resp.refreshToken,
    );
  }

  Future<AuthState> _refreshInternal() async {
    if (_refreshOverride != null) {
      return _refreshOverride!();
    }
    final refreshToken = await _tokenManager.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return const AuthState.unauthenticated(message: 'No refresh token');
    }

    final req = pb.RefreshTokenRequest()..refreshToken = refreshToken;
    final resp = await _authClient.refreshToken(req);

    await _tokenManager.saveTokens(
      accessToken: resp.accessToken,
      refreshToken: resp.refreshToken,
      accessExpiry: resp.accessTokenExpiresAt.toDateTime(),
      refreshExpiry: resp.refreshTokenExpiresAt.toDateTime(),
    );

    final snapshot = await _tokenManager.loadSnapshot();
    return AuthState.authenticated(
      userId: snapshot.userId ?? '',
      orgSlug: snapshot.orgSlug,
      features: const [],
      role: snapshot.role ?? '',
      accessToken: resp.accessToken,
      refreshToken: resp.refreshToken,
    );
  }

  Future<void> _persistLoginResponse(pb.LoginResponse resp) async {
    final accessExp = resp.accessTokenExpiresAt.toDateTime();
    final refreshExp = resp.refreshTokenExpiresAt.toDateTime();

    await _tokenManager.saveTokens(
      accessToken: resp.accessToken,
      refreshToken: resp.refreshToken,
      accessExpiry: accessExp,
      refreshExpiry: refreshExp,
      orgSlug: resp.organization.slug,
      userId: resp.user.id,
      role: resp.role,
    );
  }

  // ---------------------------------------------------------------------------
  // MFA FEATURE MANAGEMENT (setup/disable/status/recovery codes)
  // ---------------------------------------------------------------------------

  /// Start TOTP setup: returns secret + provisioning URI for QR.
  /// Requires the user to be authenticated (server reads claims from context).
  Future<TotpSetupData> setupTotp() async {
    final resp = await _mfaClient.setupTOTP(mfa_pb.SetupTOTPRequest());
    return TotpSetupData(
      secret: resp.secret,
      qrCodeUri: resp.qrCodeUri,
      issuer: resp.issuer,
      accountName: resp.accountName,
    );
  }

  /// Verify the TOTP setup and enable it. Returns plain-text recovery codes once.
  Future<List<String>> verifyTotpSetup({required String code}) async {
    final resp = await _mfaClient.verifyTOTPSetup(
      mfa_pb.VerifyTOTPSetupRequest()..code = code,
    );
    if (!resp.success) {
      throw GrpcError.unknown('TOTP setup verification failed');
    }
    return resp.recoveryCodes;
  }

  /// Disable TOTP (and clear recovery codes) after password + current TOTP code.
  Future<void> disableTotp(
      {required String password, required String code}) async {
    await _mfaClient.disableTOTP(
      mfa_pb.DisableTOTPRequest()
        ..password = password
        ..code = code,
    );
  }

  /// Generate a fresh set of recovery codes (returns plaintext once).
  Future<List<String>> generateRecoveryCodes({required String password}) async {
    final resp = await _mfaClient.generateRecoveryCodes(
      mfa_pb.GenerateRecoveryCodesRequest()..password = password,
    );
    return resp.recoveryCodes;
  }

  /// Fetch MFA status for the current user.
  Future<MfaStatusData> getMfaStatus() async {
    final resp = await _mfaClient.getMFAStatus(mfa_pb.GetMFAStatusRequest());
    return MfaStatusData(
      totpEnabled: resp.totpEnabled,
      recoveryCodesRemaining: resp.recoveryCodesRemaining,
      totpEnabledAt:
          resp.hasTotpEnabledAt() ? resp.totpEnabledAt.toDateTime() : null,
      recoveryCodesGeneratedAt: resp.hasRecoveryCodesGeneratedAt()
          ? resp.recoveryCodesGeneratedAt.toDateTime()
          : null,
    );
  }
}
