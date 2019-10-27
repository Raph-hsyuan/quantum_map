import 'package:flutter/material.dart';
import 'StaffMainPage.dart';
import 'VisitorMainPage.dart';

class ChooseStaffVisitor extends Dialog {
  @override
  Widget build(BuildContext context) {
    return new Padding(
        padding: const EdgeInsets.all(12.0),
        child: new Material(
            type: MaterialType.transparency,
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Container(
                      decoration: ShapeDecoration(
                          color: Color(0xFFFFFFFF),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                            Radius.circular(20.0),
                          ))),
                      margin: const EdgeInsets.all(12.0),
                      child: new Column(children: <Widget>[
                        new Padding(
                            padding: const EdgeInsets.fromLTRB(
                                10.0, 40.0, 10.0, 28.0),
                            child: Center(
                                child: new Text('QUI ETES VOUS ?',
                                    style: new TextStyle(
                                      fontFamily: 'Broadwell',
                                      fontSize: 20.0,
                                    )))),
                        new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _genderChooseItemWid(1, context),
                              _genderChooseItemWid(2, context)
                            ])
                      ]))
                ])));
  }

  Widget _genderChooseItemWid(var gender, var context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            gender == 1
                ? MaterialPageRoute(builder: (context) => VisitorMainPage())
                : MaterialPageRoute(builder: (context) => StaffMainPage()),
          );
        },
        child: Column(children: <Widget>[
          Image.asset(gender == 1 ? 'images/tourist.jpg' : 'images/guide.jpg',
              width: 135.0, height: 135.0),
          Padding(
              padding: EdgeInsets.fromLTRB(0.0, 22.0, 0.0, 40.0),
              child: Text(gender == 1 ? 'VISITEUR' : 'STAFF',
                  style: TextStyle(
                      fontFamily: 'Broadwell',
                      color: Color(gender == 1 ? 0xff4285f4 : 0xffff4444),
                      fontSize: 15.0)))
        ]));
  }
}
