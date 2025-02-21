// widget_instrucciones.dart
import 'package:flutter/material.dart';

class WidgetInstruccionesTestCooper extends StatelessWidget {
  const WidgetInstruccionesTestCooper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Instrucciones Generales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'A continuación te presentamos unas frases (Declaraciones).\n',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            '• Si la frase describe cómo te sientes, selecciona "Igual que yo".',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '• Si la frase NO describe cómo te sientes, selecciona "Distinto a mí".',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
