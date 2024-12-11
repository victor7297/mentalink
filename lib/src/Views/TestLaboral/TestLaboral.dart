import 'package:flutter/material.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestLaboral extends StatefulWidget {
  const TestLaboral({super.key});

  @override
  State<TestLaboral> createState() => _TestLaboralState();
}

class _TestLaboralState extends State<TestLaboral> {
  final _formKey = GlobalKey<FormState>();
  final PageController _paginaController = PageController();
  String usuarioId = "";

  final List<String> _preguntas = [
    'Me siento emocionalmente defraudado de mi trabajo.',
    'Cuando termino mi jornada de trabajo me siento agotado.',
    'Cuando me levanto por la mañana y me enfrento a otra jornada de trabajo me siento fatigado.',
    'Siento que puedo comunicarme fácilmente con las personas que tengo que relacionarme con el trabajo.',
    'Siento que estoy tratando a algunos de mis subordinados como si fueran objetos impersonales.',
    'Siento que tratar todo el día con la gente me cansa.',
    'Siento que trato, con mucha efectividad, los problemas de las personas a las que tengo que atender(dirigir).',
    'Siento que mi trabajo me está desgastando.',
    'Siento que estoy influyendo en la vida de otras personas a través de mi trabajo.',
    'Siento que mi trato con la gente es más duro.',
    'Me preocupa que este trabajo me está endureciendo emocionalmente.',
    'Me siento muy enérgico en mi trabajo.',
    'Me siento frustrado por mi trabajo.',
    'Siento que estoy demasiado tiempo en mi trabajo.',
    'Siento indiferencia ante el resultado del trabajo de mis subordinados (o personas que atiendo profesionalmente).',
    'Siento que trabajar en contacto directo con la gente me cansa.',
    'Siento que puedo crear con facilidad un clima agradable en mi trabajo.',
    'Me siento estimulado después de haber trabajado estrechamente.',
    'Creo que consigo muchas cosas valiosas en este trabajo.',
    'Me siento como si estuviera en el límite de mis posibilidades.',
    'Siento que en mi trabajo los problemas emocionales son tratados de forma adecuada.',
    'Me parece que mis subordinados me culpan de algunos de sus problemas.',
  ];

  final Map<int, int?> _respuestas = {};

  static const List<String> _opciones = [
    'Nunca',
    'Algunas veces al año',
    'Algunas veces al mes',
    'Algunas veces a la semana puede comenzar',
    'Diariamente'
  ];

  @override
  void initState() {
    super.initState();
    _cargarRespuestas();
  }

  Future<void> _cargarRespuestas() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  usuarioId = prefs.getString('usuario_id') ?? "0";

  var resultado = await Servicio().TestLaboralRespuestas(int.tryParse(usuarioId) ?? 0);

  final respuestasProcesadas = <int, int?>{};

  for (int i = 0; i < _preguntas.length; i++) {
    for (int j = 0; j < _opciones.length; j++) {
      final key = 'p${i + 1}_$j';
      final respuesta = resultado[key];
      if (respuesta != null && respuesta == '1') {
        respuestasProcesadas[i] = j;
        break;
      }
    }
  }

  setState(() {
    _respuestas.addAll(respuestasProcesadas);
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test Estrés Laboral',
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
          controller: _paginaController,
          itemCount: (_preguntas.length / 10).ceil(),
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
    final end = (start + 10) < _preguntas.length ? start + 10 : _preguntas.length;
    final questionsForPage = _preguntas.sublist(start, end);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _widgetInstrucciones(),
          ...questionsForPage
              .asMap()
              .entries
              .map((entry) => _widgetPreguntas(
                    index: start + entry.key,
                    question: entry.value,
                    margenT: entry.key == 0,
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _widgetInstrucciones() {
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
            'A continuación, encontrará una serie de enunciados acerca de su trabajo y sus sentimientos en él.\n',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          Text(
            'A cada una de las frases deberá responder expresando la frecuencia con que tiene ese sentimiento.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          for (var opcion in _opciones) ...[
            Text(
              '• $opcion',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _widgetPreguntas({required int index, required String question, required bool margenT}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0).copyWith(top: margenT ? 24.0 : 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}. $question',  // Mostrar el número de la pregunta
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
    return _opciones
        .asMap()
        .map((index, opcion) => MapEntry(
              index,
              RadioListTile<int>(
                title: Text(opcion),
                value: index,  // Enviar 0, 1, 2, 3
                groupValue: _respuestas[preguntaIndex],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _respuestas[preguntaIndex] = value;
                      Servicio().enviarRespuestaTestLaboral(preguntaIndex, value, int.tryParse(usuarioId) ?? 0);
                    });
                  }
                },
              ),
            ))
        .values
        .toList();
  }

  void Submit() {
    final paginaActualIndex = (_paginaController.page ?? 0).round();
    final start = paginaActualIndex * 10;
    final end = (start + 10) < _preguntas.length ? start + 10 : _preguntas.length;

    print('Página actual: $paginaActualIndex');
    print('Inicio: $start, Fin: $end');
    print('Preguntas en esta página: ${_preguntas.sublist(start, end)}');

    final allQuestionsOnPageAnswered = _preguntas.sublist(start, end).every((question) {
      final questionIndex = _preguntas.indexOf(question);
      final isAnswered = _respuestas.containsKey(questionIndex) && _respuestas[questionIndex] != null;
      
      print('Pregunta $questionIndex respondida: $isAnswered');
      
      return isAnswered;
    });

    if (!allQuestionsOnPageAnswered) {
      print('No todas las preguntas en la página actual han sido respondidas');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, responde todas las preguntas en esta página.')),
      );
    } else if (paginaActualIndex < (_preguntas.length / 10).ceil() - 1) {
      print('Avanzar a la siguiente página');
      _paginaController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else if (_respuestas.length == _preguntas.length) {
      print('Todas las preguntas han sido respondidas');
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
      print('No todas las preguntas han sido respondidas');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, responde todas las preguntas.')),
      );
    }
  }
}
