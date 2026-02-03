import '../models/map_marker.dart';
import '../models/map_location.dart';

/// Provider-agnostic map interface.
///
/// Implement this using Google Maps, Mapbox, or any other map SDK.
abstract class MapService {
  Widget buildMap({
    required MapLocation center,
    required List<MapMarker> markers,
    required double zoom,
    void Function(MapLocation location)? onTap,
  });
}
