// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mentalink/src/Clases/appbarPerfil.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:mentalink/src/Widgets/drawer.dart';
import 'package:mentalink/src/Widgets/footer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mentalink/src/Clases/appbar.dart';

class PerfilEspecialista extends StatefulWidget {
  const PerfilEspecialista({super.key});

  @override
  State<PerfilEspecialista> createState() => _PerfilEspecialistaState();
}

class _PerfilEspecialistaState extends State<PerfilEspecialista> {
  String token = "";
  String usuarioId = "";
  String tipoUsuario = "";
  Map<String, dynamic> usuarioData = {};
  String? rutaImagenSeleccionada;

  @override
  void initState() {
    super.initState();
    _recuperarDatos();
  }

  Future<void> _recuperarDatos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String usuarioId = prefs.getString('usuario_id') ?? "";

    // Llamar al servicio para obtener el usuario especialista
    Map<String, dynamic> userData = await Servicio().obtenerInformacionUsuarioEspecialista(int.parse(usuarioId));

    setState(() {
      usuarioData = userData;
    });
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        rutaImagenSeleccionada = pickedFile.path;
      });
    } else {
      print('No se seleccionó ninguna imagen.');
    }
  }

  appbar appbarAux = appbar("", "");

  obtenerDatosUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String usuarioId = prefs.getString('usuario_id') ?? "";
    String? tipoUsuario = prefs.getString('tipo_usuario');
    appbarAux.setId(usuarioId);

    usuarioData = await Servicio().obtenerUsuario(int.parse(usuarioId));
    appbarAux.setRutaImagenPerfil(usuarioData['foto']);

    await prefs.setString('fotoPerfil', usuarioData['foto']);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushNamed("/Home");
        return false;
      },
      child: Scaffold(
        appBar: appbarAux.getAppbar(context),
        drawer: NowDrawer(currentPage: 'Perfil'),
        body: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.56,
                child: Stack(
                  children: [
                    if (usuarioData['foto'] != null && usuarioData['foto'] != "")
                      Image.network(
                        "https://mentalink.org/api-mentalink-prueba-v/public/${usuarioData['foto']}",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    else
                      Image.network(
                        'https://mentalink.org/assets/images/icono-perfil-usuario.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    if (rutaImagenSeleccionada != null)
                      Positioned.fill(
                        child: Image.file(
                          File(rutaImagenSeleccionada!),
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.40,
                ),
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        children: [
                          Text(
                            "${usuarioData['nombre']} ${usuarioData['apellido']}",
                            style: TextStyle(fontSize: 28, color: Colors.white),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5),
                            child: IconButton(
                              icon: Icon(Icons.camera_alt),
                              onPressed: _seleccionarImagen,
                              color: Color.fromRGBO(254, 36, 114, 1.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Color.fromRGBO(254, 36, 114, 1.0),
                                ),
                                child: Text(
                                  usuarioData['especialidad'] ?? 'Psicólogo',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Text(
                                    "4.8",
                                    style: TextStyle(color: Color.fromRGBO(255, 152, 0, 1.0), fontSize: 16),
                                  ),
                                ),
                                Icon(Icons.star_border, color: Color.fromRGBO(255, 152, 0, 1.0), size: 20),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.pin_drop, color: Color.fromRGBO(151, 151, 151, 1.0)),
                            ),
                            Text(
                              "Mentalink, CA",
                              style: TextStyle(color: Color.fromRGBO(151, 151, 151, 1.0)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 8,
                          blurRadius: 10,
                          offset: Offset(0, 0),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(13.0),
                        topRight: Radius.circular(13.0),
                      ),
                    ),
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.50,
                    ),
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Text("36", style: TextStyle(fontWeight: FontWeight.w600)),
                                  SizedBox(height: 6),
                                  Text("Pacientes", style: TextStyle(color: Color.fromRGBO(151, 151, 151, 1.0))),
                                ],
                              ),
                              Column(
                                children: [
                                  Text("5", style: TextStyle(fontWeight: FontWeight.w600)),
                                  SizedBox(height: 6),
                                  Text("Favoritos", style: TextStyle(color: Color.fromRGBO(151, 151, 151, 1.0))),
                                ],
                              ),
                              Column(
                                children: [
                                  Text("2", style: TextStyle(fontWeight: FontWeight.w600)),
                                  SizedBox(height: 6),
                                  Text("Mensajes", style: TextStyle(color: Color.fromRGBO(151, 151, 151, 1.0))),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 16, bottom: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Sobre Mi",
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.0),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(bottom: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      usuarioData['biografia'] ?? '...',
                                      style: TextStyle(color: Color.fromRGBO(151, 151, 151, 1.0)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                
                                Column(
                                  children: [
              
                                  Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(context, '/DetallesCuenta');
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.account_circle, size: 30),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    'Detalles de la cuenta',
                                                    style: TextStyle(fontSize: 18),
                                                  ),
                                                ],
                                              ),
                                              Icon(Icons.arrow_forward_ios),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      //padding: EdgeInsets.symmetric(horizontal: 10),
                                      padding: EdgeInsets.only(left: 10,right: 10, bottom: 70),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(context, '/actualizarPassword');
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.5),
                                                spreadRadius: 2,
                                                blurRadius: 5,
                                                offset: Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.lock, size: 30),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    'Cambiar Contraseña',
                                                    style: TextStyle(fontSize: 18),
                                                  ),
                                                ],
                                              ),
                                              Icon(Icons.arrow_forward_ios),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Footer(),
      ),
    );
  }
}
