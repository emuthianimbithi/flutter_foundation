import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/map_camera_position.dart';
import '../models/map_marker.dart';
import '../providers/maps_providers.dart';
import '../google_maps/google_map_view.dart';
import '../mapbox/mapbox_map_view.dart';

class FoundationMap extends ConsumerWidget {
  final MapCameraPosition initialCamera;
  final List<MapMarker> markers;
  final ValueChanged<MapMarker>? onMarkerTap;

  const FoundationMap({
    super.key,
    required this.initialCamera,
    this.markers = const [],
    this.onMarkerTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(mapProviderTypeProvider);
    switch (provider) {
      case MapProviderType.google:
        return GoogleMapView(
          initialCamera: initialCamera,
          markers: markers,
          onMarkerTap: onMarkerTap,
        );
      case MapProviderType.mapbox:
        return MapboxMapView(
          initialCamera: initialCamera,
          markers: markers,
          onMarkerTap: onMarkerTap,
        );
    }
  }
}