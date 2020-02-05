import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'kalman.dart';

int currentMinor = 0;
String currentUUID = '';
String title = 'iBeacons Tester';

void main() => runApp(Beacons());
String beaconName;

class Beacons extends StatefulWidget {
  @override
  _BeaconsState createState() => _BeaconsState();
}

class _BeaconsState extends State<Beacons> {
  StreamSubscription<RangingResult> _streamRanging;
  final _regionBeacons = <Region, List<Beacon>>{};
  final _beacons = <Beacon>[];
  final _beaconsCollector = HashMap<String, KalmanFilter>();

  @override
  void initState() {
    super.initState();
    initBeacon();
    KalmanFilter filter = new KalmanFilter(1);
    filter.forgettingFactor = 0.5;
  }

  initBeacon() async {
    try {
      await flutterBeacon.initializeScanning;
      print('Beacon scanner initialized');
    } on PlatformException catch (e) {
      print(e);
    }

    final regions = <Region>[];

    if (Platform.isIOS) {
      regions.add(Region(
          identifier: 'com.aprilbrother.rfc1034identifier',
          proximityUUID: 'B5B182C7-EAB1-4988-AA99-B5C1517008D9'));
    } else {
      regions.add(Region(identifier: 'com.aprilbrother'));
    }

    _streamRanging = flutterBeacon.ranging(regions).listen((result) {
      if (result != null && mounted) {
        setState(() {
          _regionBeacons[result.region] = result.beacons;
          _beacons.clear();
          _regionBeacons.values.forEach((list) {
            _beacons.addAll(list);
          });
          _beacons.sort(_compareParameters);
        });
      }
    });
  }

  int _compareParameters(Beacon a, Beacon b) {
    int compare = a.proximityUUID.compareTo(b.proximityUUID);

    if (compare == 0) {
      compare = a.major.compareTo(b.major);
    }

    if (compare == 0) {
      compare = a.minor.compareTo(b.minor);
    }

    return compare;
  }

  @override
  void dispose() {
    if (_streamRanging != null) {
      _streamRanging.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(title),
        ),
        body: _beacons == null
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: ListTile.divideTiles(
                    context: context,
                    tiles: _beacons.map((beacon) {
                      if (!_beaconsCollector.containsKey(beacon.macAddress +
                          beacon.major.toString() +
                          beacon.minor.toString())) {
                        KalmanFilter filter = new KalmanFilter(1);
                        filter.forgettingFactor = 0.9;
                        _beaconsCollector.putIfAbsent(
                            beacon.macAddress +
                                beacon.major.toString() +
                                beacon.minor.toString(),
                            () => filter);
                      }
                      _beaconsCollector[beacon.macAddress +
                              beacon.major.toString() +
                              beacon.minor.toString()]
                          .addObservation(
                              1.0, beacon.accuracy, [beacon.accuracy]);
                      return ListTile(
                        title: Text(
                            beacon.proximityUUID +
                                "\t" +
                                " major : " +
                                beacon.major.toString() +
                                " minor : " +
                                beacon.minor.toString(),
                            style: TextStyle(fontSize: 10.0)),
                        subtitle: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Flexible(
                                child: Text(
                                    'Acc: ${beacon.accuracy}m, Kalman: ${_beaconsCollector[beacon.macAddress + beacon.major.toString() + beacon.minor.toString()].beta}\n',
                                    style: TextStyle(fontSize: 23.0)),
                                flex: 2,
                                fit: FlexFit.tight)
                          ],
                        ),
                      );
                    })).toList(),
              ),
      ),
    );
  }
}
