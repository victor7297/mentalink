import 'package:flutter/material.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetallesCuentaEspecialista extends StatefulWidget {
  const DetallesCuentaEspecialista({Key? key}) : super(key: key);

  @override
  _DetallesCuentaEspecialistaState createState() => _DetallesCuentaEspecialistaState();
}

class _DetallesCuentaEspecialistaState extends State<DetallesCuentaEspecialista> {

  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _correoController;
  late TextEditingController _fvpController;
  late TextEditingController _especialidadController;
  late TextEditingController _biografiaController;

  late bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _apellidoController = TextEditingController();
    _correoController = TextEditingController();
    _fvpController = TextEditingController();
    _especialidadController = TextEditingController();
    _biografiaController = TextEditingController();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _fvpController.dispose();
    _especialidadController.dispose();
    _biografiaController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int usuarioId = int.parse(prefs.getString('usuario_id') ?? '0');

    if (usuarioId != 0) {
      final userData = await Servicio().obtenerInformacionUsuarioEspecialista(usuarioId);
      setState(() {
        _nombreController.text = userData['nombre'];
        _apellidoController.text = userData['apellido'];
        _correoController.text = userData['correo'];
        _fvpController.text = userData['fvp'];
        _especialidadController.text = userData['especialidad'];
        _biografiaController.text = userData['biografia'];

      });
    }
  }

  /*Future<bool> actualizarInformacion() async {
    
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la cuenta'),
      ),
      body: _isLoading
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

                  TextField(
                    controller: _fvpController,
                    decoration: InputDecoration(
                      labelText: 'Fvp',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  TextField(
                    controller: _especialidadController,
                    decoration: InputDecoration(
                      labelText: 'Especialidad',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  SizedBox(height: 20),

                  TextField(
                    controller: _biografiaController,
                    decoration: InputDecoration(
                      labelText: 'Biografía',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      
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
            ),
    );
  }
}
