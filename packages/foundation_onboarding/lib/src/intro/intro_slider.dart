import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_ui/foundation_ui.dart';
import '../providers/onboarding_providers.dart';

class IntroSlide {
  final IconData icon;
  final String title;
  final String description;

  const IntroSlide({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class IntroSlider extends ConsumerStatefulWidget {
  final List<IntroSlide> slides;
  final VoidCallback? onDone;

  const IntroSlider({super.key, required this.slides, this.onDone});

  @override
  ConsumerState<IntroSlider> createState() => _IntroSliderState();
}

class _IntroSliderState extends ConsumerState<IntroSlider> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final slide = widget.slides[index];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(slide.icon, size: 72),
            const SizedBox(height: 24),
            Text(slide.title, style: FoundationTheme.typeOf(context).h2),
            const SizedBox(height: 12),
            Text(slide.description, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (index > 0)
                  FoundationButton(
                    label: 'Back',
                    variant: FoundationButtonVariant.subtle,
                    onPressed: () => setState(() => index--),
                  ),
                FoundationButton(
                  label: index == widget.slides.length - 1
                      ? 'Get Started'
                      : 'Next',
                  onPressed: () {
                    if (index == widget.slides.length - 1) {
                      ref.read(onboardingCompletedProvider.notifier).state =
                          true;
                      widget.onDone?.call();
                    } else {
                      setState(() => index++);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
