import 'package:flutter/material.dart';

class FoundationToast {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final cs = Theme.of(context).colorScheme;
    final bg = isError ? cs.errorContainer : cs.inverseSurface;
    final fg = isError ? cs.onErrorContainer : cs.onInverseSurface;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: fg)),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}