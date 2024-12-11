import 'package:flutter/material.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestAnsiedad extends StatefulWidget {
  const TestAnsiedad({super.key});

  @override
  State<TestAnsiedad> createState() => _TestAnsiedadState();
}

class _TestAnsiedadState extends State<TestAnsiedad> {
  final _formKey = GlobalKey<FormState>();
  String usuarioId = "";
  final PageController paginaController = PageController();

  final List<String> preguntas = [
    'Torpe o entumecido.',
    'Acalorado.',
    'Con temblor en las piernas.',
    'Incapaz de relajarse.',
    'Con temor a que ocurra lo peor.',
    'Mareado, o que se le va la cabeza.',
    'Con latidos del corazón fuertes y acelerados.',
    'Inestable.',
    'Atemorizado o asustado.',
    'Con sensación de bloqueo.',
    'Con temblores en las manos.',
    'Inquieto, inseguro.',
    'Con miedo a perder el control.',
    'Con sensación de ahogo.',
    'Con temor a morir.',
    'Con miedo.',
    'Con problemas digestivos.',
    'Con desvanecimientos.',
    'Con rubor facial.',
    'Con sudores, fríos o calientes.'
  ];

  final Map<int, int?> respuestas = {};

  static const List<String> opciones = [
    'No',
    'Leve',
    'Moderado',
    'Bastante',
  ];

  @override
  void initState() {
    super.initState();
    _cargarRespuestas();
  }

  Future<void> _cargarRespuestas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    usuarioId = prefs.getString('usuario_id') ?? "0";

    final userId = int.tryParse(usuarioId) ?? 0;

    var resultado = await Servicio().TestAnsiedadRespuestas(userId);

    print("Resultado del servicio: $resultado");

    final respuestasProcesadas = <int, int?>{};
    
    for (int i = 0; i < preguntas.length; i++) {
      for (int j = 0; j < opciones.length; j++) {
        final respuestaKey = 'p${i + 1}_$j';  // El índice de la pregunta comienza en 1
        final respuesta = resultado[respuestaKey];
        if (respuesta != null) {
          final respuestaValor = int.tryParse(respuesta);
          if (respuestaValor != null && respuestaValor >= 0 && respuestaValor < opciones.length) {
            respuestasProcesadas[i] = respuestaValor;
            break;  // Salir del bucle si ya se encontró una respuesta
          } else {
            respuestasProcesadas[i] = null;  // Respuesta inválida
          }
        } else {
          respuestasProcesadas[i] = null;  // Pregunta no respondida
        }
      }
    }

    setState(() {
      respuestas.addAll(respuestasProcesadas);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test Ansiedad',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(9, 25, 87, 1.0),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushNamed("/testEvaluativo");
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PageView.builder(
          controller: paginaController,
          itemCount: (preguntas.length / 10).ceil(),
          itemBuilder: (context, pageIndex) {
            return widgetPaginacion(pageIndex);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Submit();
        },
        backgroundColor: Color.fromRGBO(9, 25, 87, 1.0),
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget widgetPaginacion(int pageIndex) {
    final start = pageIndex * 10;
    final end = (start + 10) < preguntas.length ? start + 10 : preguntas.length;
    final questionsForPage = preguntas.sublist(start, end);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetInstrucciones(),
          ...questionsForPage
              .asMap()
              .entries
              .map((entry) => widgetPreguntas(
                    index: start + entry.key,
                    question: entry.value,
                    margenT: entry.key == 0,
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget WidgetInstrucciones() {
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
            'Por favor, lee atentamente cada declaración y selecciona el grado en que sientes que se aplica a ti: \n',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            '•  Si la declaración se aplica completamente a cómo te sientes, selecciona "Bastante".',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '• Si la declaración se aplica en cierta medida a cómo te sientes, selecciona "Moderado".',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '• Si la declaración se aplica en un grado bajo a cómo te sientes, selecciona "Leve".',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '• Si la declaración no se aplica a cómo te sientes, selecciona "No".',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget widgetPreguntas({required int index, required String question, required bool margenT}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0).copyWith(top: margenT ? 24.0 : 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}. $question',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          ...widgetOpciones(index),
          Divider(color: Colors.grey[300], thickness: 1),
        ],
      ),
    );
  }

  List<Widget> widgetOpciones(int preguntaIndex) {
    return opciones
        .asMap()
        .map((index, opcion) => MapEntry(
              index,
              RadioListTile<int>(
                title: Text(opcion),
                value: index,  // Enviar 0, 1, 2, 3
                groupValue: respuestas[preguntaIndex],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      respuestas[preguntaIndex] = value;
                      Servicio().enviarRespuestaTestAnsiedad(preguntaIndex, value, int.tryParse(usuarioId) ?? 0);
                    });
                  }
                },
              ),
            ))
        .values
        .toList();
  }

  void Submit() {
    final paginaActualIndex = paginaController.page?.round() ?? 0;
    final start = paginaActualIndex * 10;
    final end = (start + 10) < preguntas.length ? start + 10 : preguntas.length;

    final allQuestionsOnPageAnswered = preguntas.sublist(start, end).every((question) {
      final questionIndex = preguntas.indexOf(question);
      return respuestas[questionIndex] != null;
    });

    if (!allQuestionsOnPageAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, responde todas las preguntas en esta página.')),
      );
    } else if (paginaActualIndex < (preguntas.length / 10).ceil() - 1) {
      paginaController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else if (respuestas.length == preguntas.length) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Enviado'),
          content: Text('Tus respuestas han sido enviadas a tu Psicólogo, gracias.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/testEvaluativo');
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, responde todas las preguntas.')),
      );
    }
  }
}
