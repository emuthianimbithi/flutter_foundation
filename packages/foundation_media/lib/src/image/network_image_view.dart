import 'package:flutter/material.dart';
import 'package:foundation_ui/foundation_ui.dart';

class NetworkImageView extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;

  const NetworkImageView({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
    );
  }
}
