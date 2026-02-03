import 'package:flutter/material.dart';
import 'package:foundation_ui/foundation_ui.dart';
import 'package:foundation_maps/foundation_maps.dart';

class MapsScreen extends StatelessWidget {
  const MapsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = FoundationTheme.tokensOf(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Maps')),
      body: Padding(
        padding: EdgeInsets.all(tokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Note: real maps require API key setup.'),
            SizedBox(height: tokens.space12),
            const Expanded(
              child: FoundationCard(
                child: FoundationMap(
                  initialCamera: MapCameraPosition(target: LatLng(-1.286389, 36.817223), zoom: 12),
                  markers: [
                    MapMarker(id: '1', position: LatLng(-1.286389, 36.817223), title: 'Nairobi'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
