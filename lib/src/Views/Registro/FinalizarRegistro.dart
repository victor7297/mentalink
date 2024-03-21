// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mentalink/src/Inicio.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:mentalink/src/Views/Login/Login.dart';



class FinalizarRegistro extends StatefulWidget {
  final String nombre;
  final String apellido;
  final String correo;
  final String contrasena;

  const FinalizarRegistro({
    Key? key,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.contrasena,
  }) : super(key: key);

  @override
  State<FinalizarRegistro> createState() => _FinalizarRegistroState();
}

class _FinalizarRegistroState extends State<FinalizarRegistro> {
  late DateTime _selectedDate;
  bool showCalendarIcon = true;
  String? _selectedSexo;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale("es"),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        showCalendarIcon = false;
      });
  }

  Registro() async {

    dynamic registro = await Servicio().registrarUsuario({
      "nombre": widget.nombre,
      "apellido": widget.apellido,
      "sexo": _selectedSexo ?? "",
      "fecha_nacimiento": "${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}",
      "correo": widget.correo,
      "contrasena": widget.contrasena,
      "perfil": "cliente"
    });

    String status = registro['status'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(status == "success" ? "Éxito" : "Error"),
          content: status == "success"
              ? Text(registro['message'])
              : Text(registro['error']['text']),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
                if (status == "success") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Inicio()),
                  );
                }
              },
            ),
          ],
        );
      },
    );

    
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    double containerWidth = screenWidth * 0.7;
    double containerHeight = screenHeight * 0.07;

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
                //margin: EdgeInsets.only(bottom: 5),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Sexo',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSexo,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedSexo = newValue;
                        });
                      },
                      items: <String>['Masculino', 'Femenino', 'Otro']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(fontSize: 14.0),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Container(
                width: containerWidth,
                height: containerHeight,
                margin: EdgeInsets.only(bottom: 10),
                child: TextField(
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Fecha de nacimiento',
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                    suffixIcon: showCalendarIcon
                        ? IconButton(
                            icon: Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          )
                        : null,
                  ),
                  controller: TextEditingController(
                    text: showCalendarIcon
                        ? ''
                        : '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: containerWidth,
                height: containerHeight,
                margin: EdgeInsets.only(bottom: 15),
                child: ElevatedButton(
                  onPressed: Registro,
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
                    'Finalizar Registro',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Ya tengo una cuenta',
                style: TextStyle(
                  color: Color.fromARGB(255, 56, 55, 58),
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
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
