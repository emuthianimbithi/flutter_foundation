import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_auth/src/providers/providers.dart';

class MfaPage extends ConsumerStatefulWidget {
  final String mfaToken;
  final List<String> methods;

  const MfaPage({
    super.key,
    required this.mfaToken,
    required this.methods,
  });

  @override
  ConsumerState<MfaPage> createState() => _MfaPageState();
}

class _MfaPageState extends ConsumerState<MfaPage> {
  final _code = TextEditingController();
  bool _loading = false;
  late String _method;

  @override
  void initState() {
    super.initState();
    _method = widget.methods.isNotEmpty ? widget.methods.first : 'totp';
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() => _loading = true);
    final res = await ref.read(authControllerProvider.notifier).verifyMfa(mfaToken: widget.mfaToken, method: _method, code: _code.text.trim());
    if (!res.isOk) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res.error?.message ?? 'MFA verification failed')),
      );
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MFA')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Methods: ${widget.methods.join(', ')}'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _method,
              items: widget.methods
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(growable: false),
              onChanged: _loading ? null : (v) => setState(() => _method = v ?? _method),
              decoration: const InputDecoration(labelText: 'Method'),
            ),
            const SizedBox(height: 12),
            TextField(controller: _code, decoration: const InputDecoration(labelText: 'Code')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _verify,
                child: Text(_loading ? 'Verifying...' : 'Verify'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
