import 'package:flutter/material.dart';
import 'package:foundation_ui/foundation_ui.dart';
import 'network_image_view.dart';

class ImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageGallery(
      {super.key, required this.imageUrls, this.initialIndex = 0});

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.imageUrls.length - 1);
    _controller = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    return Scaffold(
      appBar: AppBar(
          title: Text('Gallery ${_index + 1}/${widget.imageUrls.length}')),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.imageUrls.length,
        onPageChanged: (i) => setState(() => _index = i),
        itemBuilder: (context, i) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(tokens.space16),
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 4,
                child: NetworkImageView(
                    url: widget.imageUrls[i], fit: BoxFit.contain),
              ),
            ),
          );
        },
      ),
    );
  }
}
