// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, use_key_in_widget_constructors, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, unused_element, avoid_print

import 'package:flutter/material.dart';
import 'package:mentalink/src/Views/Usuarios/Servicios/Servicio.dart';

class Inicio extends StatefulWidget {
  const Inicio({Key? key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {


  prueba()async{

  

      try {

        setState(() {
          aux = "hola2";
        });

        dynamic data = await Servicio().prueba();

        setState(() {
          aux = data["status"].toString();
        });

      } catch (e) {
        print('Ocurrió un error: $e');

        setState(() {
          aux = e.toString();
        });
      }

      //print(data["status"].runtimeType);

      
    

    }

    @override
    void initState() {
      
      
      super.initState();
    }

  String aux = "hola";

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
                child: Image.network("https://mentalink.tepuy21.com/assets/images/Psicologo.jpg",
                  
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 14),
              Container(
                width: 160,
                child: Image.network(
                  "https://mentalink.tepuy21.com/assets/images/logo-text.png",
                  fit: BoxFit.cover,
                ),
              ),
            
              SizedBox(height: 30),
              Container(
                width: containerWidth,
                height: containerHeight,
                margin: EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/RegistroParte1');
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Container(child: Text("hola"),),
              Container(child: Text("victor"),),
              Container(child: Text("caceres"),),

              Container(
                width: containerWidth,
                height: containerHeight,
                margin: EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
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
                    'Ya Tengo Una Cuenta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ' O inicia con Google',
                      style: TextStyle(
                        color: Color.fromARGB(255, 56, 55, 58),
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: containerWidth,
                height: containerHeight,
                margin: EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, 
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(color: Colors.black, width: 1),
                    ),
                    shadowColor: Colors.blue[900],
                    elevation: 5,
                  ),
                  child: Text(
                    '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Terminos y Condiciones',
                      style: TextStyle(
                        color: Color.fromARGB(255, 60, 59, 63),
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
