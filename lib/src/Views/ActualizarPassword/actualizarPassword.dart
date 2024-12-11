// ignore_for_file: camel_case_types, prefer_const_constructors, body_might_complete_normally_nullable, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActualizarPassword extends StatefulWidget {
  const ActualizarPassword({super.key});

  @override
  State<ActualizarPassword> createState() => _ActualizarPasswordState();
}

class _ActualizarPasswordState extends State<ActualizarPassword> {
  String passwordRepeat = "";
  String password = "";
  String correo = "";
  late RegExp regExp;
  bool _passwordVisible = false;

  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordRepetirController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  obtenerDatosUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String usuarioId = prefs.getString('usuario_id') ?? "";
    Map<String, dynamic> usuarioData = await Servicio().obtenerUsuario(int.parse(usuarioId));

    setState(() {
      correo = usuarioData['correo'];
    });
  }

  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Actualizar Contraseña'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20.0),
                child: TextFormField(
                  controller: passwordController,
                  obscureText: !_passwordVisible,
                  onSaved: (value) {
                    password = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Complete este campo por favor";
                    } else if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "Contraseña:",
                    prefixIcon: Icon(Icons.lock, color: Color.fromARGB(255, 0, 0, 0)),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2.0, color: Color.fromARGB(255, 0, 0, 0)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  cursorColor: Color.fromARGB(255, 0, 0, 0),
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20.0),
                child: TextFormField(
                  controller: passwordRepetirController,
                  obscureText: !_passwordVisible,
                  onSaved: (value) {
                    passwordRepeat = value!;
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Complete este campo por favor";
                    } else if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "Repetir Contraseña:",
                    prefixIcon: Icon(Icons.lock, color: Color.fromARGB(255, 0, 0, 0)),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2.0, color: Color.fromARGB(255, 0, 0, 0)),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  cursorColor: Color.fromARGB(255, 0, 0, 0),
                  style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20.0),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      formKey.currentState!.save();

                      if (password == passwordRepeat) {
                        Map<String, String> data = {
                          "correo": correo,
                          "nueva_contrasena": password,
                        };

                        Map<String, dynamic> respuesta = await Servicio().updatePassword(data);

                        if (respuesta['status'] == "success") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                respuesta['message'] + '.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Color.fromARGB(255, 0, 188, 207),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Las contraseñas no coinciden.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Color.fromARGB(255, 0, 188, 207),
                          ),
                        );
                      }
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
                    'Guardar Cambios',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
