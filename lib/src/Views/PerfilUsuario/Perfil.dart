// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_interpolation_to_compose_strings

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mentalink/src/Clases/appbarPerfil.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:mentalink/src/Widgets/drawer.dart';
import 'package:mentalink/src/Widgets/footer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mentalink/src/Clases/appbar.dart';

class Perfil extends StatefulWidget {
  const Perfil({Key? key}) : super(key: key);

  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {

  String tipoUsuario = "";
  Map<String, dynamic> usuarioData = {};

  appbar appbarAux = appbar("", "");

  obtenerDatosUsuario() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String usuarioId = prefs.getString('usuario_id') ?? "";
    String? tipoUsuario = prefs.getString('tipo_usuario');
    String? rutaImagenPerfil = prefs.getString('fotoPerfil');

    print(usuarioId);
    print(rutaImagenPerfil);

    appbar appbarAux2 = appbar(usuarioId, rutaImagenPerfil!);

    setState(() {
      this.tipoUsuario = tipoUsuario!;
      appbarAux = appbarAux2;
    });
  }
  

  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();
    _recuperarDatos();
  }

  Future<void> _recuperarDatos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String usuarioId = prefs.getString('usuario_id') ?? "";

    // Llamar al servicio para obtener el usuario especialista
    Map<String, dynamic> userData = await Servicio().obtenerUsuario(int.parse(usuarioId));

    setState(() {
      usuarioData = userData;

      print(usuarioData['usuario_id']);

    });
  }

  String? rutaImagenSeleccionada;

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        rutaImagenSeleccionada = pickedFile.path;
      });

      await _subirImagen();

    } else {
      print('No se seleccionó ninguna imagen.');
    }
  }


  Future<void> _subirImagen() async {
    if (rutaImagenSeleccionada != null) {
      File imagenSeleccionada = File(rutaImagenSeleccionada!);
      int usuarioId = int.parse(usuarioData['usuario_id']);

      try { 
        await Servicio().actualizarFotoPerfil(imagenSeleccionada , usuarioId);

        print('Foto de perfil actualizada correctamente');

      } catch (error) {
        
        print('$error');
      }
    }
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      //extendBodyBehindAppBar: true,
      appBar: appbarAux.getAppbar(context),

      drawer: NowDrawer(currentPage: 'Perfil',),

      body: WillPopScope(

        onWillPop: () async {
          Navigator.of(context).pushNamed("/Home");
          return false;
        },

        child: SingleChildScrollView(
        
          child: Stack(
        
            children: [
        
              Container(
                height: MediaQuery.of(context).size.height * 0.56,
                child: Stack(
                  children: [
                    // Imagen del servicio
                    if (usuarioData['foto'] != null && usuarioData['foto'] != "")
                      Image.network(
                        "https://mentalink.org/api-mentalink-prueba-v/public/"+usuarioData['foto'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    else
                      // Si no hay una imagen del servicio, muestra una imagen predeterminada
                      Image.network(
                        'https://mentalink.org/assets/images/icono-perfil-usuario.png',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    // Mostrar la imagen seleccionada si hay una
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
                    ]
                  )
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
                              onPressed: () {
                                _seleccionarImagen();
                              },
                              color: Color.fromRGBO(254, 36, 114, 1.0),
                            ),
                          ),
                        ],
                      ),
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
                          offset: Offset(0, 0)
                        )
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(13.0),
                        topRight: Radius.circular(13.0),
                      )
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
                  ),
                ),
        
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: Footer(),
    );
  }
}