import 'package:flutter/material.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestDesesperanza extends StatefulWidget {
  const TestDesesperanza({Key? key}) : super(key: key);

  @override
  State<TestDesesperanza> createState() => _TestDesesperanzaState();
}

class _TestDesesperanzaState extends State<TestDesesperanza> {
  final _formKey = GlobalKey<FormState>();
  final PageController _paginaController = PageController();
  String usuarioId = "";
  final List<String> _preguntas = [
    'Espero el futuro con esperanza y entusiasmo.',
    'Puedo darme por vencido y renunciar ya que no puedo hacer mejor las cosas por mi mismo.',
    'Cuando las cosas van mal, me alivia saber que no van a estar mucho tiempo así.',
    'No puedo imaginar como será mi vida dentro de diez años.',
    'Tengo bastante tiempo para llevar a cabo las cosas que quisiera poder hacer.',
    'En el futuro, espero conseguir lo que me pueda interesar.',
    'Mi futuro me parece oscuro.',
    'En la vida, espero lograr más cosas buenas que la mayoría de la gente.',
    'En realidad, no puedo estar bien, y no hay razón para estarlo en el futuro.',
    'Mis experiencias pasadas me han preparado bien para el futuro.',
    'Más que bienestar, todo lo que veo delante de mí son dificultades.',
    'No espero conseguir lo que realmente quiero.',
    'Cuando miro hacia el futuro espero ser más feliz de lo que soy ahora.',
    'Las cosas no marchan como yo quisiera.',
    'Tengo gran confianza en el futuro.',
    'Como nunca logro lo que quiero, es una locura creer algo.',
    'Es poco probable que pueda lograr una satisfacción real en el futuro.',
    'El futuro me parece vago e incierto.',
    'Espero tiempos mejores que peores.',
    'No hay razón para tratar de conseguir algo deseado pues, probablemente no lo logre.',
  ];

  final Map<int, int?> _respuestas = {};

  static const List<String> _opciones = [
    'Verdadero',
    'Falso',
  ];

  @override
  void initState() {
    super.initState();
    _cargarRespuestas();
  }

  Future<void> _cargarRespuestas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    usuarioId = prefs.getString('usuario_id') ?? "0";

    var resultado = await Servicio().TestDesesperanzaRespuestas(int.parse(usuarioId));

    final respuestasProcesadas = Map<int, int?>.fromIterable(
      List.generate(_preguntas.length, (index) => index),
      key: (index) => index,
      value: (index) {
        final respuesta = resultado['p${index + 1}'];
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
          'Test Desesperanza',
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
          itemCount: (_preguntas.length / 5).ceil(),
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
    final start = pageIndex * 5;
    final end = (start + 5) < _preguntas.length ? start + 5 : _preguntas.length;
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
            'Por favor, lee atentamente cada declaración y selecciona:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '• Si la declaración es Verdadera para ti, selecciona Verdadero.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '• Si la declaración es Falsa para ti, selecciona Falso.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
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
          SizedBox(height: 20),
          _widgetOpciones(index),
          Divider(color: Colors.grey[300], thickness: 1),
        ],
      ),
    );
  }

  Widget _widgetOpciones(int preguntaIndex) {
    final opcionesValores = [1, 0]; // Verdadero es 1, Falso es 0
    final respuesta = _respuestas[preguntaIndex];

    return Container(
      height: 80,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3,
          crossAxisSpacing: 2.0,
          mainAxisSpacing: 2.0,
        ),
        itemCount: opcionesValores.length,
        itemBuilder: (context, index) {
          final valor = opcionesValores[index];
          return Card(
            elevation: 5.0,
            child: ListTile(
              leading: Radio<int>(
                value: valor,
                groupValue: respuesta,
                onChanged: (value) {
                  setState(() {
                    _respuestas[preguntaIndex] = value;
                    if (value != null) {
                      Servicio().enviarRespuestaTestDesesperanza(preguntaIndex, value, int.parse(usuarioId));
                    }
                  });
                },
              ),
              title: Text(_opciones[index]),
            ),
          );
        },
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
      ),
    );
  }

  void Submit() {
    final paginaActualIndex = _paginaController.page?.round() ?? 0;
    final start = paginaActualIndex * 5;
    final end = (start + 5) < _preguntas.length ? start + 5 : _preguntas.length;

    final allQuestionsOnPageAnswered = _preguntas.sublist(start, end).every((question) {
      final questionIndex = _preguntas.indexOf(question);
      return _respuestas.containsKey(questionIndex) && _respuestas[questionIndex] != -1;
    });

    if (!allQuestionsOnPageAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, responde todas las preguntas en esta página.')),
      );
    } else if (paginaActualIndex < (_preguntas.length / 5).ceil() - 1) {
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
