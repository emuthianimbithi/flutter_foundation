import 'package:flutter/material.dart';
import 'package:foundation_ui/foundation_ui.dart';
import '../validators/validators.dart';

class EmailField extends StatelessWidget {
  final TextEditingController controller;

  const EmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return FoundationTextField(
      controller: controller,
      label: 'Email',
      keyboardType: TextInputType.emailAddress,
      onChanged: (_) {},
    );
  }
}