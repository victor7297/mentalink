// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, use_super_parameters, depend_on_referenced_packages, prefer_final_fields, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_print, use_build_context_synchronously, body_might_complete_normally_nullable

import 'package:flutter/material.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetallesCuenta extends StatefulWidget {
  const DetallesCuenta({Key? key}) : super(key: key);

  @override
  _DetallesCuentaState createState() => _DetallesCuentaState();
}

class _DetallesCuentaState extends State<DetallesCuenta> {

  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _correoController;

  late bool _isLoading = false;

  Map<String, dynamic> usuarioData = {};

  String usuarioId = "";
  String nombre = "";
  String apellido = "";
  String correo = "";
  late RegExp regExp;

  TextEditingController nombreController = TextEditingController();
  TextEditingController apellidoController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  

  @override
  void initState() {

    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {

    nombreController.dispose();
    apellidoController.dispose();
    correoController.dispose();

    super.dispose();
  }

  Future<void> _fetchUserData() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int usuarioId = int.parse(prefs.getString('usuario_id') ?? '0');
    usuarioData = await Servicio().obtenerUsuario(usuarioId);

    if (usuarioId != 0) {

      final userData = await Servicio().obtenerUsuario(usuarioId);

      print(userData);

      setState(() {
        this.usuarioId = userData['usuario_id'];
        nombreController.text = userData['nombre'];
        apellidoController.text = userData['apellido'];
        correoController.text = userData['correo'];
      });

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la cuenta'),
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
                  controller: nombreController,
                  onSaved: (value) {
                    nombre = value!;
                  },
                  validator: (value) {

                    if(value!.isEmpty){

                      return "Complete este campo por favor";
                    }
                    else {
                      regExp = RegExp(r'^[A-Za-z\s]+$');

                      if (!regExp.hasMatch(value)) {
                  
                        return 'El nombre solo puede contener letras';
                      } 
                    }
                  },

                  decoration: InputDecoration(

                    labelText: "Nombre:",
                    border: OutlineInputBorder(),
              
                  ),

                ),
              ),

              Container(
                margin: EdgeInsets.only(bottom: 20.0),
                child: TextFormField(
                  controller: apellidoController,
                  onSaved: (value) {
                    apellido = value!;
                  },
                  validator: (value) {

                    if(value!.isEmpty){

                      return "Complete este campo por favor";
                    }
                    else {
                      regExp = RegExp(r'^[A-Za-z\s]+$');

                      if (!regExp.hasMatch(value)) {
                  
                        return 'El apellido solo puede contener letras';
                      } 
                    }
                
                  },

                  decoration: InputDecoration(

                    labelText: "Apellido:",
                    border: OutlineInputBorder(),
              
                  ),

                ),
              ),

              Container(
                margin: EdgeInsets.only(bottom: 20.0),
                child: TextFormField(
                  controller: correoController,
                  onSaved: (value) {
                    correo = value!;
                  },
                  validator: (value) {

                    if(value!.isEmpty){

                      return "Complete este campo por favor";
                    }
                    else {

                      regExp = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

                      if (!regExp.hasMatch(value)) {
                        return 'Formato de correo invalido';
                      } 
                    }
                
                  },

                  decoration: InputDecoration(

                    labelText: "Correo:",
                    border: OutlineInputBorder(),
              
                  ),

                ),
              ),

              Container(
                margin: EdgeInsets.only(bottom: 20.0),
                width: double.infinity,
                
                child: ElevatedButton(
                  onPressed: () async {

                    if(formKey.currentState!.validate()){

                      formKey.currentState!.save();

                      Map<String, String> data = {
                        "nombre": nombre,
                        "apellido": apellido,
                        "cedula": "",
                        "correo": correo,
                      };

                      Map<String, dynamic> respuesta = await Servicio().updateDatosUsuario(usuarioId, data);

                      print(respuesta);

                      if(respuesta['status'] == "success"){

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
              )

            ],
          )
        ),
      )
    );
  }
}

/**_isLoading
          ? Center(child: CircularProgressIndicator())
          
          : Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  TextField(
                    controller: _apellidoController,
                    decoration: InputDecoration(
                      labelText: 'Apellido',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  TextField(
                    controller: _correoController,
                    decoration: InputDecoration(
                      labelText: 'Correo',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),
                  
                  ElevatedButton(
                    onPressed: () async {

                      print("hola");
                      
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
                ],
              ),
            ), */
