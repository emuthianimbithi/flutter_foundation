import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as g;
import '../models/map_camera_position.dart';
import '../models/map_marker.dart';

class GoogleMapView extends StatelessWidget {
  final MapCameraPosition initialCamera;
  final List<MapMarker> markers;
  final ValueChanged<MapMarker>? onMarkerTap;

  const GoogleMapView({
    super.key,
    required this.initialCamera,
    this.markers = const [],
    this.onMarkerTap,
  });

  @override
  Widget build(BuildContext context) {
    final gMarkers = markers
        .map(
          (m) => g.Marker(
            markerId: g.MarkerId(m.id),
            position: g.LatLng(m.position.latitude, m.position.longitude),
            infoWindow: g.InfoWindow(title: m.title, snippet: m.snippet),
            onTap: () => onMarkerTap?.call(m),
          ),
        )
        .toSet();

    return g.GoogleMap(
      initialCameraPosition: g.CameraPosition(
        target: g.LatLng(initialCamera.target.latitude, initialCamera.target.longitude),
        zoom: initialCamera.zoom,
      ),
      markers: gMarkers,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
    );
  }
}