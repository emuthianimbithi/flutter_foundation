import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as m;
import '../models/map_camera_position.dart';
import '../models/map_marker.dart';

class MapboxMapView extends StatefulWidget {
  final MapCameraPosition initialCamera;
  final List<MapMarker> markers;
  final ValueChanged<MapMarker>? onMarkerTap;

  const MapboxMapView({
    super.key,
    required this.initialCamera,
    this.markers = const [],
    this.onMarkerTap,
  });

  @override
  State<MapboxMapView> createState() => _MapboxMapViewState();
}

class _MapboxMapViewState extends State<MapboxMapView> {
  m.MapboxMap? _map;

  @override
  Widget build(BuildContext context) {
    return m.MapWidget(
      key: const ValueKey("mapbox_map"),
      cameraOptions: m.CameraOptions(
        center: m.Point(
          coordinates: m.Position(widget.initialCamera.target.longitude, widget.initialCamera.target.latitude),
        ),
        zoom: widget.initialCamera.zoom,
      ),
      onMapCreated: (map) => _map = map,
    );
  }
}