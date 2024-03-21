// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print

import 'package:flutter/material.dart';

class footerMenu extends StatefulWidget {
  const footerMenu({super.key});

  @override
  State<footerMenu> createState() => _footerMenuState();
}

class _footerMenuState extends State<footerMenu> {

  int paginaActual = 0;

  @override
  Widget build(BuildContext context) {

    return BottomNavigationBar(
        currentIndex: paginaActual,
        //selectedItemColor: Colors.black,
        onTap: (value) {

          //print(value);

          setState(() {
            paginaActual = value;
          });

          switch (value) {

            
            case 0:
              print('Returned value $value');
            break;

            case 1:
              print('Returned value $value');
            break;

            case 2:
              print('Returned value $value');
            break;

            case 3:
              print('Returned value $value');
            break;

            default: print('Default case');
          }
          
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: ""),
        ],

      );
  }
}