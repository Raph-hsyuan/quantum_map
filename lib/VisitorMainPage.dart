import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VisitorMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: GoogleMapSimple(),
    );
  }
}

class GoogleMapSimple extends StatefulWidget {
  @override
  State<GoogleMapSimple> createState() => GoogleMapSimpleState();
}

class GoogleMapSimpleState extends State<GoogleMapSimple> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _Nice = CameraPosition(
    target: LatLng(43.6915029, 7.294096),
    zoom: 13,
  );

  static final CameraPosition _beachNice = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(43.6941192, 7.2786143),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _Nice,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToBeachNice,
        label: Text('To Beach!'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToBeachNice() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_beachNice));
  }
}
