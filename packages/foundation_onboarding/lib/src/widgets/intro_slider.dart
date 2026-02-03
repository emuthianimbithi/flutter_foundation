import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation_ui/foundation_ui.dart';
import '../models/intro_page_model.dart';
import '../providers/onboarding_providers.dart';

class IntroSlider extends ConsumerStatefulWidget {
  final List<IntroPageModel> pages;
  final VoidCallback? onDone;

  const IntroSlider({super.key, required this.pages, this.onDone});

  @override
  ConsumerState<IntroSlider> createState() => _IntroSliderState();
}

class _IntroSliderState extends ConsumerState<IntroSlider> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    final t = FoundationTheme.typeOf(context);

    final isLast = _index == widget.pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(tokens.space24),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: widget.pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final p = widget.pages[i];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(p.icon, size: 72),
                        SizedBox(height: tokens.space24),
                        Text(p.title, style: t.h2, textAlign: TextAlign.center),
                        SizedBox(height: tokens.space12),
                        Text(p.description, style: t.body, textAlign: TextAlign.center),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: FoundationButton(
                      label: isLast ? 'Done' : 'Next',
                      onPressed: () {
                        if (isLast) {
                          ref.read(hasCompletedOnboardingProvider.notifier).state = true;
                          widget.onDone?.call();
                          return;
                        }
                        _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: tokens.space12),
              Text('${_index + 1}/${widget.pages.length}', style: t.caption),
            ],
          ),
        ),
      ),
    );
  }
}