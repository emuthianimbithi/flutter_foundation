import 'package:flutter/material.dart';
import 'package:foundation_ui/foundation_ui.dart';

class DateField extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const DateField({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return FoundationTextField(
      label: 'Date',
      controller: TextEditingController(text: value?.toIso8601String() ?? ''),
      onChanged: (_) async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          initialDate: value ?? DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}