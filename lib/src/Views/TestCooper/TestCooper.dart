import 'package:flutter/material.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestCooper extends StatefulWidget {
  const TestCooper({super.key});

  @override
  State<TestCooper> createState() => _TestCooperState();
}

class _TestCooperState extends State<TestCooper> {
  final PageController paginaController = PageController();
  String usuarioId = "";

  final List<String> preguntas = [
    'Paso mucho tiempo soñando despierto(a).',
    'Estoy seguro de mi mismo(a).',
    'Deseo frecuentemente ser otra persona.',
    'Soy simpatico(a).',
    'Mi familia y yo nos divertimos mucho juntos.',
    'Nunca me preocupo por nada.',
    'Me da verguenza mostrar a otros mi trabajo.',
    'Desearia ser mas joven.',
    'Hay muchas cosas acerca de mi mismo(a) que me gustaria cambiar si pudiera.',
    'Puedo tomar decisiones fácilmente.',
    'Mis amigos(as) lo pasan bien cuando están conmigo.',
    'Me incomodo en casa fácilmente.',
    'Siempre hago lo correcto.',
    'Me siento orgulloso(a) de mi en la escuela.',
    'Tengo siempre que tener a alguien que me diga lo que tengo que hacer.',
    'Me toma mucho tiempo acostumbrarme a cosas nuevas.',
    'Frecuentemente me arrepiento de las cosas que hago.',
    'Soy popular entre la gente.',
    'Usualmente en mi familia consideran mis sentimientos.',
    'Nunca estoy triste.',
    'Estoy haciendo el mejor trabajo que puedo.',
    'Me doy por vencido(a) fácilmente.',
    'Usualmente puedo cuidarme a mí mismo(a)',
    'Me siento suficientemente feliz.',
    'Prefiero compartir con personas de menor nivel que yo.',
    'Mi familia espera demasiado de mi.',
    'Me gustan todas las personas que conozco.',
    'Me gusta que el profesor me interrogue en clase.',
    'Me entiendo a mi mismo(a).',
    'Me cuesta comportarme como en realidad soy.',
    'Las cosas en mi vida están muy complicadas.',
    'Los demás casi siempre siguen mis ideas.',
    'Nadie me presta mucha atención en casa.',
    'Nunca me regañan.',
    'No estoy progresando en el colegio o liceo como me gustaría.',
    'Puedo tomar decisiones y cumplirlas.',
    'No estoy conforme con mi sexo.',
    'Tengo una mala opinión de mí mismo(a).',
    'No me gusta estar con otra gente.',
    'Muchas veces me gustaría irme de casa.',
    'Nunca soy tímido(a).',
    'Frecuentemente me avergüenzo de mí mismo(a).',
    'Frecuentemente me incomodo en el colegio o liceo.',
    'No soy tan bien parecido(a) como otra gente.',
    'Si tengo algo que decir usualmente lo digo.',
    'A los demás "les da igual" como soy.',
    'Mi familia me entiende.',
    'Siempre digo la verdad.',
    'Mi profesor me hace sentir que no soy gran cosa.',
    'A mi no me importa lo que me pase.',
    'Soy un fracaso.',
    'Me siento incómodo fácilmente cuando me regañan.',
    'Las otras personas son más agradables que yo.',
    'Usualmente siento que mi familia espera más de mi.',
    'Siempre sé qué decir a otras personas.',
    'Frecuentemente me siento desilusionado(a) en el colegio o liceo.',
    'Generalmente las cosas no me importan.',
    'No soy una persona confiable para que otros dependan de mi.'
  ];

  final Map<int, int?> respuestas = {};

  static const List<String> opciones = [
    'Igual que yo',
    'Distinto a mí',
  ];

  @override
  void initState() {
    super.initState();
    _cargarRespuestas();
  }

  Future<void> _cargarRespuestas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    usuarioId = prefs.getString('usuario_id') ?? "";

    var resultado = await Servicio().TestCooperRespuestas(int.parse(usuarioId));

    final respuestasProcesadas = Map<int, int?>.fromIterable(
      List.generate(preguntas.length, (index) => index),
      key: (index) => index,
      value: (index) {
        final respuesta = resultado['p${index + 1}_1'] ?? '0';
        return int.tryParse(respuesta);
      },
    );

    setState(() {
      respuestas.addAll(respuestasProcesadas);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Test Cooper',
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

  Widget widgetPreguntas({required int index, required String question, required bool margenT}) {
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
          ...widgetOpciones(index),  // Asegúrate de que el índice sea el correcto
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
                value: index + 1,  // Enviar 1 para "Igual que yo" y 2 para "Distinto a mí"
                groupValue: respuestas[preguntaIndex],
                onChanged: (value) async {
                  if (value != null) {
                    setState(() {
                      respuestas[preguntaIndex] = value;
                    });

                    // Enviar respuesta al servicio
                    await Servicio().enviarRespuestaTestCooper(preguntaIndex, value, int.parse(usuarioId));
                  }
                },
              ),
            ))
        .values
        .toList();
  }

  void Submit() async {
    final paginaActualIndex = paginaController.page?.round() ?? 0;
    final start = paginaActualIndex * 10;
    final end = (start + 10) < preguntas.length ? start + 10 : preguntas.length;

    // Verificar si todas las preguntas de la página actual tienen respuesta
    final allQuestionsOnPageAnswered = preguntas.sublist(start, end).every((question) {
      final questionIndex = preguntas.indexOf(question);
      return respuestas.containsKey(questionIndex);
    });

    // Verificar si todas las preguntas del cuestionario han sido respondidas
    final allQuestionsAnswered = preguntas.every((question) {
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
    } else if (allQuestionsAnswered) {
      // Enviar todas las respuestas si se ha llegado al final
      for (var entry in respuestas.entries) {
        await Servicio().enviarRespuestaTestCooper(entry.key, entry.value!, int.parse(usuarioId));
      }

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
