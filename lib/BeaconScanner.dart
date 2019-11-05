import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';

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

  @override
  void initState() {
    super.initState();
    initBeacon();
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
          identifier: 'com.bluecats.BlueCats',
          proximityUUID: '61687109-905F-4436-91F8-E602F514C96D'));
    } else {
      regions.add(Region(identifier: 'com.beacon'));
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
                      return ListTile(
                        title: Text(
                            beacon.proximityUUID + beacon.minor.toString()),
                        subtitle: new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Flexible(
                                child: Text('Distance: ${beacon.accuracy}m\n',
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
