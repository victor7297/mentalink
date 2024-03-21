// ignore_for_file: use_key_in_widget_constructors, sized_box_for_whitespace, prefer_const_constructors

import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84.0, // Aumentamos la altura para dar más espacio
      child: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.home),
                    onPressed: () {
                      Navigator.of(context).pushNamed("/PantallaInicio");
                    },
                  ),
                  Text(
                    'Inicio',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.event),
                    onPressed: () {
                      Navigator.of(context).pushNamed("/PantallaCitas");
                    },
                  ),
                  Text(
                    'Citas',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.account_box),
                    onPressed: () {
                      
                    },
                  ),
                  Text(
                    '...',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.person),
                    onPressed: () {
                    },
                  ),
                  Text(
                    'Perfil',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
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