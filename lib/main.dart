// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:mentalink/src/Inicio.dart';
import 'package:mentalink/src/Views/Login/Login.dart';
import 'package:mentalink/src/Views/Login/RecuperarContrasenaCodigo.dart';
import 'package:mentalink/src/Views/Registro/FinalizarRegistro.dart';
import 'package:mentalink/src/Views/Registro/RegistroParte1.dart';
import 'package:mentalink/src/Views/Usuarios/Psicologos/agendarCita.dart';
import 'package:mentalink/src/Views/Usuarios/Psicologos/menu.dart';
import 'package:mentalink/src/Views/Usuarios/Home/Home.dart';
import 'package:mentalink/src/Views/Usuarios/Preguntas.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale("es"),
      debugShowCheckedModeBanner: false,//quita la bandera debug de la app
      title: "Mentalink",
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        
      ],
      supportedLocales: [
        Locale("es"),
      ],
      routes: {
        "/": (BuildContext context) => Inicio(),
        "/RegistroParte1": (BuildContext context) => RegistroParte1(),
        '/FinalizarRegistro': (BuildContext context) {
          final Map<String, String> args =
              ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return FinalizarRegistro(
            nombre: args['nombre']!,
            apellido: args['apellido']!,
            correo: args['correo']!,
            contrasena: args['contrasena']!,
          );
        },
        "/login": (BuildContext context) => Login(),
        "/RecuperarContrasena": (BuildContext context) => RecuperarContrasena(),
        "/RecuperarContrasenaCodigo": (BuildContext context) => RecuperarContrasenaCodigo(),
        "/Home": (BuildContext context) => Home(),
        "/menuEspecialistas": (BuildContext context) => menu(),
        "/agendarCita": (BuildContext context) => angendarCita(),
      },
    );
  }
}
