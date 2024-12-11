import 'package:flutter/material.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestAsertividad extends StatefulWidget {
  const TestAsertividad({Key? key}) : super(key: key);

  @override
  State<TestAsertividad> createState() => _TestAsertividadState();
}

class _TestAsertividadState extends State<TestAsertividad> {
  final _formKey = GlobalKey<FormState>();
  final PageController _paginaController = PageController();
  int? usuarioId;
  final List<String> _preguntas = [
    'Mucha gente parece ser más agresiva que yo.',
    'He dudado en solicitar o aceptar citas por timidez.',
    'Cuando la comida que me han servido en un restaurante no está hecha a mi gusto me quejo al camarero.',
    'Me esfuerzo en evitar ofender los sentimientos de otras personas aun cuando me hayan molestado.',
    'Cuando un vendedor se ha molestado mucho mostrando un producto que luego no me agrada, paso un mal rato al decir "no".',
    'Cuando me dicen que haga algo, insisto en saber por qué.',
    'Hay veces en que provoco abiertamente una discusión.',
    'Lucho, como la mayoría de la gente, por mantener mi posición.',
    'En realidad, la gente se aprovecha con frecuencia de mí.',
    'Disfruto entablando conversación con conocidos y extraños.',
    'Con frecuencia no sé qué decir a personas atractivas del otro sexo.',
    'Rehúyo telefonear a instituciones y empresas.',
    'En caso de solicitar un trabajo o la admisión en una institución preferiría escribir cartas a realizar entrevistas personales.',
    'Me resulta embarazoso devolver un artículo comprado.',
    'Si un pariente cercano o respetable me molesta, prefiero ocultar mis sentimientos antes que expresar mi disgusto.',
    'He evitado hacer preguntas por miedo a parecer tonto(a).',
    'Durante una discusión, con frecuencia temo alterarme tanto como para ponerme a temblar.',
    'Si un eminente conferenciante hiciera una afirmación que considero incorrecta, yo expondría públicamente mi punto de vista.',
    'Evito discutir sobre precios con dependientes o vendedores.',
    'Cuando he hecho algo importante o meritorio, trato de que los demás se enteren de ello.',
    'Soy abierto y franco en lo que respecta a mis sentimientos.',
    'Si alguien ha hablado mal de mi o me ha atribuido hechos falsos, o la busco cuanto antes para dejar las cosas claras.',
    'Con frecuencia paso un mal rato al decir "no".',
    'Suelo reprimir mis emociones antes de hacer una escena.',
    'En el restaurante o en cualquier sitio semejante, protesto por un mal servicio.',
    'Cuando me alaban con frecuencia, no sé qué responder.',
    'Si dos personas en el teatro o en una conferencia están hablando demasiado alto, les digo que se callen o que se vayan a hablar a otra parte.',
    'Si alguien se me cuela en una fila, le llamo abiertamente la atención.',
    'Expreso mis opiniones con facilidad.',
    'Hay ocasiones en que soy incapaz de decir nada.',
  ];

  final Map<int, int?> _respuestas = {};

  static const List<String> _opciones = [
    '+3 Muy característico de mí, extremadamente descriptivo.',
    '+2 Bastante característico de mí, bastante descriptivo.',
    '+1 Algo característico de mí, ligeramente descriptivo.',
    '-1 Algo no característico de mí, ligeramente no descriptivo.',
    '-2 Bastante poco característico de mí, no descriptivo.',
    '-3 Muy poco característico de mí, extremadamente no descriptivo.',
  ];

  @override
  void initState() {
    super.initState();
    _cargarRespuestas();
  }

  Future<void> _cargarRespuestas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? usuarioIdString = prefs.getString('usuario_id');

    if (usuarioIdString == null || usuarioIdString.isEmpty) {
      // Manejo del caso cuando usuario_id no está disponible o es vacío
      return;
    }

    usuarioId = int.tryParse(usuarioIdString);
    if (usuarioId == null) {
      // Manejo del caso cuando usuario_id no se puede convertir a int
      return;
    }

    var resultado = await Servicio().TestAsertividadRespuestas(usuarioId!);

    final respuestasProcesadas = Map<int, int?>.fromIterable(
      List.generate(_preguntas.length, (index) => index),
      key: (index) => index,
      value: (index) {
        final respuesta = resultado['p${index + 1}'] ?? '0';
        return int.tryParse(respuesta);
      },
    );

    setState(() {
      _respuestas.addAll(respuestasProcesadas);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test Asertividad',
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
            return _widgetPaginacion(pageIndex);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _submit();
        },
        backgroundColor: Color.fromRGBO(9, 25, 87, 1.0),
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _widgetPaginacion(int pageIndex) {
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
            'Indica, mediante el código siguiente, hasta qué punto te describen o caracterizan cada una de las frases siguientes:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
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
            '${index + 1}. $question',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          ..._widgetOpciones(index),
          Divider(color: Colors.grey[300], thickness: 1),
        ],
      ),
    );
  }

  List<Widget> _widgetOpciones(int preguntaIndex) {
    final opcionesNumericas = [3, 2, 1, -1, -2, -3];
    return opcionesNumericas
        .asMap()
        .map((index, valor) => MapEntry(
              index,
              RadioListTile<int>(
                title: Text(_opciones[index]),
                value: valor,
                groupValue: _respuestas[preguntaIndex],
                onChanged: (value) {
                  setState(() {
                    _respuestas[preguntaIndex] = value;
                    if (value != null && usuarioId != null) {
                      Servicio().enviarRespuestaTestAsertividad(preguntaIndex, value, usuarioId!);
                    }
                  });
                },
              ),
            ))
        .values
        .toList();
  }

  void _submit() {
    final paginaActualIndex = _paginaController.page?.round() ?? 0;
    final start = paginaActualIndex * 10;
    final end = (start + 10) < _preguntas.length ? start + 10 : _preguntas.length;

    final allQuestionsOnPageAnswered = _preguntas.sublist(start, end).every((question) {
      final questionIndex = _preguntas.indexOf(question);
      return _respuestas.containsKey(questionIndex);
    });

    if (!allQuestionsOnPageAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, responde todas las preguntas en esta página.')),
      );
    } else if (paginaActualIndex < (_preguntas.length / 10).ceil() - 1) {
      _paginaController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else if (_respuestas.length == _preguntas.length) {
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
