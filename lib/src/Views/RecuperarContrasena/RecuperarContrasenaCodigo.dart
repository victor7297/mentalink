// ignore_for_file: library_private_types_in_public_api, use_super_parameters, unused_element, prefer_const_constructors, unnecessary_new, avoid_unnecessary_containers, empty_statements

import 'package:flutter/material.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';

class RecuperarContrasenaCodigo extends StatefulWidget {

  final String correo;
  const RecuperarContrasenaCodigo({Key? key, required this.correo})
      : super(key: key);

  @override
  _RecuperarContrasenaCodigoState createState() =>
      _RecuperarContrasenaCodigoState();
}

class _RecuperarContrasenaCodigoState extends State<RecuperarContrasenaCodigo> {

  final TextEditingController _contrasenaController = TextEditingController();

  late List<TextEditingController> _controllers;

  bool _passwordValid = true;
  bool _mostrarContrasena = false;
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (index) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }


  void _validatePassword(String value) {
  bool hasUppercase = value.contains(new RegExp(r'[A-Z]'));
  bool hasDigits = value.contains(new RegExp(r'[0-9]'));

  setState(() {
    _passwordValid = hasUppercase && hasDigits;
  });
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
                SizedBox(height: 20.0),
                Text(
                  'Ingrese el código de verificación:',
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6,
                    (index) => SizedBox(
                      width: 40,
                      child: TextField(
                        controller: _controllers[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        onChanged: (value) {

                          if (value.isEmpty && index > 0) {

                            FocusScope.of(context).previousFocus();

                          } else if (value.isNotEmpty && index < 5) {

                            FocusScope.of(context).nextFocus();
                          }
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(vertical: 6),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 0, 188, 207)),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color.fromARGB(255, 0, 188, 207)),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        cursorColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.0),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextFormField(
                    controller: _contrasenaController,
                    obscureText: !_mostrarContrasena,
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
                          _mostrarContrasena
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _mostrarContrasena = !_mostrarContrasena;
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

                cargando ? Container(child: CircularProgressIndicator(color: Colors.blue,),): Container(),

                Container(

                  margin: EdgeInsets.symmetric(vertical: 20),
                  width: MediaQuery.of(context).size.width * 0.7,
                  
                  child: ElevatedButton(

                    onPressed: () async{

                      RegExp exp = RegExp(r'^(?=.*[A-Z])(?=.*\d).+$');
                      int i;
                      String codigo = "";

                      for(i=0; i < _controllers.length; i++){

                        codigo = codigo + _controllers[i].text.toString();

                      };

                      if(_contrasenaController.text != "" && codigo != ""){

                        if (exp.hasMatch(_contrasenaController.text)) {

                          setState(() {
                            cargando = true;
                          });

                          Map<String, dynamic> data = {

                            "correo": widget.correo,
                            "codigo_recuperacion": codigo,
                            "nueva_contrasena": _contrasenaController.text,
                            "confirmacion_contrasena": _contrasenaController.text
                          };

                          var respuesta = await Servicio().actualizarPassword(data);

                          if(respuesta['status'] == "success"){

                            setState(() {
                              cargando = false;
                            });

                            final snackBar = SnackBar(
                              content: Text(
                                'Contraseña actualizada correctamente.',
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

                            // Usa un Timer para esperar el tiempo que durará el SnackBar
                            Future.delayed(snackBar.duration ?? Duration(seconds: 2), () {

                              Navigator.of(context).pushNamed("/login");
                              
                            });
                          }
                          else{

                            setState(() {
                              cargando = false;
                            });

                            final snackBar = SnackBar(
                              content: Text(
                                'Código de recuperación incorrecto, puede que el código de recuperación ya se utilizó.',
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

                          }

                        } 
                        else {

                          final snackBar = SnackBar(
                            content: Text(
                              'La contraseña no cumple con el formato.',
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
                        }

                      }
                      else{

                        final snackBar = SnackBar(
                          content: Text(
                            'Complete todos los campos por favor.',
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
                      }

                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                            width: 2.0, color: Color.fromARGB(255, 0, 188, 207)),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Cambiar Contraseña',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
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
