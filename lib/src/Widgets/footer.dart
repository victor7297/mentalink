// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Footer extends StatelessWidget {
  Future<String?> _getUserType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('tipo_usuario');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.0,
      child: BottomAppBar(
        color: Color.fromRGBO(9, 25, 87, 1.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.home, size: 25, color: Colors.white),
                    onPressed: () async {
                      Navigator.of(context).pushNamed("/Home");
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.calendar_month_sharp, size: 25, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pushNamed("/citas");
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit_note_rounded, size: 25, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pushNamed("/testEvaluativo");
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.account_circle_outlined, size: 25, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pushNamed("/perfil");
                    },
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
