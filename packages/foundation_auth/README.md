# foundation_auth

Headless auth state machine for Marulla SSO: token persistence, refresh, org-selection, MFA, and Riverpod providers.

## Happy path (with foundation_bootstrap)
- Call `FoundationBootstrap.initialize(...)`
- Wrap app with `ProviderScope(overrides: FoundationBootstrap.overrides())`
- Use `authStateProvider` in router/UI; defaults to auth-driven routing.

## Token restore + refresh
- On startup `SessionManager.restore()` loads tokens from secure storage/prefs.
- If access token expires within `AuthOptions.refreshLeeway` and refresh token is valid, `AuthService.refresh()` runs.
- Refresh is coalesced: concurrent refresh calls execute the RPC exactly once.

## Override providers
```dart
ProviderScope(
  overrides: [
    authOptionsProvider.overrideWithValue(
      const AuthOptions(refreshLeeway: Duration(seconds: 10), logoutClearsStorage: false),
    ),
    grpcChannelFactoryProvider.overrideWithValue(myGrpcFactory),
    authServiceProvider.overrideWith((ref) => MyAuthService(...)),
  ],
  child: MyApp(),
);
```

## MFA
- Default flow supports TOTP/recovery via `MfaPage` when backend signals `requiresMfa`.
- If backend does not require MFA, login completes normally.

## Failures
- Refresh with missing/expired refresh token -> `AuthState.unauthenticated(message)`
- Unsupported MFA method -> `GrpcError.invalidArgument`

## Tests
- `test/auth_refresh_test.dart` covers refresh coalescing, leeway, and logout clearing.
