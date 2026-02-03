import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_ui/foundation_ui.dart';
import '../providers/form_providers.dart';
import '../validators/validators.dart';

class ValidatedTextField extends ConsumerWidget {
  final String fieldKey;
  final String? label;
  final String? hint;
  final List<String? Function(String?)> validators;
  final TextInputType? keyboardType;
  final bool obscureText;

  const ValidatedTextField({
    super.key,
    required this.fieldKey,
    this.label,
    this.hint,
    this.validators = const [],
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(foundationFormControllerProvider);
    final current = form.field<String>(fieldKey, initial: '');

    return FoundationTextField(
      label: label,
      hint: hint,
      keyboardType: keyboardType,
      obscureText: obscureText,
      errorText: current.error,
      onChanged: (v) {
        final err = Validators.combine(v, validators);
        ref.read(foundationFormControllerProvider.notifier).setText(fieldKey, v, error: err);
      },
    );
  }
}