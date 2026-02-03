import 'latlng.dart';

class MapMarker {
  final String id;
  final LatLng position;
  final String? title;
  final String? snippet;

  const MapMarker({
    required this.id,
    required this.position,
    this.title,
    this.snippet,
  });
}
