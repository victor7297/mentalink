import 'package:flutter/material.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestBDI extends StatefulWidget {
  const TestBDI({super.key});

  @override
  State<TestBDI> createState() => _TestBDIState();
}

class _TestBDIState extends State<TestBDI> {
  final _formKey = GlobalKey<FormState>();
  String usuarioId = "";
  final PageController paginaController = PageController(); // Define el controlador de página

  final List<String> preguntas = [
    'Tristeza.',
    'Pesimismo.',
    'Fracaso.',
    'Pérdida de placer.',
    'Sentimientos de culpa.',
    'Sentimientos de castigo.',
    'Disconformidad con uno mismo.',
    'Autocrítica.',
    'Pensamientos o deseos suicidas.',
    'Llanto.',
    'Agitación.',
    'Pérdida de interés.',
    'Indecisión.',
    'Desvalorización.',
    'Pérdida de energía.',
    'Cambios en los Hábitos de sueño.',
    'Irritabilidad.',
    'Cambios en el Apetito.',
    'Dificultad de concentración.',
    'Cansancio o fatiga.',
    'Pérdida de interés en el sexo.'
  ];

  final Map<int, int?> respuestas = {};

  final Map<int, List<String>> opcionesPorPregunta = {
    0: ['No me siento triste.', 'Me siento triste gran parte del tiempo.', 'Estoy triste todo el tiempo.', 'Estoy tan triste o soy tan infeliz que no puedo soportarlo.'],
    1: ['No estoy desalentado respecto de mi futuro.', 'Me siento más desalentado respecto de mi futuro que lo que solía estarlo.', 'No espero que las cosas funcionen para mí.', 'Siento que no hay esperanza para mi futuro y que sólo puede empeorar.'],
    2: ['No me siento como un fracasado.', 'He fracasado más de lo que hubiera debido.', 'Cuando miro hacia atrás veo muchos fracasos.', 'Siento que como persona soy un fracaso total.'],
    3: ['Obtengo tanto placer siempre por las cosas de las que disfruto.', 'No disfruto tanto de las cosas como solía hacerlo.', 'Obtengo muy poco placer de las cosas de las que solía disfrutar.', 'No puedo obtener ningún placer de las cosas de las que solía disfrutar.'],
    4: ['No me siento particularmente culpable.', 'Me siento culpable respecto de varias cosas que he hecho o que debería haber hecho.', 'Me siento bastante culpable la mayor parte del tiempo.', 'Me siento culpable todo el tiempo.'],
    5: ['No siento que estoy siendo castigado.', 'Siento que tal vez pueda ser castigado.', 'Espero ser castigado.', 'Siento que estoy siendo castigado.'],
    6: ['Siento acerca de mí lo mismo que siempre.', 'He perdido la confianza en mí mismo.', 'Estoy decepcionado conmigo mismo.', 'No me gusto a mí mismo.'],
    7: ['No me critico ni me culpo más de lo habitual.', 'Estoy más crítico conmigo mismo de lo que solía estarlo.', 'Me critico a mí mismo por todos mis errores.', 'Me culpo a mí mismo por todo lo malo que sucede.'],
    8: ['No tengo ningún pensamiento de matarme.', 'He tenido pensamientos de matarme, pero no lo haría.', 'Querría matarme.', 'Me mataría si tuviera la oportunidad de hacerlo.'],
    9: ['No lloro más de lo que solía hacerlo.', 'Lloro más de lo que solía hacerlo.', 'Lloro por cualquier pequeñez.', 'Siento ganas de llorar pero no puedo.'],
    10: ['No estoy más inquieto o tenso que lo habitual.', 'Me siento más inquieto o tenso que lo habitual.', 'Estoy tan inquieto o agitado que me es difícil quedarme quieto.', 'Estoy tan inquieto o agitado que tengo que estar siempre en movimiento o haciendo algo.'],
    11: ['No he perdido el interés en otras actividades o personas.', 'Estoy menos interesado que antes en otras personas o cosas.', 'He perdido casi todo el interés en otras personas o cosas.', 'Me es difícil interesarme por algo.'],
    12: ['Tomo mis decisiones tan bien como siempre.', 'Me resulta más difícil que de costumbre tomar decisiones.', 'Encuentro mucha más dificultad que antes para tomar decisiones.', 'Tengo problemas para tomar cualquier decisión.'],
    13: ['No siento que yo no sea valioso.', 'No me considero a mí mismo tan valioso y útil como solía considerarme.', 'Me siento menos valioso cuando me comparo con otros.', 'Siento que no valgo nada.'],
    14: ['Tengo tanta energía como siempre.', 'Tengo menos energía que la que solía tener.', 'No tengo suficiente energía para hacer demasiado.', 'No tengo energía suficiente para hacer nada.'],
    15: ['No he experimentado ningún cambio en mis hábitos de sueño.', '1a. Duermo un poco más que lo habitual.', '1b. Duermo un poco menos que lo habitual.', '2a. Duermo mucho más que lo habitual.', '2b. Duermo mucho menos que lo habitual.', '3a. Duermo la mayor parte del día.', '3b. Me despierto 1-2 horas más temprano y no puedo volver a dormirme.'],
    16: ['No estoy más irritable que lo habitual.', 'Estoy más irritable que lo habitual.', 'Estoy mucho más irritable que lo habitual.', 'Estoy irritable todo el tiempo.'],
    17: ['No he experimentado ningún cambio en mi apetito.', '1a. Mi apetito es un poco menor que lo habitual.', '1b. Mi apetito es un poco mayor que lo habitual.', '2a. Mi apetito es mucho menor que antes.', '2b. Mi apetito es mucho mayor que lo habitual.', '3a. No tengo apetito en absoluto.', '3b. Quiero comer todo el tiempo.'],
    18: ['Puedo concentrarme tan bien como siempre.', 'No puedo concentrarme tan bien como habitualmente.', 'Me es difícil mantener la mente en algo por mucho tiempo.', 'Encuentro que no puedo concentrarme en nada.'],
    19: ['No estoy más cansado o fatigado que lo habitual.', 'Me fatigo o me canso más fácilmente que lo habitual.', 'Estoy demasiado fatigado o cansado para hacer muchas de las cosas que solía hacer.', 'Estoy demasiado fatigado o cansado para hacer la mayoría de las cosas que solía hacer.'],
    20: ['No he notado ningún cambio reciente en mi interés por el sexo.', 'Estoy menos interesado en el sexo de lo que solía estarlo.', 'Ahora estoy mucho menos interesado en el sexo.', 'He perdido completamente el interés en el sexo.']
  };

