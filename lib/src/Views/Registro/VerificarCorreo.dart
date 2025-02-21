import 'package:flutter/material.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';

class VerificarCorreo extends StatefulWidget {
  final String nombre;
  final String apellido;
  final String correo;
  final String contrasena;

  const VerificarCorreo({
    Key? key,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.contrasena,
  }) : super(key: key);

  @override
  State<VerificarCorreo> createState() => _VerificarCorreoState();
}

class _VerificarCorreoState extends State<VerificarCorreo> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  bool _codigoValido = true;
  bool cargando = false;

  @override
  void initState() {
    super.initState();
  }

  bool _validarCodigo() {
    for (var controller in _controllers) {
      if (controller.text.isEmpty) {
        return false;
      }
    }
    return true;
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
                // Logo
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
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 40,
                      child: TextField(
                        controller: _controllers[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(color: Colors.white),
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
                          errorText: !_codigoValido ? 'El código es inválido' : null,
                        ),
                        cursorColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),

                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: cargando
                      ? Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              cargando = true;
                            });

                            if (_validarCodigo()) {

                              String codigo = _controllers.map((controller) => controller.text).join();

                              var data = {
                                'codigo_recuperacion': codigo,
                                'correo': widget.correo,
                              };

                              var respuesta = await Servicio().verificarCorreoCodigo(data);

                              setState(() {
                                cargando = false;
                              });

                              if (respuesta['status'] == 'success') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      respuesta['message'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: Color.fromARGB(255, 0, 188, 207),
                                  ),
                                );

                                Navigator.pushNamed(context, '/login');

                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      respuesta['message'] ?? 'Error al enviar el código de verificación',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } else {
                              setState(() {
                                _codigoValido = false;
                              });
                              setState(() {
                                cargando = false;
                              });
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
                            'Continuar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
