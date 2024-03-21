import 'package:flutter/material.dart';

class RegistroParte1 extends StatefulWidget {
  const RegistroParte1({Key? key}) : super(key: key);

  @override
  State<RegistroParte1> createState() => _RegistroParte1State();
}

class _RegistroParte1State extends State<RegistroParte1> {
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
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    double containerWidth = screenWidth * 0.7;
    double containerHeight = screenHeight * 0.06;

    // MediaQuery de flutter
    if (screenWidth > 1300) {
      containerWidth = screenWidth * 0.6;
      containerHeight = screenHeight * 0.05;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: screenHeight * 0.4,
                child: Image.asset(
                  'Psicologo.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 14),
              Container(
                width: 160,
                child: Image.asset(
                  'logo-text.png',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 25),
              Container(
                width: containerWidth,
                height: containerHeight,
                margin: EdgeInsets.only(bottom: 6),
                child: TextField(
                  controller: _nombreController,
                  onChanged: (value) {
                    setState(() {
                      _nombreValido = value.isEmpty || RegExp(r'^[a-zA-Z]+$').hasMatch(value);
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nombre',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
              SizedBox(height: 5),
              Container(
                width: containerWidth,
                height: containerHeight,
                margin: EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: _apellidoController,
                  onChanged: (value) {
                    setState(() {
                      _apellidoValido = value.isEmpty || RegExp(r'^[a-zA-Z]+$').hasMatch(value);
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Apellido',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 3),
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
              SizedBox(height: 5),
              Container(
                width: containerWidth,
                height: containerHeight,
                margin: EdgeInsets.only(bottom: 10),
                child: TextField(
                  controller: _emailController,
                  onChanged: (value) {
                    setState(() {
                      _emailValido = value.isEmpty || RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
              SizedBox(height: 5),
              Container(
                width: containerWidth,
                height: containerHeight,
                margin: EdgeInsets.only(bottom: 10),
                child: TextField(
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
                    border: OutlineInputBorder(),
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
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
                ),
              ),
              SizedBox(height: 3),
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
              SizedBox(height: 20),
              Container(
                width: containerWidth,
                height: containerHeight,
                margin: EdgeInsets.only(bottom: 15),
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
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              '¡Complete Todos Los Campos!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Aceptar',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      
                      setState(() {
                        _nombreValido =
                            RegExp(r'^[a-zA-Z]+$').hasMatch(_nombreController.text);
                        _apellidoValido = RegExp(r'^[a-zA-Z]+$')
                            .hasMatch(_apellidoController.text);
                        _emailValido = RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(_emailController.text);
                        _passwordValid = _passwordController.text.isNotEmpty &&
                            _passwordController.text.contains(RegExp(r'[A-Z]')) &&
                            _passwordController.text.contains(RegExp(r'[0-9]'));
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
                    foregroundColor: Colors.white, 
                    backgroundColor: Color.fromRGBO(19, 57, 121, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(color: Colors.black, width: 1),
                    ),
                    shadowColor: Colors.blue[900],
                    elevation: 5,
                  ),
                  child: Text(
                    'Crear una cuenta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text(
                  'Ya tengo una cuenta',
                  style: TextStyle(
                    color: Color.fromARGB(255, 56, 55, 58),
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