  @override
  void initState() {
    super.initState();
    _cargarRespuestas();
  }

  Future<void> _cargarRespuestas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    usuarioId = prefs.getString('usuario_id') ?? "0";

    var resultado = await Servicio().TestBDIRespuestas(int.tryParse(usuarioId) ?? 0);

    final respuestasProcesadas = <int, int?>{};

    for (int i = 0; i < preguntas.length; i++) {
      for (int j = 0; j < opcionesPorPregunta[i]!.length; j++) {
        final key = 'p${i + 1}_$j';
        final respuesta = resultado[key];
        if (respuesta != null && respuesta == '1') {
          respuestasProcesadas[i] = j;
          break;
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
          'Test BDI',
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
          itemCount: (preguntas.length / 7).ceil(), // Ajusta la cantidad de páginas según el número de preguntas por página
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
    final start = pageIndex * 7;
    final end = (start + 7) < preguntas.length ? start + 7 : preguntas.length;
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
                    margenT: entry.key == 0, // Indica si es la primera pregunta en la página actual
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
            '• Lee los enunciados y selecciona la opción que mejor describa el modo como te has sentido las últimas dos semanas (incluyendo hoy)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
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
            '${index + 1}. $question', // Mostrar el número de la pregunta
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
    // Obtener las opciones para la pregunta actual
    final opciones = opcionesPorPregunta[preguntaIndex] ?? [];

    return opciones
        .asMap()
        .map((index, opcion) => MapEntry(
              index,
              RadioListTile<int>(
                title: Text(opcion),
                value: index,
                groupValue: respuestas[preguntaIndex],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      respuestas[preguntaIndex] = value;
                      // Asegúrate de que usuarioId es un número válido
                      final intId = int.tryParse(usuarioId) ?? 0;
                      Servicio().enviarRespuestaTestBDI(preguntaIndex, value, opciones.length, intId);
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
    final start = paginaActualIndex * 7;
    final end = (start + 7) < preguntas.length ? start + 7 : preguntas.length;

    final allQuestionsOnPageAnswered = preguntas.sublist(start, end).every((question) {
      final questionIndex = preguntas.indexOf(question);
      return respuestas.containsKey(questionIndex);
    });

    if (!allQuestionsOnPageAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, responde todas las preguntas en esta página.')),
      );
    } else if (paginaActualIndex < (preguntas.length / 7).ceil() - 1) {
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
