// ignore_for_file: unnecessary_this, prefer_const_constructors, camel_case_types

import 'package:flutter/material.dart';

class appbar {

  String id;
  String rutaImagenPerfil;

  // Constructor
  appbar(this.id, this.rutaImagenPerfil);

  // Setters
  setId(String id) {
    this.id = id;
  }

  setRutaImagenPerfil(String rutaImagenPerfil) {
    this.rutaImagenPerfil = rutaImagenPerfil;
  }

  AppBar getAppbar(BuildContext context) {
    return AppBar(
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.network(
              "https://mentalink.org/assets/images/Logo_Mentalink.png",
              width: 150,
              height: 155,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/perfil');
              },
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
                child: ClipOval(
                  child: rutaImagenPerfil.isNotEmpty
                      ? Image.network(
                          // ignore: prefer_interpolation_to_compose_strings
                          "https://mentalink.org/api-mentalink-prueba-v/public/" + this.rutaImagenPerfil,
                          fit: BoxFit.cover,
                        )
                      : Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      toolbarHeight: 65,
      backgroundColor: Color.fromRGBO(9, 25, 87, 1.0),
      foregroundColor: Colors.white,
    );
  }
}
