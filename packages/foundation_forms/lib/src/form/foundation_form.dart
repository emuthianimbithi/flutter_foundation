import 'package:flutter/material.dart';

class FoundationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Widget child;

  const FoundationForm({super.key, required this.formKey, required this.child});

  bool validate() => formKey.currentState?.validate() ?? false;
  void save() => formKey.currentState?.save();

  @override
  Widget build(BuildContext context) {
    return Form(key: formKey, child: child);
  }
}