import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_maps_widget/google_maps_widget.dart';

class MapPage extends StatefulWidget {
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final mapsWidgetController = GlobalKey<GoogleMapsWidgetState>();

  @override
  Widget build(BuildContext context) {
    // Directly returning Scaffold instead of MaterialApp
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GoogleMapsWidget(
                apiKey: "AIzaSyAciMVouN2OmS1BnaDSvfU7n_f-9oe9ppU",
                key: mapsWidgetController,
                sourceLatLng: LatLng(
                  40.484000837597925,
                  -3.369978368282318,
                ),
                destinationLatLng: LatLng(
                  40.48017307700204,
                  -3.3618026599287987,
                ),
                // Other properties as previously defined...
                routeWidth: 2,
                sourceMarkerIconInfo: MarkerIconInfo(
                  infoWindowTitle: "This is source name",
                  onTapInfoWindow: (_) {
                    print("Tapped on source info window");
                  },
                  assetPath: "assets/images/house-marker-icon.png",
                ),
                // Continued implementation...
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        mapsWidgetController.currentState!.setSourceLatLng(
                          LatLng(
                            40.484000837597925 * (Random().nextDouble()),
                            -3.369978368282318,
                          ),
                        );
                      },
                      child: Text('Update source'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final googleMapsCon = await mapsWidgetController
                            .currentState!
                            .getGoogleMapsController();
                        googleMapsCon.showMarkerInfoWindow(
                            MarkerIconInfo.sourceMarkerId);
                      },
                      child: Text('Show source info'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
