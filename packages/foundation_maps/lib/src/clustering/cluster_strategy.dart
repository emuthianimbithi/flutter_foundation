import '../models/map_marker.dart';

abstract class ClusterStrategy {
  /// Given a list of markers, return a potentially reduced list to render.
  /// Implementations can group markers by proximity for the current zoom.
  List<MapMarker> cluster(List<MapMarker> markers, {required double zoom});
}