import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StaffMainPage extends StatelessWidget {
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
      body: new Stack(children: <Widget>[
        GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: _Nice,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
        Positioned(
            top: 350,
            left: 90,
            right: 90,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.lightBlue,
              icon: Icon(Icons.arrow_forward_ios),
              label: new Text("Deployment",
                  style: new TextStyle(fontFamily: 'Broadwell')),
              onPressed: () {
                _startDepolyment();
              },
            )),
        Positioned(
            top: 250,
            left: 40,
            right: 40,
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Input Your Project ID',
                border: OutlineInputBorder(),
              ),
            )),
      ]),
    );
//      GoogleMap(
//        mapType: MapType.hybrid,
//        initialCameraPosition: _Nice,
//        onMapCreated: (GoogleMapController controller) {
//          _controller.complete(controller);
//        },
//      ),
//      floatingActionButton: FloatingActionButton.extended(
//        onPressed: _startDepolyment,
//        label: Text('Déploiement'),
//        icon: Icon(Icons.golf_course),
//      ),
//      bottomNavigationBar: TextField(
//        obscureText: true,
//        decoration: InputDecoration(
//          border: OutlineInputBorder(),
//          labelText: 'Password',
//        ),
//      ),
  }

  Future<void> _startDepolyment() async {}
}
