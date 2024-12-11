
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController CorreoController = TextEditingController();
  final TextEditingController ContrasenaController = TextEditingController();
  bool _emailValido = true;
  bool _passwordValid = true;
  bool _passwordVisible = false;
  bool mostrarContainerError = false;
  String mensajeError = "";

  bool checked = false;

  @override
  void initState() {
    super.initState();
    _checkRememberUser();
  }

  Future<void> _checkRememberUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      checked = prefs.getBool('checked') ?? false;
      if (checked) {
        CorreoController.text = prefs.getString('email') ?? '';
        ContrasenaController.text = prefs.getString('clave') ?? '';
      }
    });
  }
  void _handleRememberUser(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      checked = value;
    });

    if (checked) {
      // Guardar los valores en SharedPreferences
      await prefs.setBool('checked', checked);
      await prefs.setString('email', CorreoController.text);
      await prefs.setString('clave', ContrasenaController.text);
    } else {
      // Eliminar los valores de SharedPreferences
      await prefs.remove('checked');
      await prefs.remove('email');
      await prefs.remove('clave');
    }
  }

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
                    controller: CorreoController,
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
                if (!_emailValido && CorreoController.text.isNotEmpty)
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextFormField(
                    controller: ContrasenaController,
                    obscureText: !_passwordVisible,
                    onChanged: (value) {
                      /*setState(() {
                        _passwordValid = value.isNotEmpty &&
                            value.contains(RegExp(r'[A-Z]')) &&
                            value.contains(RegExp(r'[0-9]'));
                      });*/
                    },
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock, color: Color(0xFFa7a7a9)),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2.0, color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelStyle: TextStyle(color: Colors.white),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 3),
                /*if (!_passwordValid)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.only(left: 60),
                      child: Text(
                        'La contraseña debe contener al menos una mayúscula y un número',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),*/
                mostrarContainerError
                    ? Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        margin: EdgeInsets.only(bottom: 10, top: 10),
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(221, 13, 13, 0.1),
                          borderRadius: BorderRadius.circular(5.0),
                          border: Border.all(color: Colors.red, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            mensajeError,
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      )
                    : Container(),
                SizedBox(height: 5),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Checkbox(
                        value: checked,
                        onChanged: (value) {
                          setState(() {
                            checked = value!;
                          });
                          _handleRememberUser(checked);
                        },
                        activeColor: Color.fromARGB(255, 0, 188, 207),
                      ),
                      Text(
                        "Recordar Usuario",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          //fontWeight: FontWeight.bold,
                          //decoration: TextDecoration.underline,
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  width: MediaQuery.of(context).size.width * 0.7,
                  /*child: ElevatedButton(
                    onPressed: () async {
                      bool camposVacios = false;
                      if (CorreoController.text.isEmpty ||
                          ContrasenaController.text.isEmpty) {
                        camposVacios = true;
                      }

                      if (camposVacios) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '¡Complete Todos Los Campos!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Color.fromARGB(255, 0, 188, 207),
                          ),
                        );
                      } else {
                        setState(() {
                          _emailValido =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(CorreoController.text);
                          _passwordValid =
                              ContrasenaController.text.isNotEmpty &&
                                  ContrasenaController.text
                                      .contains(RegExp(r'[A-Z]')) &&
                                  ContrasenaController.text
                                      .contains(RegExp(r'[0-9]'));
                        });

                          if (_emailValido && _passwordValid) {
                          Map<String, dynamic> data = {
                            "correo": CorreoController.text,
                            "contrasena": ContrasenaController.text,
                          };

                          var respuesta = await Servicio().validarLogin(data);

                          print(respuesta);

                          if (respuesta['status'] == "error") {
                            setState(() {
                              mostrarContainerError = true;
                              mensajeError = respuesta['message'];
                            });
                          } else {
                            // Guardar datos del usuario en SharedPreferences
                            SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setString('token', respuesta['token_seguridad']);
                            await prefs.setString('usuario_id', respuesta['usuario_id']);
                            await prefs.setString('tipo_usuario', respuesta['tipo_usuario']);
                            
                            Navigator.of(context).pushNamed("/Home");
                          }
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
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),*/
                  child: ElevatedButton(
                    onPressed: () async {
                      bool camposVacios = CorreoController.text.isEmpty || ContrasenaController.text.isEmpty;

                      if (camposVacios) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '¡Complete Todos Los Campos!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Color.fromARGB(255, 0, 188, 207),
                          ),
                        );
                      } else {
                        Map<String, dynamic> data = {
                          "correo": CorreoController.text,
                          "contrasena": ContrasenaController.text,
                        };

                        var respuesta = await Servicio().validarLogin(data);

                        print(respuesta);

                        if (respuesta['status'] == "error") {
                          setState(() {
                            mostrarContainerError = true;
                            mensajeError = respuesta['message'];
                          });
                        } else {
                          // Guardar datos del usuario en SharedPreferences
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString('token', respuesta['token_seguridad']);
                          await prefs.setString('usuario_id', respuesta['usuario_id']);
                          await prefs.setString('tipo_usuario', respuesta['tipo_usuario']);
                          await prefs.setString('pais', respuesta['pais']);

                            Navigator.of(context).pushNamed("/Home");
                      
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
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/RecuperarContrasena');
                  },
                  child: Text(
                    'Olvidé mi Contraseña',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      //decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
