import 'latlng.dart';

class MapCameraPosition {
  final LatLng target;
  final double zoom;

  const MapCameraPosition({required this.target, this.zoom = 12});
}
