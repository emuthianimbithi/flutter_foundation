import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../location/location_service.dart';

enum MapProviderType { google, mapbox }

final mapProviderTypeProvider = StateProvider<MapProviderType>((ref) => MapProviderType.google);

final locationServiceProvider = Provider<LocationService>((ref) => LocationService());