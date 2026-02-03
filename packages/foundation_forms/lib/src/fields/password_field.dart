import 'package:flutter/material.dart';
import 'package:foundation_ui/foundation_ui.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return FoundationTextField(
      controller: controller,
      label: 'Password',
      obscureText: true,
    );
  }
}
