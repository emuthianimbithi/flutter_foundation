import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/map_providers.dart';
import 'package:geolocator/geolocator.dart';

class LocationPermissionGate extends ConsumerWidget {
  final Widget child;

  const LocationPermissionGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(locationServiceProvider);

    return FutureBuilder(
      future: service.isLocationEnabled(),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return const Center(child: Text('Location services disabled'));
        }
        return FutureBuilder(
          future: Geolocator.checkPermission(),
          builder: (context, snap) {
            final perm = snap.data;
            if (perm == LocationPermission.denied ||
                perm == LocationPermission.deniedForever) {
              return Center(
                child: ElevatedButton(
                  onPressed: () => service.requestPermission(),
                  child: const Text('Enable location'),
                ),
              );
            }
            return child;
          },
        );
      },
    );
  }
}