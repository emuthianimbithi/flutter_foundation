import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_ui/foundation_ui.dart';
import '../fakes/fake_auth_repository.dart';

final _authRepoProvider = Provider<FakeAuthRepository>((_) => FakeAuthRepository());
final _authStateProvider = StateProvider<FakeAuthState>((ref) => ref.read(_authRepoProvider).state);

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = FoundationTheme.tokensOf(context);
    final state = ref.watch(_authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Auth')),
      body: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Demo auth flow (login → org selection → MFA)', style: FoundationTheme.typeOf(context).body),
            SizedBox(height: tokens.space16),
            if (state.phase == FakeAuthPhase.idle || state.phase == FakeAuthPhase.loggingIn)
              _LoginForm(onLogin: (email, password) async {
                final repo = ref.read(_authRepoProvider);
                final s = await repo.login(email, password);
                ref.read(_authStateProvider.notifier).state = s;
              }),
            if (state.phase == FakeAuthPhase.needsOrg)
              _OrgSelection(
                orgs: state.orgs,
                onSelect: (slug) async {
                  final s = await ref.read(_authRepoProvider).selectOrg(slug);
                  ref.read(_authStateProvider.notifier).state = s;
                },
              ),
            if (state.phase == FakeAuthPhase.needsMfa)
              _MfaStep(
                error: state.message,
                onVerify: (code) async {
                  final s = await ref.read(_authRepoProvider).verifyMfa(code);
                  ref.read(_authStateProvider.notifier).state = s;
                },
              ),
            if (state.phase == FakeAuthPhase.authenticated)
              const SuccessState(),
          ],
        ),
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  final void Function(String email, String password) onLogin;
  const _LoginForm({required this.onLogin});

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _email = TextEditingController(text: 'user@example.com');
  final _password = TextEditingController(text: 'password123');

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FoundationTextField(label: 'Email', controller: _email),
        SizedBox(height: tokens.space12),
        FoundationTextField(label: 'Password', controller: _password, obscureText: true),
        SizedBox(height: tokens.space16),
        FoundationButton(label: 'Login', onPressed: () => widget.onLogin(_email.text, _password.text)),
      ],
    );
  }
}

class _OrgSelection extends StatelessWidget {
  final List<String> orgs;
  final void Function(String slug) onSelect;
  const _OrgSelection({required this.orgs, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select organization'),
        ...orgs.map((slug) => ListTile(
              title: Text(slug),
              onTap: () => onSelect(slug),
            )),
      ],
    );
  }
}

class _MfaStep extends StatefulWidget {
  final void Function(String code) onVerify;
  final String? error;
  const _MfaStep({required this.onVerify, this.error});

  @override
  State<_MfaStep> createState() => _MfaStepState();
}

class _MfaStepState extends State<_MfaStep> {
  final _code = TextEditingController(text: '000000');

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.error != null) Text(widget.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
        FoundationTextField(label: 'MFA Code', controller: _code),
        SizedBox(height: tokens.space12),
        FoundationButton(label: 'Verify', onPressed: () => widget.onVerify(_code.text)),
      ],
    );
  }
}

class SuccessState extends StatelessWidget {
  const SuccessState({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListTile(
      leading: Icon(Icons.verified, color: Colors.green),
      title: Text('Authenticated'),
      subtitle: Text('Tokens stored via FakeAuthRepository'),
    );
  }
}
