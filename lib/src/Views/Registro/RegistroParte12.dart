import 'package:flutter/material.dart';

class RegistroParte12 extends StatefulWidget {
  const RegistroParte12({Key? key}) : super(key: key);

  @override
  State<RegistroParte12> createState() => _RegistroParte12State();
}

class _RegistroParte12State extends State<RegistroParte12> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _nombreValido = true;
  bool _apellidoValido = true;
  bool _emailValido = true;
  bool _passwordValid = true;
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(

        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("/fondo.jpg"),
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
                  child: Image.asset(
                    'logoText.png',
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
                            RegExp(r'^[a-zA-Z]+$').hasMatch(value);
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
                            RegExp(r'^[a-zA-Z]+$').hasMatch(value);
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
                  child: ElevatedButton(
                    onPressed: () {
                      String nombre = _nombreController.text;
                      String apellido = _apellidoController.text;
                      String correo = _emailController.text;
                      String contrasena = _passwordController.text;

                      bool camposVacios = false;

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
                            backgroundColor: Color.fromARGB(255, 0, 188, 207),
                          ),
                        );
                      } else {
                        setState(() {
                          _nombreValido = RegExp(r'^[a-zA-Z]+$')
                              .hasMatch(_nombreController.text);
                          _apellidoValido = RegExp(r'^[a-zA-Z]+$')
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
