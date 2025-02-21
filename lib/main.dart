// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mentalink/src/Views/ActualizarPassword/actualizarPassword.dart';
import 'package:mentalink/src/Views/CitasPsicologo/CitasPsicologo.dart';
import 'package:mentalink/src/Views/Psicologos/testEvaluativo.dart';
import 'package:mentalink/src/Views/Registro/RegistroGoogle.dart';
import 'package:mentalink/src/Views/Registro/VerificarCorreo.dart';
import 'package:mentalink/src/Views/TestAnsiedad/TestAnsiedad.dart';
import 'package:mentalink/src/Views/TestAsertividad/TestAsertividad.dart';
import 'package:mentalink/src/Views/TestBDI/TestBDI.dart';
import 'package:mentalink/src/Views/TestCooper/TestCooper.dart';
import 'package:mentalink/src/Views/TestDesesperanza/TestDesesperanza.dart';
import 'package:mentalink/src/Views/TestLaboral/TestLaboral.dart';
import 'package:mentalink/src/Widgets/PruebaMeet.dart';
import 'package:mentalink/src/Inicio.dart';
import 'package:mentalink/src/Views/Citas/Citas.dart';
import 'package:mentalink/src/Views/DetallesCuenta/DetallesCuenta.dart';
import 'package:mentalink/src/Views/DetallesCuentaEspecialista/DetallesCuenta.dart';
import 'package:mentalink/src/Views/Login/Login.dart';
import 'package:mentalink/src/Views/Perfil/Perfil.dart';
import 'package:mentalink/src/Views/PerfilUsuario/Perfil.dart';
import 'package:mentalink/src/Views/RecuperarContrasena/RecuperarContrasena.dart';
import 'package:mentalink/src/Views/RecuperarContrasena/RecuperarContrasenaCodigo.dart';
import 'package:mentalink/src/Views/Registro/FinalizarRegistro.dart';
import 'package:mentalink/src/Views/Registro/RegistroParte1.dart';
import 'package:mentalink/src/Views/Psicologos/agendarCita.dart';
import 'package:mentalink/src/Views/Psicologos/menu.dart';
import 'package:mentalink/src/Views/Home/Home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mentalink/src/Widgets/formularioPreguntas.dart';

void main() {
  //WidgetsFlutwhterBinding.ensureInitialized();
  runApp(const MyApp());

  //initUniLinks();
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //navigatorKey: navigatorKey, // Asignar la clave global al MaterialApp
      locale: const Locale("es"),
      debugShowCheckedModeBanner: false,
      title: "Mentalink",
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale("es"),
      ],
      routes: {
        "/": (BuildContext context) => Inicio(),
        "/RegistroParte1": (BuildContext context) => RegistroParte1(),
        '/FinalizarRegistro': (BuildContext context) {
          final Map<String, String> args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return FinalizarRegistro(
            nombre: args['nombre']!,
            apellido: args['apellido']!,
            correo: args['correo']!,
            contrasena: args['contrasena']!,
          );
        },
        "/VerificarCorreo": (BuildContext context) {
          final Map<String, String> args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          
          return VerificarCorreo(
            nombre: args['nombre']!,
            apellido: args['apellido']!,
            correo: args['correo']!,
            contrasena: args['contrasena']!,
          );
        },
        "/login": (BuildContext context) => Login(),
        "/RecuperarContrasena": (BuildContext context) => RecuperarContrasena(),
        "/RecuperarContrasenaCodigo": (BuildContext context) => RecuperarContrasenaCodigo(correo: ModalRoute.of(context)!.settings.arguments as String),
        "/Home": (BuildContext context) => Home(),
        "/menuEspecialistas": (BuildContext context) => menu(),
        "/agendarCita": (BuildContext context) => angendarCita(),
        "/formularioPreguntas": (BuildContext context) => formularioPreguntas(),
        "/perfilEspecialista": (BuildContext context) => PerfilEspecialista(),
        "/perfil": (BuildContext context) => Perfil(), 
        "/citas": (BuildContext context) => Citas(),
        "/citasPsicologos": (BuildContext context) => CitasPsicologos(),  
        "/DetallesCuentaEspecialista": (BuildContext context) => DetallesCuentaEspecialista(),          
        "/DetallesCuenta": (BuildContext context) => DetallesCuenta(),
        "/PruebaMeet":(BuildContext context) => Meet(),
        "/testEvaluativo":(BuildContext context) => testEvaluativo(),
        "/testCooper":(BuildContext context) => TestCooper(),
        "/testbdi":(BuildContext context) => TestBDI(),
        "/testansiedad":(BuildContext context) => TestAnsiedad(),
        "/testasertividad":(BuildContext context) => TestAsertividad(),
        "/testdesesperanza":(BuildContext context) => TestDesesperanza(),
        "/testlaboral":(BuildContext context) => TestLaboral(),
        "/actualizarPassword":(BuildContext context) => ActualizarPassword(),
        "/RegistroGoogle":(BuildContext context) => RegistroGoogle(),
      },
    );
  }
}
