import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/form_providers.dart';
import '../models/form_field_state.dart';

class DropdownField<T> extends ConsumerWidget {
  final String fieldKey;
  final String? label;
  final List<DropdownMenuItem<T>> items;
  final T? initialValue;

  const DropdownField({
    super.key,
    required this.fieldKey,
    this.label,
    required this.items,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(foundationFormControllerProvider);
    final current = form.field<T?>(fieldKey, initial: initialValue);

    return InputDecorator(
      decoration: InputDecoration(labelText: label, errorText: current.error),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: current.value,
          items: items,
          onChanged: (v) {
            ref
                .read(foundationFormControllerProvider.notifier)
                .state = form.setField<T?>(fieldKey, FoundationFormFieldState<T?>(value: v));
          },
        ),
      ),
    );
  }
}