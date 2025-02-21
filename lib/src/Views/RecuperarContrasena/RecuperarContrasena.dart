// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:googleapis/authorizedbuyersmarketplace/v1.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:mentalink/src/Views/RecuperarContrasena/RecuperarContrasenaCodigo.dart';

class RecuperarContrasena extends StatefulWidget {
  const RecuperarContrasena({Key? key}) : super(key: key);

  @override
  State<RecuperarContrasena> createState() => _RecuperarContrasenaState();
}

class _RecuperarContrasenaState extends State<RecuperarContrasena> {
  final TextEditingController _emailController = TextEditingController();
  bool _emailValido = true;
  bool mostrarContainerError = false;
  String mensajeError = "";
  bool loading = false;

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage("https://mentalink.org/assets/images/fondo.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  width: 260,
                  child: Image.network(
                    'https://mentalink.org/assets/images/Logo_Mentalink.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextFormField(
                    controller: _emailController,
                    onChanged: (value) {
                      setState(() {
                        _emailValido = value.isEmpty ||
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value);
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Color(0xFFa7a7a9)),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2.0, color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelStyle: TextStyle(color: Color(0xFFa7a7a9)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 3),
                if (!_emailValido && _emailController.text.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.only(left: 60),
                      child: Text(
                        'Formato de correo electrónico inválido',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 20),

                loading ? Container(child: CircularProgressIndicator(color: Colors.blue,),): Container(),


                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ElevatedButton(
                    onPressed: () async{

                      if(_emailController.text != ""){

                        setState(() {
                          loading = true;
                        });

                        Map<String, dynamic> data = {
                          "correo": _emailController.text
                        };

                        var respuesta = await Servicio().recuperarPassword(data);

                        if (respuesta['status'] == "success") {

                          setState(() {
                            loading = false;
                          });

                          final snackBar = SnackBar(
                            content: Text(
                              'Se ha enviado un código de recuperación a tu correo electrónico.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Color.fromARGB(255, 0, 188, 207),
                          );

                          // Muestra el SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);

                          // Usa un Timer para esperar el tiempo que durará el SnackBar
                          Future.delayed(snackBar.duration ?? Duration(seconds: 2), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecuperarContrasenaCodigo(correo: _emailController.text),
                              ),
                            );
                          });
                        }
                        else{

                          setState(() {
                            loading = false;
                          });

                        }
                      }
                      else{

                        final snackBar = SnackBar(
                          content: Text(
                            'Ingrese un correo por favor.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: Color.fromARGB(255, 0, 188, 207),
                        );

                        // Muestra el SnackBar
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }

                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Color.fromARGB(255, 0, 188, 207),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(width: 2.0, color: Colors.white),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Recuperar cuenta',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
