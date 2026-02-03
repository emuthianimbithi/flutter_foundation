import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_forms/foundation_forms.dart';
import 'package:foundation_ui/foundation_ui.dart';
import '../fakes/fake_forms_repository.dart';

final _formsRepoProvider = Provider<FakeFormsRepository>((_) => FakeFormsRepository());

class FormsScreen extends ConsumerStatefulWidget {
  const FormsScreen({super.key});

  @override
  ConsumerState<FormsScreen> createState() => _FormsScreenState();
}

class _FormsScreenState extends ConsumerState<FormsScreen> {
  String _selectedTemplateId = 'demo_form';
  Map<String, dynamic>? _lastSubmission;

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    final repo = ref.watch(_formsRepoProvider);
    final template = repo.getTemplate(_selectedTemplateId);
    final fields = repo.toDynamicFields(template);

    return Scaffold(
      appBar: AppBar(title: const Text('Forms')),
      body: ListView(
        padding: EdgeInsets.all(tokens.space16),
        children: [
          Text('Template: ${template.name}', style: FoundationTheme.typeOf(context).h3),
          SizedBox(height: tokens.space12),
          DynamicFormRenderer(
            fields: fields,
            onSubmitted: (data) {
              repo.saveSubmission(template.id, data);
              setState(() => _lastSubmission = data);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved locally')));
            },
          ),
          if (_lastSubmission != null) ...[
            SizedBox(height: tokens.space16),
            Text('Last submission:', style: FoundationTheme.typeOf(context).bodyStrong),
            Text(_lastSubmission.toString()),
          ],
        ],
      ),
    );
  }
}
