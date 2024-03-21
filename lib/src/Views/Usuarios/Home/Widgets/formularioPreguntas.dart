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

      body: Container(
        width: double.infinity,
        height: double.infinity,
        //color: Colors.amber,

        child: SingleChildScrollView(
        
          child: Container(

            padding: EdgeInsets.only(top: 50, bottom: 50, left: 20, right: 20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            
                Container(
                  //color: Colors.red,
                  width: double.infinity,
                  //color: Colors.amber,
                  child: Image.asset(
                    'logo-text.png',
                    //fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(top: 30),
                  width: double.infinity,
                  //color: Colors.blue,
                  child: Center(child: Text("Completa la siguiente información",style: TextStyle(fontWeight: FontWeight.bold),)),
                ),

                Container(

                  //color: Colors.green,
                  child: Form(
                    child: Column(

                      children: [
                        
                        Container(
                          //color: Colors.brown,
                          margin: EdgeInsets.only(top: 40),

                          child: TextFormField(
                            
                            decoration: InputDecoration(
                              labelText: 'Pregunta 1',
                              filled: false,// Esta propiedad permite quitarle el color de fondo a los textFormField

                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(10, 28, 92, 1)), // Borde cuando el campo no está enfocado
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue), // Borde cuando el campo está enfocado
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red), // Borde cuando hay un error
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red), // Borde cuando el campo está enfocado y hay un error
                              ),

                            ),
                          ),
                        ),

                        Container(
                          //color: Colors.brown,
                          margin: EdgeInsets.only(top: 20),
                          
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Pregunta 2',
                              filled: false,// Esta propiedad permite quitarle el color de fondo a los textFormField

                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(10, 28, 92, 1)), // Borde cuando el campo no está enfocado
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue), // Borde cuando el campo está enfocado
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red), // Borde cuando hay un error
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red), // Borde cuando el campo está enfocado y hay un error
                              ),

                            ),
                          ),
                        ),

                        Container(
                          //color: Colors.brown,
                          margin: EdgeInsets.only(top: 20),
                          
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Pregunta 3',
                              filled: false,// Esta propiedad permite quitarle el color de fondo a los textFormField

                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(10, 28, 92, 1)), // Borde cuando el campo no está enfocado
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue), // Borde cuando el campo está enfocado
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red), // Borde cuando hay un error
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red), // Borde cuando el campo está enfocado y hay un error
                              ),

                            ),
                          ),
                        ),

                        Container(
                          //color: Colors.brown,
                          margin: EdgeInsets.only(top: 20),
                          
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Pregunta 4',
                              filled: false,// Esta propiedad permite quitarle el color de fondo a los textFormField

                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(10, 28, 92, 1)), // Borde cuando el campo no está enfocado
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue), // Borde cuando el campo está enfocado
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red), // Borde cuando hay un error
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red), // Borde cuando el campo está enfocado y hay un error
                              ),

                            ),
                          ),
                        ),

                        Container(
                          //color: Colors.brown,
                          margin: EdgeInsets.only(top: 20),
                          
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Pregunta 5',
                              filled: false,// Esta propiedad permite quitarle el color de fondo a los textFormField

                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(10, 28, 92, 1)), // Borde cuando el campo no está enfocado
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue), // Borde cuando el campo está enfocado
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red), // Borde cuando hay un error
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red), // Borde cuando el campo está enfocado y hay un error
                              ),

                            ),
                          ),
                        ),

                        Container(
                          //color: Colors.brown,
                          margin: EdgeInsets.only(top: 20),
                          
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Pregunta 6',
                              filled: false,// Esta propiedad permite quitarle el color de fondo a los textFormField

                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(10, 28, 92, 1)), // Borde cuando el campo no está enfocado
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue), // Borde cuando el campo está enfocado
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red), // Borde cuando hay un error
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red), // Borde cuando el campo está enfocado y hay un error
                              ),

                            ),
                          ),
                        ),

                        Container(
                          //color: Colors.brown,
                          margin: EdgeInsets.only(top: 20),
                          
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Pregunta 7',
                              filled: false,// Esta propiedad permite quitarle el color de fondo a los textFormField

                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(10, 28, 92, 1)), // Borde cuando el campo no está enfocado
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue), // Borde cuando el campo está enfocado
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red), // Borde cuando hay un error
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red), // Borde cuando el campo está enfocado y hay un error
                              ),

                            ),
                          ),
                        ),

                        Container(
                          //color: Colors.brown,
                          margin: EdgeInsets.only(top: 20),
                          
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Pregunta 8',
                              filled: false,// Esta propiedad permite quitarle el color de fondo a los textFormField

                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color.fromRGBO(10, 28, 92, 1)), // Borde cuando el campo no está enfocado
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue), // Borde cuando el campo está enfocado
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red), // Borde cuando hay un error
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red), // Borde cuando el campo está enfocado y hay un error
                              ),

                            ),
                          ),
                        ),

                        Container(

                          width: double.infinity,
                          height: 50,
                          margin: EdgeInsets.only(top: 40),

                          child: ElevatedButton(

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(10, 28, 92, 1), // Reemplaza con el color deseado
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0), // Reemplaza con el radio de borde deseado
                              ),
                            ),
                            onPressed: (){

                            },
                            child: Text(
                              "Continuar",
                              style: TextStyle( color: Colors.white, fontSize: 20 ),
                            )
                          ),
                        ),

                        Container(

                          width: double.infinity,
                          margin: EdgeInsets.only(top: 20),
                          
                          child: TextButton(
                            onPressed: () {
                              // Acción al presionar el botón
                            },
                            child: Text('Saltar',style: TextStyle(color: Colors.black, decoration: TextDecoration.underline, fontSize: 15),),
                          )
                        
                        )

                      ],

                    )
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