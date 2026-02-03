import 'package:flutter/material.dart';
import 'package:foundation_ui/foundation_ui.dart';

class PhoneField extends StatelessWidget {
  final TextEditingController controller;

  const PhoneField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return FoundationTextField(
      controller: controller,
      label: 'Phone',
      keyboardType: TextInputType.phone,
    );
  }
}
