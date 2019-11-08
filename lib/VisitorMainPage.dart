import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quantum_map/VisitorMap.dart';

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

  static final CameraPosition _initialPos = CameraPosition(
    target: LatLng(43.6154734, 7.0718325),
    zoom: 10,
  );

  static final CameraPosition _classroom = CameraPosition(
      bearing: 229.8334901395799,
      target: LatLng(43.6154734, 7.0718325),
      tilt: 10.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition: _initialPos,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToSchool,
        label: Text('To O101!'),
        icon: Icon(Icons.school),
      ),
    );
  }

  Future<void> _goToSchool() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_classroom));
    await Future.delayed(const Duration(seconds: 3), () {});
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VisitorMap()),
    );
  }
}
