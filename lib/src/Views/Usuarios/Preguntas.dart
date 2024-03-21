import 'package:flutter/material.dart';

class RecuperarContrasena extends StatefulWidget {
  const RecuperarContrasena({Key? key}) : super(key: key);

  @override
  State<RecuperarContrasena> createState() => _RecuperarContrasenaState();
}

class _RecuperarContrasenaState extends State<RecuperarContrasena> {
  final TextEditingController _emailController = TextEditingController();
  bool _emailValido = true;

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
              SizedBox(height: 10),
              Container(
                width: containerWidth,
                height: containerHeight,
                margin: EdgeInsets.only(bottom: 15),
                child: ElevatedButton(
                  onPressed: () {
                    
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
                    'Recuperar cuenta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    color: Color.fromARGB(255, 56, 55, 58),
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 25),
              Container(
                width: containerWidth,
                height: containerHeight,
                margin: EdgeInsets.only(bottom: 15),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/RegistroParte1');
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
                    'Crear cuenta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
