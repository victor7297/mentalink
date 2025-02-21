// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mentalink/src/Clases/gmail.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistroParte1 extends StatefulWidget {
  const RegistroParte1({Key? key}) : super(key: key);

  @override
  State<RegistroParte1> createState() => _RegistroParte12State();
}

class _RegistroParte12State extends State<RegistroParte1> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _nombreValido = true;
  bool _apellidoValido = true;
  bool _emailValido = true;
  bool _passwordValid = true;
  bool _passwordVisible = false;
  bool cargando = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                NetworkImage("https://mentalink.org/assets/images/fondo.jpg"),
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextFormField(
                    controller: _nombreController,
                    onChanged: (value) {
                      setState(() {
                        _nombreValido = value.isEmpty ||
                            RegExp(r'^[a-zA-ZñÑáéíóúÁÉÍÓÚ\s]+$')
                                .hasMatch(value);
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person, color: Color(0xFFa7a7a9)),
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
                if (!_nombreValido && _nombreController.text.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.only(left: 60),
                      child: Text(
                        'El nombre solo debe contener letras',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 20.0),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextFormField(
                    controller: _apellidoController,
                    onChanged: (value) {
                      setState(() {
                        _apellidoValido = value.isEmpty ||
                            RegExp(r'^[a-zA-ZñÑáéíóúÁÉÍÓÚ\s]+$')
                                .hasMatch(value);
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Apellido',
                      prefixIcon: Icon(Icons.person, color: Color(0xFFa7a7a9)),
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
                if (!_apellidoValido && _apellidoController.text.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.only(left: 60),
                      child: Text(
                        'El apellido solo debe contener letras',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 20.0),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextFormField(
                    controller: _emailController,
                    onChanged: (value) {
                      setState(() {
                        _emailValido = value.isEmpty ||
                            RegExp(r'^[a-zA-Z0-9ñÑáéíóúÁÉÍÓÚüÜ\._%+-]+@[a-zA-Z0-9ñÑáéíóúÁÉÍÓÚüÜ\.-]+\.[a-zA-Z]{2,}$')
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
                SizedBox(height: 20.0),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    onChanged: (value) {
                      setState(() {
                        _passwordValid = value.isNotEmpty &&
                            value.contains(RegExp(r'[A-Z]')) &&
                            value.contains(RegExp(r'[0-9]'));
                      });
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
                if (!_passwordValid)
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
                  ),
                SizedBox(height: 20.0),
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: cargando
                      ? Container(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(color: Colors.blue),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            String nombre = _nombreController.text;
                            String apellido = _apellidoController.text;
                            String correo = _emailController.text;
                            String contrasena = _passwordController.text;

                            bool camposVacios = false;

                            // Validación de campos vacíos
                            if (_nombreController.text.isEmpty) {
                              camposVacios = true;
                            }
                            if (_apellidoController.text.isEmpty) {
                              camposVacios = true;
                            }
                            if (_emailController.text.isEmpty) {
                              camposVacios = true;
                            }
                            if (_passwordController.text.isEmpty) {
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
                                  backgroundColor:
                                      Color.fromARGB(255, 0, 188, 207),
                                ),
                              );
                            } else {
                              setState(() {
                                _nombreValido = RegExp(r'^[a-zA-Z\s]+$')
                                    .hasMatch(_nombreController.text);
                                _apellidoValido = RegExp(r'^[a-zA-Z\s]+$')
                                    .hasMatch(_apellidoController.text);
                                _emailValido =
                                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(_emailController.text);
                                _passwordValid =
                                    _passwordController.text.isNotEmpty &&
                                        _passwordController.text
                                            .contains(RegExp(r'[A-Z]')) &&
                                        _passwordController.text
                                            .contains(RegExp(r'[0-9]'));
                              });

                              if (_nombreValido &&
                                  _apellidoValido &&
                                  _emailValido &&
                                  _passwordValid) {
                                // Cambiar el estado a cargando
                                /*setState(() {
                                  cargando = true;
                                });

                                Map<String, dynamic> data = {
                                  'correo': correo,
                                };

                                var respuesta =
                                    await Servicio().enviarCorreoCodigo(data);

                                // Después de la respuesta, cambiar el estado a no cargando
                                setState(() {
                                  cargando = false;
                                });

                                if (respuesta['status'] == 'success') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        respuesta['message'],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor:
                                          Color.fromARGB(255, 0, 188, 207),
                                    ),
                                  );*/

                                  Navigator.pushNamed(
                                    context,
                                    '/FinalizarRegistro',
                                    arguments: {
                                      'nombre': nombre,
                                      'apellido': apellido,
                                      'correo': correo,
                                      'contrasena': contrasena,
                                    },
                                  );
                                /*} else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        respuesta['message'] ??
                                            'Error al enviar el código de verificación',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }*/
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
                            'Crear una cuenta',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'O registrarse con Google',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  width: MediaQuery.of(context).size.width * 0.7,
                  //margin: EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final user = await gmail.login();

                        final GoogleSignInAuthentication googleAuth =
                            await user!.authentication;

                        Map<String, dynamic> data = {"correo": user.email};

                        data = await Servicio().verificarCorreo(data);

                        if (data['status'] != "success") {
                          await gmail.disconnect();

                          Navigator.of(context).pushNamed(
                            "/RegistroGoogle",
                            arguments: {
                              'correo': user.email,
                            },
                          );
                        } else {
                          final snackBar = SnackBar(
                            content: Text(
                              'Correo ya Registrado.',
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

                          await gmail.disconnect();
                        }
                      } catch (e) {
                        print(e);
                        await gmail.disconnect();
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.google,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                        Text(
                          '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    'Ya tengo una cuenta',
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
