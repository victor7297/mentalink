// ignore_for_file: use_key_in_widget_constructors, avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_print, body_might_complete_normally_nullable, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mentalink/src/Clases/appbar.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:mentalink/src/Widgets/drawer.dart';
import 'package:mentalink/src/Widgets/footer.dart';
import 'package:mentalink/src/Widgets/formularioPreguntas.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  appbar appbarAux = appbar("","");
  Map<String, dynamic> usuarioData = {};

  int paginaActual = 0;
  bool mostrarFormulario = false;

  List<dynamic> listaPsicologos = [];

  bool esFavorito = false;

  final ScrollController _scrollController = ScrollController();
  bool _isVisible = false;

  TextEditingController searchController = TextEditingController();
  List<dynamic> filtroPsicologos = [];

  String? tipoUsuarioGlobal;
  String paisGlobal = "";

  obtenerDatosUsuario() async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String usuarioId = prefs.getString('usuario_id') ?? "";
    String? tipoUsuario = prefs.getString('tipo_usuario');
    appbarAux.setId(usuarioId);

    usuarioData = await Servicio().obtenerUsuario(int.parse(usuarioId));

    appbarAux.setRutaImagenPerfil(usuarioData['foto']);
    await prefs.setString('fotoPerfil', usuarioData['foto']);
    
  }

  @override
  void initState() {
    super.initState();

    obtenerDatosUsuario();
    obtenerEspecialistas();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        setState(() {
          _isVisible = true;
        });
      } else {
        setState(() {
          _isVisible = false;
        });
      }
    });

  }


  Future<void> obtenerEspecialistas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String usuarioId = prefs.getString('usuario_id') ?? "";
    String? tipoUsuario = prefs.getString('tipo_usuario');

    tipoUsuarioGlobal = tipoUsuario;

    paisGlobal = prefs.getString('pais') ?? "";

    List<Map<String, dynamic>> listaEspecialistas;

    if (tipoUsuario == "2") {
      listaEspecialistas = await Servicio().UsuariosAsignados(usuarioId);
    } else {
      listaEspecialistas = await Servicio().UsuariosEspecialistas(usuarioId);
    }

    setState(() {
      listaPsicologos = listaEspecialistas;
      filtroPsicologos = listaPsicologos; 
    });
  }


  void _onChanged(String value) {
    setState(() {
      filtroPsicologos = listaPsicologos.where((psicologo) {
        String nombreCompleto = "${psicologo['nombre']} ${psicologo['apellido']}".toLowerCase();
        String especialidad = (psicologo['especialidad'] is String && psicologo['especialidad'].isNotEmpty)
            ? psicologo['especialidad'].toLowerCase()
            : 'psicologo';
        String tipoCita = psicologo['tipo_cita'] ?? "";

        // Verificamos si el tipo de cita es "ambas", "remota" o "presencial"
        bool tipoCitaMatches = tipoCita.contains("ambas") || tipoCita.contains(value.toLowerCase());

        return nombreCompleto.contains(value.toLowerCase()) || 
              especialidad.contains(value.toLowerCase()) || 
              tipoCitaMatches;
      }).toList();
    });
  }

  void scrollToTop() {
    _scrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {

    //String nombrePsicologo = "";

    return mostrarFormulario ? formularioPreguntas(): 
    Scaffold(

      appBar: appbarAux.getAppbar(context),

      body: WillPopScope(

        onWillPop: () async {
          return false;
        },
          
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
          
            padding: EdgeInsets.only(top: 30, bottom: 50, left: 20, right: 20),
            
            child: Column(
          
              children: [
          
          
                /**************************Estados Psicologos****************************************/
          
                Container(
          
                  height: 80,
                  //color: Colors.blue,
          
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    //itemCount: listaPsicologosEstados.length,
                    itemCount: listaPsicologos.length,
                    itemBuilder: (context,index){
          
                      //nombrePsicologo = listaPsicologosEstados[index]['profesion'];
                      String nombrePsicologo = listaPsicologos[index]['nombre'];
                      String fotoUrl = listaPsicologos[index]['foto'];
                      //print(fotoUrl);
          
                      return InkWell(
                        onTap: (){
                          print("hola");
                        },
                        child: Container(
          
                          child: Column(
                        
                            children: [

                              Container(
                                margin: EdgeInsets.only(left: 10),
                                width: 50,
                                height: 50,
                                child: fotoUrl.isNotEmpty
                                  ? ClipOval(
                                      child: Image.network(
                                        "https://mentalink.org/api-mentalink-prueba-v/public/" + fotoUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Icon(
                                      Icons.account_circle_rounded,
                                      color: Colors.grey,
                                      size: 50,
                                    ),
                              ),
                        
                              Container(child: Text(nombrePsicologo, style: TextStyle(fontWeight: FontWeight.bold),),)
                            ],
                          ),
                        )
                      );
                      
                    } 
                  ),
          
                ),
          
                /**********************************Filtro*****************************************************************/
          
                Container(
                  //color: Colors.amber,
                  margin: EdgeInsets.only(top: 20),
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Container(
          
                        width: 250,
                        height: 45,
          
                        child: TextFormField(
                          controller: searchController,
                          onChanged: _onChanged,
          
                          decoration: InputDecoration(
                            labelText: 'Buscar',
                            filled: false,
          
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(175, 175, 175, 1),
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color.fromRGBO(72, 189, 199, 1),
                                width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
          
                            suffixIcon: Container(
                              child: TextButton(
                                child: Icon(
                                  Icons.search,
                                  color: Color.fromRGBO(175, 175, 175, 1),
                                ),
                                onPressed: () {},
                              ),
                            ),
          
                          ),
          
                        ),
          
                      ),
          
          
                      Container(
                        child: TextButton(
                          onPressed: () {
                          
                          },
                          child: Icon(Icons.filter_alt_outlined,
                          color: Color.fromRGBO(172, 172, 172, 1.0),
                          size: 32.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          
                /**********************************Lista Psicologos*****************************************************************/

                /*Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: filtroPsicologos.length,
                    itemBuilder: (context, index) {
                      String nombrePsicologo = filtroPsicologos[index]['nombre'];
                      String apellido = filtroPsicologos[index]['apellido'];
                      String fotoUrl = filtroPsicologos[index]['foto'];
                      String correo = filtroPsicologos[index]['correo'];
                      String? tipoUsuario = tipoUsuarioGlobal;

                      String pais = paisGlobal;

                      String especialidad = filtroPsicologos[index]['especialidad'] ?? "Psicólogo";
                      String tipoCita = filtroPsicologos[index]['tipo_cita'] ?? "";

                      // Verifica si el tipo de cita es "ambas"
                      String tipo_cita_1 = tipoCita.contains("ambas") ? "remota y presencial" : tipoCita;

                      String favorito = filtroPsicologos[index]['es_favorito'];
                      bool isSelected = favorito == "true";

                      // Obtener costos locales e internacionales
                      String costo_presencial = filtroPsicologos[index]['costo_presencial'] ?? 'No disponible';
                      String costo_remota = filtroPsicologos[index]['costo_remota'] ?? 'No disponible';
                      String costo_internacional = filtroPsicologos[index]['costo_internacional'] ?? 'No disponible';

                      // Si el país no es Venezuela, mostrar costo_internacional
                      String costo_cita;
                      if (pais == "Venezuela") {
                        if (tipoCita.contains("ambas")) {
                          costo_cita = "Presencial: $costo_presencial\$ , Remota: $costo_remota\$";
                        } else if (tipoCita == "presencial") {
                          costo_cita = "Presencial: $costo_presencial\$";
                        } else if (tipoCita == "remota") {
                          costo_cita = "Remota: $costo_remota\$";
                        } else {
                          costo_cita = "Costo no disponible";
                        }
                      } else {
                        // Si el país no es Venezuela, mostramos solo el costo sin la palabra "internacional"
                        costo_cita = "Costo: $costo_internacional\$";
                      }

                      if (tipoUsuario == "2") {
                        return InkWell(
                          onTap: () {
                            Map<String, dynamic> psicologoSeleccionado = {
                              'id': filtroPsicologos[index]['usuario_id'],
                              'nombre': nombrePsicologo,
                              'apellido': apellido,
                              'foto': fotoUrl,
                              'correo': correo,
                            };
                            //Navigator.of(context).pushNamed("/menuEspecialistas", arguments: psicologoSeleccionado);
                          },
                          child: Container(
                            height: 130,
                            margin: EdgeInsets.only(top: 10),
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          child: fotoUrl.isNotEmpty
                                              ? ClipOval(
                                                  child: Image.network(
                                                    "https://mentalink.org/api-mentalink-prueba-v/public/" + fotoUrl,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.account_circle_rounded,
                                                  color: Colors.grey,
                                                  size: 60,
                                                ),
                                        ),
                                        SizedBox(width: 10),
                                        Container(
                                          padding: EdgeInsets.all(5),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${nombrePsicologo.toUpperCase()} ${apellido.toUpperCase()}",
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                correo,
                                                style: TextStyle(fontWeight: FontWeight.w200),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return InkWell(
                          onTap: () {
                            Map<String, dynamic> psicologoSeleccionado = {
                              'id': filtroPsicologos[index]['usuario_id'],
                              'nombre': nombrePsicologo,
                              'apellido': apellido,
                              'foto': fotoUrl,
                              'correo': correo,
                              'especialidad': especialidad,
                              'tipo_cita': filtroPsicologos[index]['tipo_cita'],
                              'presencial_direccion': filtroPsicologos[index]['presencial_direccion'],
                              'costo_presencial': filtroPsicologos[index]['costo_presencial'],
                              'costo_remota': filtroPsicologos[index]['costo_remota'],
                              'costo_internacional': filtroPsicologos[index]['costo_internacional'],
                              'pais': pais,
                            };
                            Navigator.of(context).pushNamed("/menuEspecialistas", arguments: psicologoSeleccionado);
                          },
                          child: Container(
                            height: 180,
                            margin: EdgeInsets.only(top: 10),
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: isSelected ? Color.fromRGBO(72, 189, 199, 1) : Colors.transparent,
                                  width: 2.0,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          child: fotoUrl.isNotEmpty
                                              ? ClipOval(
                                                  child: Image.network(
                                                    "https://mentalink.org/api-mentalink-prueba-v/public/" + fotoUrl,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.account_circle_rounded,
                                                  color: Colors.grey,
                                                  size: 60,
                                                ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${nombrePsicologo.toUpperCase()} ${apellido.toUpperCase()}",
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  especialidad,
                                                  style: TextStyle(fontWeight: FontWeight.w400),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (pais == "Venezuela") ...[
                                                  // Solo mostrar "Citas" si el país es Venezuela
                                                  Text(
                                                    "Citas: $tipo_cita_1",
                                                    style: TextStyle(fontWeight: FontWeight.w400),
                                                  ),
                                                ],
                                                Container(
                                                  margin: EdgeInsets.only(top: 3),
                                                  child: Text(
                                                    "$costo_cita",
                                                    style: TextStyle(fontWeight: FontWeight.w500),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 2),
                                          child: TextButton(
                                            onPressed: () async {
                                              SharedPreferences prefs = await SharedPreferences.getInstance();
                                              String pacienteId = prefs.getString('usuario_id') ?? "";

                                              // Llama a la función para marcar/desmarcar usuario como favorito
                                              await Servicio().marcarUsuario(filtroPsicologos[index]['usuario_id'], pacienteId);

                                              // Actualiza el estado local después de la respuesta del servicio
                                              setState(() {
                                                filtroPsicologos[index]['es_favorito'] = isSelected ? "false" : "true";
                                              });
                                            },
                                            style: ButtonStyle(
                                              elevation: MaterialStateProperty.all(10.0),
                                              minimumSize: MaterialStateProperty.all(Size(40, 40)),
                                              padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                                            ),
                                            child: Icon(
                                              isSelected ? Icons.star : Icons.star_border,
                                              color: Color.fromRGBO(72, 189, 199, 1),
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {},
                                          style: ButtonStyle(
                                            elevation: MaterialStateProperty.all(10.0),
                                            minimumSize: MaterialStateProperty.all(Size(40, 40)),
                                            padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                                          ),
                                          child: Icon(
                                            Icons.search,
                                            color: Color.fromRGBO(72, 189, 199, 1),
                                            size: 30,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                )*/

                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: filtroPsicologos.length,
                    itemBuilder: (context, index) {
                      String nombrePsicologo = filtroPsicologos[index]['nombre'];
                      String apellido = filtroPsicologos[index]['apellido'];
                      String fotoUrl = filtroPsicologos[index]['foto'];
                      String correo = filtroPsicologos[index]['correo'];
                      String? tipoUsuario = tipoUsuarioGlobal;

                      if (tipoUsuario == "2") {
                        return InkWell(
                          onTap: () {
                            Map<String, dynamic> psicologoSeleccionado = {
                              'id': filtroPsicologos[index]['usuario_id'],
                              'nombre': nombrePsicologo,
                              'apellido': apellido,
                              'foto': fotoUrl,
                              'correo': correo,
                            };
                            //Navigator.of(context).pushNamed("/menuEspecialistas", arguments: psicologoSeleccionado);
                          },
                          child: Container(
                            height: 130,
                            margin: EdgeInsets.only(top: 10),
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          child: fotoUrl.isNotEmpty
                                              ? ClipOval(
                                                  child: Image.network(
                                                    "https://mentalink.tepuy21.com/api-mentalink/public/" + fotoUrl,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.account_circle_rounded,
                                                  color: Colors.grey,
                                                  size: 60,
                                                ),
                                        ),
                                        SizedBox(width: 10),
                                        Container(
                                          padding: EdgeInsets.all(5),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${nombrePsicologo.toUpperCase()} ${apellido.toUpperCase()}",
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                correo,
                                                style: TextStyle(fontWeight: FontWeight.w200),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        String pais = paisGlobal;
                        String especialidad = filtroPsicologos[index]['especialidad'] ?? "Psicólogo";
                        String tipoCita = filtroPsicologos[index]['tipo_cita'] ?? "";
                        String tipo_cita_1 = tipoCita.contains("ambas") ? "remota y presencial" : tipoCita;
                        String favorito = filtroPsicologos[index]['es_favorito'];
                        bool isSelected = favorito == "true";
                        String costo_presencial = filtroPsicologos[index]['costo_presencial'] ?? 'No disponible';
                        String costo_remota = filtroPsicologos[index]['costo_remota'] ?? 'No disponible';
                        String costo_internacional = filtroPsicologos[index]['costo_internacional'] ?? 'No disponible';
                        String costo_cita;

                        if (pais == "Venezuela") {
                          if (tipoCita.contains("ambas")) {
                            costo_cita = "Presencial: $costo_presencial\$ , Remota: $costo_remota\$";
                          } else if (tipoCita == "presencial") {
                            costo_cita = "Presencial: $costo_presencial\$";
                          } else if (tipoCita == "remota") {
                            costo_cita = "Remota: $costo_remota\$";
                          } else {
                            costo_cita = "Costo no disponible";
                          }
                        } else {
                          costo_cita = "Costo: $costo_internacional\$";
                        }

                        return InkWell(
                          onTap: () {
                            Map<String, dynamic> psicologoSeleccionado = {
                              'id': filtroPsicologos[index]['usuario_id'],
                              'nombre': nombrePsicologo,
                              'apellido': apellido,
                              'foto': fotoUrl,
                              'correo': correo,
                              'especialidad': especialidad,
                              'tipo_cita': filtroPsicologos[index]['tipo_cita'],
                              'presencial_direccion': filtroPsicologos[index]['presencial_direccion'],
                              'costo_presencial': filtroPsicologos[index]['costo_presencial'],
                              'costo_remota': filtroPsicologos[index]['costo_remota'],
                              'costo_internacional': filtroPsicologos[index]['costo_internacional'],
                              'pais': pais,
                            };
                            Navigator.of(context).pushNamed("/menuEspecialistas", arguments: psicologoSeleccionado);
                          },
                          child: Container(
                            height: 180,
                            margin: EdgeInsets.only(top: 10),
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(
                                  color: isSelected ? Color.fromRGBO(72, 189, 199, 1) : Colors.transparent,
                                  width: 2.0,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          child: fotoUrl.isNotEmpty
                                              ? ClipOval(
                                                  child: Image.network(
                                                    "https://mentalink.org/api-mentalink-prueba-v/public/" + fotoUrl,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.account_circle_rounded,
                                                  color: Colors.grey,
                                                  size: 60,
                                                ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${nombrePsicologo.toUpperCase()} ${apellido.toUpperCase()}",
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                Text(
                                                  especialidad,
                                                  style: TextStyle(fontWeight: FontWeight.w400),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (pais == "Venezuela") ...[
                                                  Text(
                                                    "Citas: $tipo_cita_1",
                                                    style: TextStyle(fontWeight: FontWeight.w400),
                                                  ),
                                                ],
                                                Container(
                                                  margin: EdgeInsets.only(top: 3),
                                                  child: Text(
                                                    "$costo_cita",
                                                    style: TextStyle(fontWeight: FontWeight.w500),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 2),
                                          child: TextButton(
                                            onPressed: () async {
                                              SharedPreferences prefs = await SharedPreferences.getInstance();
                                              String pacienteId = prefs.getString('usuario_id') ?? "";

                                              await Servicio().marcarUsuario(filtroPsicologos[index]['usuario_id'], pacienteId);

                                              setState(() {
                                                filtroPsicologos[index]['es_favorito'] = isSelected ? "false" : "true";
                                              });
                                            },
                                            style: ButtonStyle(
                                              elevation: MaterialStateProperty.all(10.0),
                                              minimumSize: MaterialStateProperty.all(Size(40, 40)),
                                              padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                                            ),
                                            child: Icon(
                                              isSelected ? Icons.star : Icons.star_border,
                                              color: Color.fromRGBO(72, 189, 199, 1),
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () {},
                                          style: ButtonStyle(
                                            elevation: MaterialStateProperty.all(10.0),
                                            minimumSize: MaterialStateProperty.all(Size(40, 40)),
                                            padding: MaterialStateProperty.all(EdgeInsets.all(10)),
                                          ),
                                          child: Icon(
                                            Icons.search,
                                            color: Color.fromRGBO(72, 189, 199, 1),
                                            size: 30,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                )



          
                
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _isVisible
        ? FloatingActionButton(
          onPressed: () {
            scrollToTop();
          },
          child: Icon(Icons.arrow_upward),
        )
        : null,

      drawer: NowDrawer(currentPage: 'Home',),
      bottomNavigationBar: Footer(),
    );
  }
}
