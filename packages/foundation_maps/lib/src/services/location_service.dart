import 'package:geolocator/geolocator.dart';
import '../models/map_location.dart';

class LocationService {
  Future<bool> isLocationEnabled() => Geolocator.isLocationServiceEnabled();

  Future<LocationPermission> requestPermission() => Geolocator.requestPermission();

  Future<MapLocation> getCurrentLocation() async {
    final pos = await Geolocator.getCurrentPosition();
    return MapLocation(latitude: pos.latitude, longitude: pos.longitude);
  }
}