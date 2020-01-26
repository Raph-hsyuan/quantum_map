import 'dart:ui';

import 'package:flutter/material.dart';

class PositionBeaconLadar extends StatelessWidget {
  static const String my_title = 'Beacon ladar';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: my_title, home: MyPositionBeaconLadar());
  }
}

class MyPositionBeaconLadar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(title: Text('Beacon Ladar')),
        body: Center(
            child: new CustomPaint(
              size: new Size(15, 15),
              painter: new MyPainter(),
            )
        ));
  }
}

class MyPainter extends CustomPainter {
  List<Offset> points = new List();

  Paint _paint = Paint()
    ..color = Colors.lightBlue
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true
    ..strokeWidth = 15.0;

  Paint _paintCenter = Paint()
    ..color = Colors.amber
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true
    ..strokeWidth = 15.0;


  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(new Offset(0, 0), 15, _paintCenter);
    points.add(new Offset(10, 200));
    points.add(new Offset(0, 150));
    points.add(new Offset(-75, 0));
    points.add(new Offset(-5, -100));
    points.add(new Offset(50, 200));
    canvas.drawPoints(PointMode.points, points, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return null;
  }

}

