import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_auth/foundation_auth.dart';
import 'package:foundation_ui/foundation_ui.dart';

/// Simple splash/loader page.
class SplashPage extends StatelessWidget {
  final String appName;
  const SplashPage({super.key, required this.appName});

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

/// Wrapper around the foundation_auth login page.
class DefaultLoginPage extends StatelessWidget {
  const DefaultLoginPage({super.key});

  @override
  Widget build(BuildContext context) => const LoginPage();
}

class DefaultOrgSelectionPage extends ConsumerWidget {
  const DefaultOrgSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authStateProvider);
    if (state.phase == AuthPhase.requiresOrgSelection &&
        state.orgSelectionToken != null) {
      return OrgSelectorPage(
        orgSelectionToken: state.orgSelectionToken!,
        organizations: state.organizations,
      );
    }
    return const _InfoScaffold(
        title: 'Organization', message: 'No organization selection required.');
  }
}

class DefaultMfaPage extends ConsumerWidget {
  const DefaultMfaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authStateProvider);
    if (state.phase == AuthPhase.requiresMfa &&
        state.mfaToken != null &&
        state.mfaMethods.isNotEmpty) {
      return MfaPage(mfaToken: state.mfaToken!, methods: state.mfaMethods);
    }
    return const _InfoScaffold(
        title: 'MFA', message: 'No MFA challenge active.');
  }
}

class ForbiddenPage extends ConsumerWidget {
  const ForbiddenPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forbidden')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('You do not have access to this section.'),
            const SizedBox(height: 16),
            FoundationButton(
              label: 'Logout',
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).logout(),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoScaffold extends StatelessWidget {
  final String title;
  final String message;
  const _InfoScaffold({required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(message)),
    );
  }
}
