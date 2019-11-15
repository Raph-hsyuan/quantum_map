import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'dart:async';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:ovprogresshud/progresshud.dart';

// ignore: implementation_imports
import 'package:simple_cluster/src/dbscan.dart';

class Line {
  Offset p1;
  Offset p2;

  Line(Offset p1, Offset p2) {
    this.p1 = p1;
    this.p2 = p2;
  }
}

class Position {
  int top;
  int left;
  int recordPoint = 0;

  Position(int top, int left) {
    this.top = top;
    this.left = left;
  }
}

class StaffMap extends StatefulWidget {
  @override
  _StaffMapState createState() => new _StaffMapState();
}

class _StaffMapState extends State<StaffMap>
    with SingleTickerProviderStateMixin {
  //AnimationController controller;
  final lines = <Line>[];
  final points = <Offset>[];
  final positions = <Position>[];
  bool checkingState = false;
  String region = 'O+101';
  Offset current = Offset(-100, -100);
  StreamSubscription<RangingResult> _streamRanging;
  final _regionBeacons = <Region, List<Beacon>>{};
  final _regionBeaconsPos = <Region, List<Beacon>>{};

  final _beacons = <Beacon>[];
  final _beaconsPos = <Beacon>[];

  final _beaconsCollector = HashMap<String, double>();
  final _beaconsCollectorPos = HashMap<String, double>();

  final _beaconsList = <String>[];
  bool logging = false;
  bool positioning = false;

  _StaffMapState();

  StreamSubscription<double> _streamDoubleRanging;
  double pi = 3.1415926;
  String currentBeaconID = '';
  Position currentPosition = new Position(-1, -1);
  final _totalProjectBeacons = new HashMap<Position, List<String>>();
  final _totalMapDouble = new HashMap<Position, List<List<double>>>();
  final _totalProjectBeaconsDouble = new List<List<double>>();
  double epsilon = 50;
  DBSCAN dbscan = new DBSCAN(
    epsilon: 50,
    minPoints: 3,
  );

  @override
  void initState() {
    super.initState();
    initMap();
    initBeacon();
    positions.add(new Position(0, 0));
    positions.add(new Position(0, 100));
    positions.add(new Position(0, 200));
    positions.add(new Position(80, 0));
    positions.add(new Position(80, 100));
    positions.add(new Position(80, 200));
    positions.add(new Position(160, 0));
    positions.add(new Position(160, 100));
    positions.add(new Position(160, 200));
    positions.add(new Position(240, 200));
    _beaconsList.add("E4:F5:46:61:6F:7A131343");
    _beaconsList.add("C3:A7:10:53:3F:BB147935");
    _beaconsList.add("D0:5F:5B:74:8E:B21256");
    _beaconsList.add("D2:2A:96:01:1A:C1149434");
    _beaconsList.add("F1:80:31:49:9A:5E124218");
  }

  updatePosition() async {}

  initMap() async {
    lines.add(Line(Offset(0.0, 0.0), Offset(290.0, 0)));
    lines.add(Line(Offset(290.0, 0.0), Offset(290.0, 330.0)));
    lines.add(Line(Offset(290.0, 330.0), Offset(180.0, 330.0)));
    lines.add(Line(Offset(180.0, 320.0), Offset(180.0, 330.0)));
    lines.add(Line(Offset(290.0, 230.0), Offset(180.0, 230.0)));
    lines.add(Line(Offset(180.0, 220.0), Offset(180.0, 260.0)));

    lines.add(Line(Offset(0.0, 0.0), Offset(0.0, 230.0)));
    lines.add(Line(Offset(0.0, 230.0), Offset(130.0, 230.0)));
    lines.add(Line(Offset(130.0, 220.0), Offset(130.0, 330.0)));
  }

  @override
  void dispose() {
    if (_streamRanging != null) {
      _streamRanging.cancel();
    }
    if (_streamDoubleRanging != null) {
      _streamDoubleRanging.cancel();
    }
    super.dispose();
  }

  Future<File> _getLocalFile() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    return new File('$dir/points.txt');
  }

  void saveFingerprintToFiles() async {
    String fg = "";
    String success = "";
    int i = 1;
    bool first = true;
    List<double> doubleList = new List<double>();
    _beaconsList.forEach((key) {
      print("8888888888888888888" + key);
      if (_beaconsCollector[key] != null) {
        fg += (first ? "" : ",") + _beaconsCollector[key].toStringAsFixed(2);
        doubleList.add(_beaconsCollector[key]);
        first = false;
        success += "Signal #" +
            (i++).toString() +
            " : " +
            _beaconsCollector[key].toStringAsFixed(2) +
            " mm\n";
      }
    });
//    _totalProjectBeaconsDouble.add(doubleList);
    fg += '\n';
    await (await _getLocalFile()).writeAsString(fg);
    print(fg);
    if (_totalProjectBeacons[currentPosition] == null) {
      _totalProjectBeacons[currentPosition] = new List<String>();
    }
    if (_totalMapDouble[currentPosition] == null) {
      _totalMapDouble[currentPosition] = new List<List<double>>();
    }
    _totalMapDouble[currentPosition].add(doubleList);
    _totalProjectBeacons[currentPosition].add(fg);
    Progresshud.dismiss();
    Progresshud.showSuccessWithStatus("Terminé avec succès\n\n\n" + success);
    setState(() {
      currentPosition.recordPoint = currentPosition.recordPoint + 1;
    });
    _beaconsCollector.clear();
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
      if (logging) {
        if (result != null && mounted) {
          _regionBeacons[result.region] = result.beacons;
          _beacons.clear();
          _regionBeacons.values.forEach((list) {
            _beacons.addAll(list);
          });
          _beacons.sort(_compareParameters);
          _beacons.forEach((beacon) {
            if (beacon.accuracy > 0) {
              String mac = "";
              if(beacon.minor == 31343){
                mac = "E4:F5:46:61:6F:7A131343";
              }
              if(beacon.minor == 47935){
                mac = "C3:A7:10:53:3F:BB147935";
              }
              if(beacon.minor == 256){
                mac = "D0:5F:5B:74:8E:B21256";
              }
              if(beacon.minor == 49434){
                mac = "D2:2A:96:01:1A:C1149434";
              }
              if(beacon.minor == 24218){
                mac = "F1:80:31:49:9A:5E124218";
              }
              _beaconsCollector[mac] = beacon.accuracy * 100;
            }
          });
          if (_beaconsCollector.length == 5) {
            saveFingerprintToFiles();
            setState(() {
              logging = false;
            });
          }
        }
      }
      if (positioning) {
        if (result != null && mounted) {
          _regionBeaconsPos[result.region] = result.beacons;
          _beaconsPos.clear();
          _regionBeaconsPos.values.forEach((list) {
            _beaconsPos.addAll(list);
          });
          _beaconsPos.sort(_compareParameters);
          _beaconsPos.forEach((beacon) {
            if (beacon.accuracy > 0) {
              String mac = "";
              if(beacon.minor == 31343){
                mac = "E4:F5:46:61:6F:7A131343";
              }
              if(beacon.minor == 47935){
                mac = "C3:A7:10:53:3F:BB147935";
              }
              if(beacon.minor == 256){
                mac = "CD0:5F:5B:74:8E:B21256";
              }
              if(beacon.minor == 49434){
                mac = "D2:2A:96:01:1A:C1149434";
              }
              if(beacon.minor == 24218){
                mac = "F1:80:31:49:9A:5E124218";
              }
              _beaconsCollectorPos[mac] = beacon.accuracy * 100;
            }
          });
          if (_beaconsCollectorPos.length == 5) {
            Position where = locating();
            if (where.top == -404) {
              positioning = false;
              Progresshud.dismiss();
              Progresshud.showErrorWithStatus("Pas réussi");
            } else {
              Progresshud.dismiss();
              Progresshud.showSuccessWithStatus("Terminé avec succès");
              setState(() {
                points.clear();
                points.add(new Offset(
                    where.left.toDouble() + 50, where.top.toDouble() + 40));
                positioning = false;
              });
            }
          }
        }
      }
    });
  }

  Position locating() {
    List<List<double>> pos = new List<List<double>>();
    pos.addAll(_totalProjectBeaconsDouble);
    List<double> doubleList = new List<double>();
    _beaconsList.forEach((key) {
      doubleList.add(_beaconsCollectorPos[key]);
    });
    pos.add(doubleList);
    dbscan.run(pos);
    int area = dbscan.label[dbscan.label.length - 1];
    if (area == -1) {
      return new Position(-404, -404);
    }
    int mark = -404;
    for (int i = 0; i < dbscan.label.length; i++) {
      if (dbscan.label[i] == area) {
        mark = i;
        break;
      }
    }
    if (mark == -404) {
      return new Position(-404, -404);
    }
    for (Position key in _totalMapDouble.keys) {
      mark -= _totalMapDouble[key].length;
      if (mark <= 0) {
        return key;
      }
    }
    return new Position(-404, -404);
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
  Widget build(BuildContext context) {
    return new Scaffold(
        //appBar: new AppBar(title: new Text(region)),
        body: new Builder(
            builder: (context) => new GestureDetector(
                child: new Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('images/mapBg.jpg'),
                            fit: BoxFit.fill)),
                    child: new Stack(children: <Widget>[
                      Positioned(
                          top: 190,
                          right: 25,
                          child: FloatingActionButton.extended(
                            backgroundColor: Colors.brown[600],
                            icon: Icon(Icons.check),
                            label: new Text("Terminer",
                                style: new TextStyle(fontFamily: 'Broadwell')),
                            onPressed: () {
                              _showConfirmDialog();
                            },
                          )),
                      Positioned(
                          top: 190,
                          left: 25,
                          child: IconButton(
                            icon: Icon(Icons.my_location),
                            iconSize: 40,
                            color: Colors.brown[600],
                            onPressed: () {
                              getLocation();
                            },
                          )),
                      Positioned(
                          top: 250,
                          left: 35,
                          right: 35,
                          child: new Stack(
                            children: getMapContent(context),
                          )),
                      Positioned(
                          top: 130,
                          left: 35,
                          child: new Text(
                            region,
                            style: new TextStyle(
                                fontSize: 21.0,
                                color: Colors.grey[350],
                                fontFamily: 'Broadwell'),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                            textAlign: TextAlign.left,
                          )),
                      Positioned(
                          top: 60,
                          left: 35,
                          right: 35,
                          child: new Text(
                            'Ubiquarium',
                            style: new TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 41.0,
                                color: Colors.grey[350],
                                fontFamily: 'Broadwell'),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.left,
                          )),
                      Positioned(
                        top: 580,
                        left: 10,
                        right: 10,
                        child: Slider(
                          min: 0,
                          max: 300,
                          activeColor: Colors.brown,
                          inactiveColor: Colors.black,
                          value: epsilon,
                          onChanged: (newValue) {
                            setState(() {
                              dbscan = new DBSCAN(
                                epsilon: newValue,
                                minPoints: 3,
                              );
                              epsilon = newValue;
                            });
                          },
                          onChangeStart: (startValue) {
                            print('onChangeStart:$startValue');
                          },
                          onChangeEnd: (endValue) {
                            print('onChangeEnd:$endValue');
                          },
                          label: 'epsilon=$epsilon',
                          divisions: 300,
                          semanticFormatterCallback: (newValue) {
                            return 'epsilon=${newValue.round()}';
                          },
                        ),
                      ),
                    ])))));
  }

  void _showConfirmDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text(
                'Vos données seront envoyées au serveur pour la formation'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Annuler')),
              FlatButton(
                onPressed: () {
                  print(_totalProjectBeacons.values
                      .reduce((f, v) => f + v)
                      .reduce((a, b) => a + b));
                  _totalProjectBeaconsDouble.clear();
                  for (Position key in _totalMapDouble.keys) {
                    _totalProjectBeaconsDouble.addAll(_totalMapDouble[key]);
                  }
                  dbscan.run(_totalProjectBeaconsDouble);
                  print('result:' + dbscan.label.toString());
                  Navigator.pop(context);
                  Progresshud.showSuccessWithStatus(
                      'result:' + dbscan.label.toString());
                },
                child: Text('Valider'),
              )
            ],
          );
        });
  }

  List<Widget> getMapContent(BuildContext context) {
    List<Widget> children = [];
    children.add(Image.asset('images/classroom.png'));
    positions.forEach((p) {
      bool enough = false;
      if (_totalMapDouble[p] != null) {
        dbscan.run(_totalMapDouble[p]);
        for (int data in dbscan.label) {
          if (data == 0) {
            enough = true;
            break;
          }
        }
      }
      children.add(new Positioned(
          top: p.top.toDouble(),
          left: p.left.toDouble(),
          child: Opacity(
            opacity: enough ? 1 : 0.4,
            child: new SizedBox(
              width: 90.0,
              height: 70.0,
              child: RaisedButton(
                child: Text(
                    "Nombre : " +
                        (enough
                            ? (p.recordPoint.toString() +
                                "\nSuffisant\n" +
                                dbscan.label.toString())
                            : (p.recordPoint.toString() + "\nInsuffisant\n")),
                    style: TextStyle(fontSize: 11)),
                color: enough ? Colors.green : Colors.white,
                onPressed: () {
                  setState(() {
                    logging = true;
                    currentPosition = p;
                  }); // Add your onPressed code here!
                  Progresshud.setDefaultMaskTypeGradient();
                  Progresshud.showWithStatus('Détecter les signaux...');
                },
              ),
            ),
          )));
    });
    children.add(new CustomPaint(
        willChange: true,
        child: new Container(),
        foregroundPainter: new MapPainter(lines, points)));
    return children;
  }

  void getLocation() async {
    if (_totalMapDouble.length < 2) {
      Progresshud.showErrorWithStatus("Positionnement Non Disponible !");
      return;
    }
    setState(() {
      positioning = true;
    });
    Progresshud.setDefaultMaskTypeGradient();
    Progresshud.showWithStatus('Positionnement ...');
  }
}

class MapPainter extends CustomPainter {
  final lines;
  final points;

  MapPainter(this.lines, this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.black
      ..maskFilter = MaskFilter.blur(BlurStyle.inner, 0.5);
    for (Line line in lines) canvas.drawLine(line.p1, line.p2, paint);
    for (Offset point in points) canvas.drawCircle(point, 10, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
