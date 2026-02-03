# foundation_routing

Routing + deep-link package for the Flutter Foundation monorepo.

- Built on **go_router**
- Integrates with **Riverpod**
- Redirect logic driven by `AuthState` from `foundation_auth`

## Usage (monorepo)

Add to your app:

```yaml
dependencies:
  foundation_routing:
    path: packages/foundation_routing
```

Override page builders via `appRouterConfigProvider`:

```dart
ProviderScope(
  overrides: [
    appRouterConfigProvider.overrideWithValue(
      AppRouterConfig(
        loginBuilder: (_) => const LoginPage(),
        homeBuilder: (_) => const HomePage(),
        // ...
      ),
    ),
  ],
  child: const MyApp(),
);
```

Then use:

```dart
final router = ref.read(goRouterProvider);
MaterialApp.router(routerConfig: router);
```
