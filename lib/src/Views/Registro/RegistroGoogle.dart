// ignore_for_file: prefer_const_constructors, unused_element, prefer_adjacent_string_concatenation, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:mentalink/src/Inicio.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:mentalink/src/Views/Login/Login.dart';


class RegistroGoogle extends StatefulWidget {
  
  const RegistroGoogle({super.key});

  @override
  State<RegistroGoogle> createState() => _RegistroGoogleState();
}

class _RegistroGoogleState extends State<RegistroGoogle> {

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();


  bool _nombreValido = true;
  bool _apellidoValido = true;


  @override
  void initState() {
    super.initState();
    
  }

  @override
  Widget build(BuildContext context) {

    final argumentos = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>;
    String correo = argumentos["correo"] ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Completar Registro",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Color.fromRGBO(9, 25, 87, 1.0),
      ),
      body: SingleChildScrollView(
        child: Container(
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

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextFormField(
                    controller: _nombreController,
                    onChanged: (value) {
                      setState(() {
                        _nombreValido = value.isEmpty ||
                            RegExp(r'^[a-zA-ZñÑáéíóúÁÉÍÓÚ\s]+$').hasMatch(value);
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
                            RegExp(r'^[a-zA-ZñÑáéíóúÁÉÍÓÚ\s]+$').hasMatch(value);
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

                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ElevatedButton(
                    onPressed: () {
                      String nombre = _nombreController.text;
                      String apellido = _apellidoController.text;
                    

                      bool camposVacios = false;

                      if (_nombreController.text.isEmpty) {
                        camposVacios = true;
                      }
                      if (_apellidoController.text.isEmpty) {
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
                          _nombreValido = RegExp(r'^[a-zA-Z\s]+$')
                              .hasMatch(_nombreController.text);
                          _apellidoValido = RegExp(r'^[a-zA-Z\s]+$')
                              .hasMatch(_apellidoController.text);
                          
                        });

                        if (_nombreValido &&
                            _apellidoValido) {
                          Navigator.pushNamed(
                            context,
                            '/FinalizarRegistro',
                            arguments: {
                              'nombre': nombre,
                              'apellido': apellido,
                              'correo': correo,
                              'contrasena': "",
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
                                      ),]
        ), 
        
          ))))
      
      );
    
  }
  
}

