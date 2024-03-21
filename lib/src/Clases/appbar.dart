// ignore_for_file: camel_case_types, avoid_unnecessary_containers, prefer_const_constructors

import 'package:flutter/material.dart';

class appbar{
  
  PreferredSizeWidget? appbarPrincipal = AppBar(
    
    title: Container(

      child: Row(

        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [

          Container(
            child: Image.asset(
              'logo-text.png',
              width: 150,
              height: 150,
            ),
          ),

          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(50), // Radio de 50 para lograr la forma redonda
              image: DecorationImage(image: AssetImage('ImagenPerfil.png'),fit: BoxFit.cover),
            ),
          )
        ],
      ),
    ),
    toolbarHeight: 65, // Reemplaza con la altura deseada
    backgroundColor: Colors.white,
    foregroundColor: Color.fromRGBO(10, 28, 92, 1)
  );

  getAppbar(){

    return appbarPrincipal;
  }
}