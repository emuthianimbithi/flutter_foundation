import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/form_providers.dart';

class FoundationForm extends ConsumerWidget {
  final Widget Function(BuildContext context, WidgetRef ref) builder;
  const FoundationForm({super.key, required this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Touch the form controller so it exists in subtree.
    ref.watch(foundationFormControllerProvider);
    return builder(context, ref);
  }
}