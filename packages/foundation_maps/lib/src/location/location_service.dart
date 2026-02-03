import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> ensurePermissions() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  Future<Position?> currentPosition() async {
    final ok = await ensurePermissions();
    if (!ok) return null;
    return Geolocator.getCurrentPosition();
  }

  Stream<Position> positionStream({LocationSettings? settings}) {
    return Geolocator.getPositionStream(locationSettings: settings);
  }
}