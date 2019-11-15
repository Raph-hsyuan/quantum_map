import 'package:flutter/material.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter_compass/flutter_compass.dart';

class Line {
  Offset p1;
  Offset p2;

  Line(Offset p1, Offset p2) {
    this.p1 = p1;
    this.p2 = p2;
  }
}

class VisitorMap extends StatefulWidget {
  @override
  _VisitorMapState createState() => new _VisitorMapState();
}

class _VisitorMapState extends State<VisitorMap>
    with SingleTickerProviderStateMixin {
  //AnimationController controller;
  final lines = <Line>[];
  final points = <Offset>[];
  bool checkingState = false;
  String region = 'O+101';
  Offset current = Offset(-100, -100);

  _VisitorMapState();

  StreamSubscription<RangingResult> _streamRanging;
  StreamSubscription<double> _streamDoubleRanging;
  double _direction;
  double pi = 3.1415926;
  double shaking = 0.2;
  bool shakeState = false;
  int shakeStopCount = 0;
  String currentBeaconID = '';

  @override
  void initState() {
    super.initState();
    initMap();
    _streamDoubleRanging = FlutterCompass.events.listen((double direction) {
      setState(() {
        _direction = direction;
      });
    });
  }

  updatePosition() async {}

  initMap() async {
    lines.add(Line(Offset(0.0, 0.0), Offset(320.0, 0)));
    lines.add(Line(Offset(320.0, 0.0), Offset(320.0, 365.0)));
    lines.add(Line(Offset(320.0, 365.0), Offset(200.0, 365.0)));
    lines.add(Line(Offset(200.0, 345.0), Offset(200.0, 365.0)));
    lines.add(Line(Offset(320.0, 250.0), Offset(200.0, 250.0)));
    lines.add(Line(Offset(200.0, 240.0), Offset(200.0, 260.0)));

    lines.add(Line(Offset(0.0, 0.0), Offset(0.0, 250.0)));
    lines.add(Line(Offset(0.0, 250.0), Offset(150.0, 250.0)));
    lines.add(Line(Offset(150.0, 240.0), Offset(150.0, 360.0)));
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
                          right: 35,
                          child: FloatingActionButton.extended(
                            backgroundColor: Colors.brown[600],
                            icon: Icon(Icons.my_location),
                            label: new Text("Location",
                                style: new TextStyle(fontFamily: 'Broadwell')),
                            onPressed: () {},
                          )),
                      Positioned(
                          top: 250,
                          left: 35,
                          right: 35,
                          child: new Stack(
                            children: <Widget>[
                              Image.asset('images/classroom.png'),
                              CustomPaint(
                                  willChange: true,
                                  child: new Container(),
                                  foregroundPainter:
                                      new MapPainter(lines, points)),
                            ],
                          )),
                      Positioned(
                          top: 180,
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
                          top: 100,
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
                    ])))));
  }

  void showAlertDialog(BuildContext context, String message) {
    NavigatorState navigator =
        context.rootAncestorStateOfType(const TypeMatcher<NavigatorState>());
    debugPrint("navigator is null?" + (navigator == null).toString());
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              shape: new RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
              title: new Text("UNE ERREUR",
                  style:
                      new TextStyle(fontSize: 20.0, fontFamily: 'Broadwell')),
              content: new Text(message,
                  style:
                      new TextStyle(fontSize: 16.0, fontFamily: 'Broadwell')),
            ));
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
