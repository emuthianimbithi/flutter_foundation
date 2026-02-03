import 'package:flutter/material.dart';
import 'package:foundation_ui/foundation_ui.dart';

class ImagePickerView extends StatelessWidget {
  final VoidCallback onPick;

  const ImagePickerView({super.key, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return FoundationButton(
      label: 'Pick Image',
      icon: Icons.image,
      onPressed: onPick,
      variant: FoundationButtonVariant.secondary,
    );
  }
}
