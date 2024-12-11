// ignore_for_file: camel_case_types, prefer_const_constructors, sized_box_for_whitespace, avoid_unnecessary_containers

import 'package:flutter/material.dart';

class formularioPreguntas extends StatefulWidget {
  const formularioPreguntas({super.key});

  @override
  State<formularioPreguntas> createState() => _formularioPreguntasState();
}

class _formularioPreguntasState extends State<formularioPreguntas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(

        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              SizedBox(height: 25),

              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Image.asset(
                  'logoText.png',
                  fit: BoxFit.cover,
                ),
              ),

              SizedBox(height: 15),

              Text(
                "Completa la siguiente información:",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: Color.fromRGBO(79, 79, 79, 1.0),
                ),
              ),

              SizedBox(height: 30),

              Form(
                child: Column(
                  children: List.generate(6, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Pregunta ${index + 1}',
                          contentPadding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 12),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0, color: Color.fromARGB(255, 0, 188, 207)),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          labelStyle: TextStyle(color: Color.fromRGBO(79, 79, 79, 1.0)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(width: 2.0, color: Color.fromARGB(255, 0, 188, 207)),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        cursorColor: Color.fromARGB(255, 0, 188, 207),
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }),
                ),
              ),

              //SizedBox(height: 15),

              SizedBox(

                width: MediaQuery.of(context).size.width * 0.8,

                child: ElevatedButton(

                  onPressed: () {
                    Navigator.pushNamed(context, '/Home');
                  },

                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    backgroundColor: Color.fromRGBO(10, 28, 92, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(width: 2.0, color: Color.fromARGB(255, 0, 188, 207)),
                    ),
                    elevation: 5,
                  ),
                  
                  child: Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

              ),

              SizedBox(height: 10),

              TextButton(

                onPressed: () {
                  Navigator.pushNamed(context, '/Home');
                },

                child: Text(
                  'Saltar',
                  style: TextStyle(color: Colors.black, decoration: TextDecoration.underline, fontSize: 15),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}