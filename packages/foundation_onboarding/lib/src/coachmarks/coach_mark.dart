import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_providers.dart';

class CoachMark extends ConsumerWidget {
  final String id;
  final Widget child;
  final String message;

  const CoachMark({
    super.key,
    required this.id,
    required this.child,
    required this.message,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seen = ref.watch(seenCoachMarksProvider);
    if (seen.contains(id)) return child;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              ref.read(seenCoachMarksProvider.notifier).state = {...seen, id};
            },
            child: Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Material(
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(message, textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}