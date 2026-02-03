# foundation_routing

GoRouter wiring with auth-aware redirects, deep-link queueing, and sensible default pages.

## Modes
- **Auth-driven (default):** protects routes using `authStateProvider` phases (unauth → login, org → /org, mfa → /mfa, auth → /home).
- **Simple:** no auth redirects; use for public apps or shell flows.

## Quickstart
```dart
final router = AppRouter(
  ref: ref,
  config: AppRouterConfig(
    options: const RoutingOptions(mode: RoutingMode.authDriven),
    homeBuilder: (_) => const HomePage(),
  ),
).router;
```

### Simple mode
```dart
final router = AppRouter(
  ref: ref,
  config: AppRouterConfig(
    options: const RoutingOptions(mode: RoutingMode.simple),
    homeBuilder: (_) => const PublicHome(),
  ),
).router;
```

## Custom pages
Override any builder:
```dart
AppRouterConfig(
  homeBuilder: (_) => const Home(),
  loginBuilder: (_) => const MyLogin(),
  splashBuilder: (_) => const MySplash(),
  forbiddenBuilder: (_) => const Forbidden(),
)
```

## Deep links
- Incoming deep links are mapped via `DeepLinkHandler.mapIncomingUri`.
- If auth state isn’t ready, the link is queued and resumed after authentication (auth-driven mode).

## Tests
See `test/redirect_policy_test.dart` for auth vs simple mode redirects and deep-link queue behavior.
