part of 'foundation_bootstrap.dart';

/// Builds the default router wired to Foundation auth/routing pieces.
class FoundationBootstrapRouter {
  const FoundationBootstrapRouter._();

  static GoRouter build({
    required WidgetRef ref,
    required WidgetBuilder homeBuilder,
    WidgetBuilder? loginBuilder,
    WidgetBuilder? splashBuilder,
    WidgetBuilder? orgSelectionBuilder,
    WidgetBuilder? mfaBuilder,
    WidgetBuilder? forbiddenBuilder,
    BootstrapRoutingOptions routingOptions = const BootstrapRoutingOptions(),
  }) {
    final config = AppRouterConfig(
      options: RoutingOptions(
        mode: routingOptions.mode,
        initialRoute: routingOptions.initialRoute ?? AppRoutes.splash,
        enableDeepLinks: routingOptions.enableDeepLinks,
        deepLinkQueueUntilAuthReady: routingOptions.deepLinkQueueUntilAuthReady,
      ),
      splashBuilder: splashBuilder ?? _defaultSplashBuilder,
      loginBuilder: loginBuilder ?? _defaultLoginBuilder,
      orgSelectBuilder: orgSelectionBuilder ?? _defaultOrgSelectionBuilder,
      mfaBuilder: mfaBuilder ?? _defaultMfaBuilder,
      homeBuilder: homeBuilder,
      forbiddenBuilder: forbiddenBuilder ?? _defaultForbiddenBuilder,
    );

    final router = AppRouter(ref: ref, config: config).router;

    if (routingOptions.initialRoute != null) {
      router.go(routingOptions.initialRoute!);
    }
    return router;
  }

  // ─────────────────────────────────────────────────────────────
  // DEFAULT PAGES
  // ─────────────────────────────────────────────────────────────

  static Widget _defaultSplashBuilder(BuildContext context) =>
      _BootstrapSplashPage(
        appName: FoundationBootstrap.config.appName,
      );

  static Widget _defaultLoginBuilder(BuildContext context) =>
      const auth.LoginPage();

  static Widget _defaultOrgSelectionBuilder(BuildContext context) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(auth.authStateProvider);
          if (state.phase == auth.AuthPhase.requiresOrgSelection &&
              state.orgSelectionToken != null) {
            return auth.OrgSelectorPage(
              orgSelectionToken: state.orgSelectionToken!,
              organizations: state.organizations,
            );
          }
          return const _BootstrapErrorPage(
            title: 'Organization',
            message: 'No organization selection in progress.',
          );
        },
      );

  static Widget _defaultMfaBuilder(BuildContext context) => Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(auth.authStateProvider);
          if (state.phase == auth.AuthPhase.requiresMfa &&
              state.mfaToken != null &&
              state.mfaMethods.isNotEmpty) {
            return auth.MfaPage(
              mfaToken: state.mfaToken!,
              methods: state.mfaMethods,
            );
          }
          return const _BootstrapErrorPage(
            title: 'MFA',
            message: 'No MFA challenge active.',
          );
        },
      );

  static Widget _defaultForbiddenBuilder(BuildContext context) => Consumer(
        builder: (context, ref, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Forbidden')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('You do not have access to this section.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(auth.authControllerProvider.notifier).logout(),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          );
        },
      );
}

class _BootstrapSplashPage extends StatelessWidget {
  final String appName;
  const _BootstrapSplashPage({required this.appName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(appName, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class _BootstrapErrorPage extends StatelessWidget {
  final String title;
  final String message;
  const _BootstrapErrorPage({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(message)),
    );
  }
}
