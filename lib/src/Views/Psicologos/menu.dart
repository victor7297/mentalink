// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, non_constant_identifier_names, prefer_const_declarations, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mentalink/src/Clases/appbar.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:mentalink/src/Widgets/calendario.dart';
import 'package:mentalink/src/Widgets/drawer.dart';
import 'package:mentalink/src/Widgets/footer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class menu extends StatefulWidget {
  const menu({super.key});

  @override
  State<menu> createState() => _menuState();
}

class _menuState extends State<menu> {
  bool calendario = false;
  String? tipoCita;
  String? direccionPresencial;

  appbar appbarAux = appbar("", "");
  Map<String, dynamic> usuarioData = {};

  Future<void> obtenerDatosUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String usuarioId = prefs.getString('usuario_id') ?? "";
    String tipoUsuario = prefs.getString('tipo_usuario') ?? "";

    usuarioData = await Servicio().obtenerUsuario(int.parse(usuarioId));

    String? rutaImagenPerfil = prefs.getString('fotoPerfil');

    appbar appbarAux = appbar(usuarioId, rutaImagenPerfil!);
    setState(() {
      this.appbarAux = appbarAux;
    });
  }

  /*void _WhatsApp() async {
    final phoneNumber = '04242032164';
    final url = 'https://wa.me/$phoneNumber';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }*/

  void _WhatsApp() async {
    final phoneNumber = '584242032164';
    final message = 'Hola, me gustaría obtener más información.';
    final url =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    // Recuperar los datos del psicólogo seleccionado
    var psicologoSeleccionado =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    /*print('Psicólogo seleccionado:');
    print('ID: ${psicologoSeleccionado?['id']}');
    print('Nombre: ${psicologoSeleccionado?['nombre']}');
    print('Apellido: ${psicologoSeleccionado?['apellido']}');
    print('Foto: ${psicologoSeleccionado?['foto']}');*/

    tipoCita = psicologoSeleccionado!['tipo_cita'];

    direccionPresencial = psicologoSeleccionado['presencial_direccion'];

    return Scaffold(
      appBar: appbarAux.getAppbar(context),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 40, bottom: 50, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                child: psicologoSeleccionado != null &&
                        psicologoSeleccionado['foto'] != null &&
                        psicologoSeleccionado['foto'].isNotEmpty
                    ? ClipOval(
                        child: Image.network(
                          "https://mentalink.org/api-mentalink-prueba-v/public/" +
                              psicologoSeleccionado?['foto'],
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.account_circle_rounded,
                        color: Colors.grey,
                        size: 70,
                      ),
              ),
              Container(
                width: double.infinity,
                child: Center(
                    child: Text(
                  "${psicologoSeleccionado?['nombre']} ${psicologoSeleccionado?['apellido']}",
                  style: TextStyle(fontWeight: FontWeight.w600),
                )),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                child: Center(
                  child: Text(
                    psicologoSeleccionado?['especialidad'] ?? 'Psicólogo',
                    style: TextStyle(fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      calendario = !calendario;
                      //print(calendario);
                    });
                  },
                  child: Card(
                    color: Color.fromRGBO(9, 25, 87, 1.0),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Color.fromARGB(255, 0, 188, 207),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.78,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              size: 35,
                              color: Color.fromARGB(255, 0, 188, 207),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Agenda una cita",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                //height: calendario ? MediaQuery.of(context).size.height * 0.4 : 0,
                child: Visibility(
                  visible: calendario,
                  child: Calendario(
                      psicologoSeleccionado?['id'],
                      psicologoSeleccionado?['correo'],
                      psicologoSeleccionado?['tipo_cita'],
                      psicologoSeleccionado?['presencial_direccion'],
                      psicologoSeleccionado?['costo_presencial'],
                      psicologoSeleccionado?['costo_remota'],
                      psicologoSeleccionado?['costo_internacional'],
                      psicologoSeleccionado?['pais']),
                ),
              ),
              Container(
                child: InkWell(
                  onTap: () {
                    //Navigator.of(context).pushNamed("/agendarCita");
                  },
                  child: Card(
                    color: Color.fromRGBO(9, 25, 87, 1.0),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Color.fromARGB(255, 0, 188, 207),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                        width: MediaQuery.of(context).size.width * 0.78,
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Padding(
                          padding: EdgeInsets.all(18),
                          child: GestureDetector(
                            onTap: () => _WhatsApp(),
                            child: Row(
                              children: [
                                Icon(
                                  FontAwesomeIcons.whatsapp,
                                  size: 35,
                                  color: Color.fromARGB(255, 0, 188, 207),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Necesito Hablar Ahora",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ),
                ),
              ),
              Container(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed("/testEvaluativo");
                  },
                  child: Card(
                    color: Color.fromRGBO(9, 25, 87, 1.0),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Color.fromARGB(255, 0, 188, 207),
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.78,
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      child: Padding(
                        padding: EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Icon(
                              Icons.article_outlined,
                              size: 35,
                              color: Color.fromARGB(255, 0, 188, 207),
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Iniciar Test Evaluativo",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: NowDrawer(
        currentPage: 'menuEspecialistas',
      ),
      bottomNavigationBar: Footer(),
    );
  }
}
