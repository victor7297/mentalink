// ignore_for_file: prefer_const_constructors, curly_braces_in_flow_control_structures, use_key_in_widget_constructors, sized_box_for_whitespace, sort_child_properties_last, camel_case_types

import 'package:flutter/material.dart';
import 'package:mentalink/src/Clases/appbar.dart';
import 'package:mentalink/src/Widgets/drawer.dart';
import 'package:mentalink/src/Widgets/footer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class testEvaluativo extends StatefulWidget {
  const testEvaluativo({super.key});

  @override
  State<testEvaluativo> createState() => _testEvaluativoState();
}

class _testEvaluativoState extends State<testEvaluativo> {
  Map<String, dynamic>? testResults;
  bool cargando = true;
  String mensajeError = "";
  int progresoCooper = 0;
  int progresoBDI = 0;
  int progresoAnsiedad = 0;
  int progresoDesesperanza = 0;
  int progresoAsertividad = 0;
  int progresoLaboral = 0;

  appbar appbarAux = appbar("","");
  Map<String, dynamic> usuarioData = {};

  @override
  void initState() {
    super.initState();
    _fetchTestAsignados();
    obtenerDatosUsuario();
  }

  Future<void> obtenerDatosUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String usuarioId = prefs.getString('usuario_id') ?? "";
    String tipoUsuario = prefs.getString('tipo_usuario') ?? "";

    usuarioData = await Servicio().obtenerUsuario(int.parse(usuarioId));

    String? rutaImagenPerfil = prefs.getString('fotoPerfil');

    appbar appbarAux = appbar(usuarioId,rutaImagenPerfil!);
    setState(() {
      this.appbarAux = appbarAux;
    });
    
  }

  Future<void> _fetchTestAsignados() async {

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String usuarioId = prefs.getString('usuario_id') ?? "";

      // Obtener los tests asignados
      testResults = await Servicio().testAsignados(int.parse(usuarioId));

      // Obtener el progreso para los tests
      var progresoTC = await Servicio().progresoTestCooper(int.parse(usuarioId));
      progresoCooper = (progresoTC['progreso'] as int?) ?? 0;

      var progresoTBDI = await Servicio().progresoTestBdi(int.parse(usuarioId));
      progresoBDI = (progresoTBDI['progreso'] as int?) ?? 0;

      var progresoTAnsiedad = await Servicio().progresoTestAnsiedad(int.parse(usuarioId));
      progresoAnsiedad = (progresoTAnsiedad['progreso'] as int?) ?? 0;

      var progresoTAsertividad = await Servicio().progresoTestAsertividad(int.parse(usuarioId));
      progresoAsertividad = (progresoTAsertividad['progreso'] as int?) ?? 0;

      var progresoTDesesperanza = await Servicio().progresoTestDesesperanza(int.parse(usuarioId));
      progresoDesesperanza = (progresoTDesesperanza['progreso'] as int?) ?? 0;

      var progresoTLaboral = await Servicio().progresoTestLaboral(int.parse(usuarioId));
      progresoLaboral = (progresoTLaboral['progreso'] as int?) ?? 0;

      setState(() {
        cargando = false;
      });
      
    } catch (e) {
      setState(() {
        cargando = false;
        mensajeError = 'Excepción: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return Scaffold(
        appBar: appbarAux.getAppbar(context),
        drawer: NowDrawer(currentPage: 'Mis Test'),
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: Footer(),
      );
    }

    if (mensajeError.isNotEmpty) {
      return Scaffold(
        appBar: appbarAux.getAppbar(context),
        drawer: NowDrawer(currentPage: 'Mis Test'),
        body: Center(child: Text(mensajeError)),
        bottomNavigationBar: Footer(),
      );
    }

    List<TestCard> tests = [];

    if (testResults != null) {
      if (testResults!['testcooper'] == true) tests.add(TestCard(
        title: 'Coopersmith',
        imageUrl: 'https://mentalink.org/assets/images/1.jpg',
        description: 'Puedes realizar este test',
        onPressed: () {
          Navigator.of(context).pushNamed("/testCooper");
        },
        progress: progresoCooper / 100.0,
      ));
      if (testResults!['testbdi'] == true) tests.add(TestCard(
        title: 'BDI',
        imageUrl: 'https://mentalink.org/assets/images/2.jpg',
        description: 'Puedes realizar este test',
        onPressed: () {
          Navigator.of(context).pushNamed("/testbdi");
        },
        progress: progresoBDI / 100.0,
      ));
      if (testResults!['test_ansiedad'] == true) tests.add(TestCard(
        title: 'Ansiedad',
        imageUrl: 'https://mentalink.org/assets/images/6.jpg',
        description: 'Puedes realizar este test',
        onPressed: () {
          Navigator.of(context).pushNamed("/testansiedad");
        },
        progress: progresoAnsiedad / 100.0,
      ));
      if (testResults!['test_asertividad'] == true) tests.add(TestCard(
        title: 'Asertividad',
        imageUrl: 'https://mentalink.org/assets/images/7.jpg',
        description: 'Puedes realizar este test',
        onPressed: () {
          Navigator.of(context).pushNamed("/testasertividad");
        },
        progress: progresoAsertividad / 100.0,
      ));
      if (testResults!['test_desesperanza'] == true) tests.add(TestCard(
        title: 'Desesperanza',
        imageUrl: 'https://mentalink.org/assets/images/7.jpg',
        description: 'Puedes realizar este test',
        onPressed: () {
          Navigator.of(context).pushNamed("/testdesesperanza");
        },
        progress: progresoDesesperanza / 100.0,
      ));
      if (testResults!['test_laboral'] == true) tests.add(TestCard(
        title: 'Estrés Laboral',
        imageUrl: 'https://mentalink.org/assets/images/4.jpg',
        description: 'Puedes realizar este test',
        onPressed: () {
          Navigator.of(context).pushNamed("/testlaboral");
        },
        progress: progresoLaboral / 100.0,
      ));
    }

    return WillPopScope(

      onWillPop: () async {
        Navigator.of(context).pushNamed("/Home");
        return false;
      },
      
      child: Scaffold(
        appBar: appbarAux.getAppbar(context),
        drawer: NowDrawer(currentPage: 'Mis Test'),
        body: tests.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(25.0),
                child: ListView(
                  children: tests,
                ),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Estimado paciente, usted aún no tiene test asignados por su psicólogo.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              bottomNavigationBar: Footer(),
      ),
    );
  }
}

class TestCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String description;
  final VoidCallback onPressed;
  final double progress;

  const TestCard({
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.onPressed,
    this.progress = 0.0, // Valor predeterminado
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Center(
                    child: Image.network(
                      imageUrl,
                      height: 150,
                      width: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'TEST',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 2),
                          Text(
                            title,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: double.infinity,
                    height: 6,
                    child: LinearProgressIndicator(
                      value: progress, // Usa el progreso aquí
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9068BE)),
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ElevatedButton(
                      onPressed: onPressed,
                      child: Text(
                        'Empezar ahora',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6ED3CF),
                        minimumSize: Size(double.infinity, 36),
                        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
