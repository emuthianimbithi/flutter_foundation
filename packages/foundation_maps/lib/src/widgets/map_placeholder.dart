import 'package:flutter/material.dart';
import 'package:foundation_ui/foundation_ui.dart';
import '../models/map_location.dart';
import '../models/map_marker.dart';

class MapPlaceholder extends StatelessWidget {
  final MapLocation center;
  final List<MapMarker> markers;

  const MapPlaceholder({super.key, required this.center, this.markers = const []});

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined, size: 48),
            const SizedBox(height: 8),
            Text('Map placeholder'),
            Text('Markers: ${markers.length}'),
          ],
        ),
      ),
    );
  }
}