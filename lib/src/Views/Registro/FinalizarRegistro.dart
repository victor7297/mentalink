// ignore_for_file: use_super_parameters, non_constant_identifier_names, prefer_const_constructors, prefer_adjacent_string_concatenation, prefer_const_literals_to_create_immutables

import 'package:country_picker/country_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mentalink/src/Inicio.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:mentalink/src/Views/Login/Login.dart';

class FinalizarRegistro extends StatefulWidget {
  final String nombre;
  final String apellido;
  final String correo;
  final String contrasena;

  const FinalizarRegistro({
    Key? key,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.contrasena,
  }) : super(key: key);

  @override
  State<FinalizarRegistro> createState() => _FinalizarRegistroState();
}

class _FinalizarRegistroState extends State<FinalizarRegistro> {
  late DateTime selecionnarHora;
  bool showCalendarIcon = true;
  String? _selectedSexo;
  bool Terminos = false;
  Country? _selectedCountry;

  final TextEditingController _telefonoController = TextEditingController();
  bool _telefonoValido = true;

  List<String> opcionesGenero = ['Masculino', 'Femenino', 'Otro'];

  @override
  void initState() {
    super.initState();
    selecionnarHora = DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selecionnarHora,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale("es"),
    );
    if (picked != null && picked != selecionnarHora) {
      setState(() {
        selecionnarHora = picked;
        showCalendarIcon = false;
      });
    }
  }

  /*void modalTerminosyCondiciones() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Text('Términos y Condiciones'),
          ),
          message: Container(
            height: 520,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Column(
                  children: [
                    SizedBox(height: 16),
                    Text(
                      '1. Uso de la Aplicación: La aplicación está destinada a usuarios mayores de 18 años.',
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '2. Privacidad de Datos: Nos comprometemos a proteger tu información personal. Los datos recopilados se usarán únicamente para mejorar la experiencia del usuario.',
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '3. Conducta del Usuario: Se espera que los usuarios se comporten de manera respetuosa y ética. Cualquier conducta inapropiada puede resultar en la suspensión de la cuenta.',
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '4. Responsabilidad: La aplicación no se hace responsable por interacciones entre los usuarios.',
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '5. Modificaciones: Nos reservamos el derecho de modificar estos términos en cualquier momento.',
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '6. Terminación de Servicios: La aplicación puede terminar o suspender el acceso de un usuario si se violan estos términos.',
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        CupertinoCheckbox(
                          value: Terminos,
                          onChanged: (bool? value) {
                            setModalState(() {
                              Terminos = value ?? false;
                            });
                          },
                        ),
                        Text('Acepto los Términos y Condiciones'),
                      ],
                    ),
                    Divider(),
                    CupertinoButton(
                      child: Text('Cerrar'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }*/

  void modalTerminosyCondiciones(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              'Términos y Condiciones',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
          message: Container(
            height: 560,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                PageController _pageController = PageController();
                int currentPage = 0;
                bool Terminos = false; // Inicializa la variable Terminos

                return Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setModalState(() {
                            currentPage = index;
                          });
                        },
                        children: [
                          // Página 1 - Introducción
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 14),
                                Text(
                                  'Introducción\n',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                Text(
                                  'Este instrumento establece las condiciones que regirán la relación entre La Sociedad Mercantil ' + 
                                  '“Mindsolutions C.A”, los psicólogos adscritos a la misma y los pacientes que requieren a través de su plataforma digital, de terapia psicológica entre otros servicios.',
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'Descripción del Servicio',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'A través de la Plataforma Digital “Mentalink”. “Mindsolutions C.A” ofrece a los pacientes los servicios de terapia psicológica bajo la modalidad online, con profesionales de la Psicología altamente calificados' +
                                  'y debidamente certificados. A través del acceso a la plataforma, el paciente podrá agendar su cita con el Psicólogo de su preferencia y realizar el pago correspondiente a través de los medios bancarios disponibles por el canal digital. ',
                                  textAlign: TextAlign.left,
                                ),
                                
                              ],
                            ),
                          ),
                          // Página 2 - Servicios Ofrecidos
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 14),
                                Text(
                                  'Condiciones del Servicio',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                SizedBox(height: 14),
                                Text(
                                  '-  El paciente deberá registrarse en la Plataforma, ingresando sus datos personales, y  podrá agendar su cita con el psicólogo de su preferencia, de acuerdo al horario disponible.',
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  '-  El paciente tendrá hasta 48 horas para cancelar su próxima consulta, en caso de que desee tener continuidad de atención con un Psicólogo especifico, de lo contrario perderá la disponibilidad de atención en la fecha y hora agendada, por lo que deberá reprogramar de acuerdo a la disponibilidad del mismo.',
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  '-  El paciente deberá contar con una conexión a internet adecuada y disponer del tiempo de duración de la sesión terapéutica. ',
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  '-  En caso de no poder asistir a la misma, deberá notificar a la Plataforma, con una anticipación de dos (02) horas previos a la consulta, y a través de los medios de contacto para que la misma sea reagendada. Queda entendido que el incumplimiento de ésta disposición ocasionará la imposibilidad de reagendar y la devolución del importe pagado por la sesión terapéutica.  ',
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 14),
                                
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 14),
                                Text(
                                  '-  El Paciente podrá notificar cualquier reclamo sobre los servicios recibidos a nivel de la Plataforma y por parte del Psicólogo tratante, a través de los medios de contacto de la Plataforma Digital.',
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  '-  El Paciente exime de cualquier responsabilidad a “Mindsolutions C.A”, por las actuaciones del Psicólogo que éste adscrito a la Plataforma Digital, de nacionalidad extranjera y que considere atenten contra las normas y principios que rigen el libre ejercicio de su profesión. De darse el mismo supuesto pero con un Psicólogo de nacionalidad Venezolana, que se encuentre prestando el servicio dentro del territorio nacional, frente a cualquier acción jurídica o denuncia ante algún órgano administrativo o judicial, “Mindsolutions C.A”, limita su responsabilidad en facilitar a éstos últimos, cualquier información relacionada al Psicólogo que consideren necesaria.',
                                  textAlign: TextAlign.left,
                                ),
    
                              ],
                            ),
                          ),
                          // Página 3 - Privacidad y Confidencialidad
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Condición de privacidad',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'Al usar o acceder a la  Plataforma Digital “Mentalink” el paciente o  usuario está aceptando la siguiente condición: Cuando usted visita nuestra plataforma, proporciona información personal de manera directa,  como su nombre, apellido, datos de contacto, nombre de usuario, etc; toda vez que se les son solicitadas; y de manera indirecta, toda vez que interactúa con nuestra plataforma por voluntad propia. En cualquiera de los casos, es decisión del usuario suministrar, o no, dicha información. ',
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'Seguridad',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'La participación en nuestra plataforma es voluntaria. Usted es responsable de mantener la confidencialidad de su ingreso y es totalmente responsable de todas las actividades que ocurran durante su interacción. ',
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Conducta de los miembros',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                SizedBox(height: 15),
                                Text(
                                  'Usted acepta no utilizar el sitio para:',
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 15),
                                Text(
                                  '– hacerse pasar por cualquier persona o entidad.',
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  '– publicar, enviar por correo electrónico, transmitir o poner a disposición de cualquier otro modo cualquier contenido que infrinja cualquier patente, marca comercial, secreto comercial, derechos de autor u otros derechos de propiedad de  “Mindsolutions C.A”, puestos a su disposición en la Plataforma Digital “Mentalink”.',
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  '– publicar, enviar por correo electrónico, transmitir o poner a disposición cualquier material que contenga virus de software o cualquier otro código informático, archivos o programas diseñados para interrumpir, destruir o limitar la funcionalidad de cualquier software o hardware informático o equipo de telecomunicaciones.',
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  '– interferir o interrumpir el sitio o los servidores o redes conectados al sitio, o desobedecer cualquier requisito, procedimiento, política o reglamento de las redes conectadas al sitio.',
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  '– recopilar o almacenar datos personales sobre otros usuarios.',
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                          // Página 4 - Modificaciones a los Términos
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 14),
                                Text(
                                  'Al aceptar estos términos y condiciones, usted acepta que “Mindsolutions C.A” tiene el derecho de (pero no la obligación), a su entera discreción, de editar, eliminar, rechazar o mover cualquier contenido que esté disponible a través del sitio. Usted acepta que debe evaluar y asumir todos los riesgos asociados con el uso de cualquier contenido.',
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'Usted reconoce y acepta que “Mindsolutions C.A” puede preservar el contenido y también puede divulgarlo si así lo exige la ley o si cree de buena fe que dicha preservación o divulgación es razonablemente necesaria para: (a) cumplir con un proceso legal; (b) hacer cumplir las Condiciones de uso y servicios para los usuarios de redes sociales y plataformas digitales; (c) responder a reclamos de que cualquier contenido que viole los derechos de terceros; o (d) proteger los derechos, la propiedad o la seguridad personal de “Mindsolutions C.A”, sus usuarios y el público.',
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 14),
                                Text(
                                  'Admoniciones especiales para uso internacional',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'Reconociendo la naturaleza global de Internet, usted se compromete a cumplir con todas las reglas locales relativas a la conducta en línea y al contenido aceptable. Específicamente, usted acepta cumplir con todas las leyes aplicables en relación con la transmisión de datos técnicos desde el país en el que reside.',
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'Indemnización',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'Usted acepta indemnizar y eximir de responsabilidad a “Mindsolutions C.A” por cualquier reclamación o demanda, incluidos los honorarios profesionales de los abogados, presentada por usted en contra del Psicólogo encargado de su atención psicológica, en virtud de la responsabilidad directa que recae sobre éste último.',
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 14),
                                Text(
                                  'No reventa del servicio',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'Usted se compromete a no reproducir, duplicar, copiar, vender, revender o explotar con fines comerciales, ninguna parte del sitio del servicio y su Plataforma Digital.',
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'Modificaciones al Servicio',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                SizedBox(height: 14),
                                Text(
                                  '“Mindsolutions C.A” se reserva el derecho de modificar o interrumpir, de forma temporal o permanente, el sitio (o cualquier parte del mismo) en cualquier momento. Usted acepta que “Mindsolutions C.A” no será responsable ante usted ni ante ningún tercero por cualquier modificación, suspensión o interrupción del sitio.',
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'Acciones de defensa',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                SizedBox(height: 14),
                                Text(
                                  '“Mindsolutions C.A” está en pleno derecho de bloquear de todas sus redes y plataformas a aquellos usuarios que no cumplan con las condiciones y términos aquí descritos. ',
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 14),
                                Text(
                                  'Condiciones de uso, avisos y revisiones',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'Nos reservamos el derecho de cambiar nuestra Política de Privacidad y nuestras Condiciones de Uso en cualquier momento. Si hacemos cambios, los publicaremos e informaremos a la comunidad de los cambios. Si hacemos cambios significativos a esta política, se lo notificaremos a través de un aviso en nuestra página de inicio. Le animamos a que consulte este documento de forma continuada para que entienda nuestra Política de Privacidad las cuales éstan previstas en la página web de “Mindsolutions C.A” y en la “Plataforma Digital Mentalink”.',
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'Contacto con el sitio web',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                SizedBox(height: 14),
                                Text(
                                  'Si tiene alguna pregunta sobre esta política de privacidad, algún requerimiento o reclamo,  por favor contacte al “Mindsolutions C.A” a través de cualquiera de nuestros medios de contacto.',
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (currentPage < 2)
                          CupertinoButton(
                            child: Text('Anterior'),
                            onPressed: () {
                              _pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            },
                          ),
                        if (currentPage < 2)
                          CupertinoButton(
                            child: Text('Siguiente'),
                            onPressed: () {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            },
                          ),
                      ],
                    ),
                    Divider(),
                    CupertinoButton(
                      child: Text('Cerrar'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Divider(),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _registro() async {
    if (!Terminos) {
      // Mostrar un mensaje de error si no se han aceptado los términos
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(
                "Debes aceptar los Términos y Condiciones para continuar."),
            actions: <Widget>[
              ElevatedButton(
                child: Text('Aceptar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      print(Terminos);

      dynamic registro = await Servicio().registrarUsuario({
        "nombre": widget.nombre,
        "apellido": widget.apellido,
        "correo": widget.correo,
        "telefono": _telefonoController.text,
        "contrasena": widget.contrasena,
        "genero": _selectedSexo ?? "",
        "fecha_nacimiento":
            "${selecionnarHora.year}-${selecionnarHora.month}-${selecionnarHora.day}",
        "pais": _selectedCountry?.name,
        "perfil_id": "5",
        "terminos_condiciones": "true"
      });

      String status = registro['status'];
      String title;
      String message;

      if (status == "success") {
        title = "Éxito";
        message = registro['message'];
      } else {
        title = "Error";
        message = registro['message'] ?? registro['error']['text'];
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: <Widget>[
              ElevatedButton(
                child: Text('Aceptar'),
                onPressed: () {
                  Navigator.of(context).pop();
                  if (status == "success") {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Inicio()),
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text(
                "Ha ocurrido un error al procesar la solicitud. Inténtelo de nuevo más tarde."),
            actions: <Widget>[
              ElevatedButton(
                child: Text('Aceptar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                "https://mentalink.org/assets/images/fondo.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  width: 260,
                  child: Image.network(
                    'https://mentalink.org/assets/images/Logo_Mentalink.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 20),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 55,
                  child: TextFormField(
                    controller: _telefonoController,
                    onChanged: (value) {
                      setState(() {
                        _telefonoValido = value.isEmpty ||
                            RegExp(r'^[0-9]+$').hasMatch(value);
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Teléfono',
                      prefixIcon: Icon(Icons.phone, color: Color(0xFFa7a7a9)),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2.0, color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelStyle: TextStyle(color: Color(0xFFa7a7a9)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    cursorColor: Colors.white,
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                if (!_telefonoValido && _telefonoController.text.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.only(left: 60),
                      child: Text(
                        'Este campo solo debe contener números',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.0),

                SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 55,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'País',
                    prefixIcon: Icon(Icons.public, color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2.0, color: Colors.white),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    labelStyle: TextStyle(color: Colors.grey),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: false,
                        countryListTheme: CountryListThemeData(
                          // Personalización del diseño del picker
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40.0),
                            topRight: Radius.circular(40.0),
                          ),
                          inputDecoration: InputDecoration(
                            labelText: 'Buscar',
                            hintText: 'Comienza a escribir para buscar',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color(0xFF8C98A8).withOpacity(0.2),
                              ),
                            ),
                          ),
                          searchTextStyle: TextStyle(
                            color: Colors.blue,
                            fontSize: 18,
                          ),
                        ),
                        onSelect: (Country country) {
                          setState(() {
                            _selectedCountry = country;
                          });
                        },
                      );
                    },
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _selectedCountry != null
                            ? '${_selectedCountry!.name}'
                            : 'Seleccione un país',
                        style: TextStyle(
                          color: _selectedCountry != null
                              ? Colors.white
                              : Color(0xFFa7a7a9),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                ),

                SizedBox(height: 20.0),

                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 56,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Género',
                      prefixIcon: Icon(Icons.person, color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2.0, color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.white,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: opcionesGenero.map((gender) {
                                return ListTile(
                                  title: Text(
                                    gender,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedSexo = gender;
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              }).toList(),
                            );
                          },
                        );
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _selectedSexo ?? 'Seleccione un género',
                          style: TextStyle(
                            color: _selectedSexo != null
                                ? Colors.white
                                : Color(0xFFa7a7a9),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: 55,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Fecha de Nacimiento',
                      hintStyle: TextStyle(color: Color(0xFFa7a7a9)),
                      prefixIcon:
                          Icon(Icons.calendar_today, color: Colors.grey),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 2.0, color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () => _selectDate(context),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          showCalendarIcon
                              ? 'Seleccione una fecha'
                              : '${selecionnarHora.day}/${selecionnarHora.month}/${selecionnarHora.year}',
                          style: TextStyle(
                            color: showCalendarIcon
                                ? Color(0xFFa7a7a9)
                                : Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 14.0),
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Row(
                    children: [
                      CupertinoCheckbox(
                        value: Terminos,
                        onChanged: (bool? value) {
                          setState(() {
                            Terminos = value ?? false;
                          });
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          modalTerminosyCondiciones(context);
                        },
                        child: Text(
                          'Acepto los Términos y Condiciones',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ElevatedButton(
                    onPressed: _registro,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Color.fromARGB(255, 0, 188, 207),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(width: 2.0, color: Colors.white),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Finalizar Registro',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.only(top: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoButton(
                        onPressed: () => modalTerminosyCondiciones(context),
                        child: Text(
                          'Términos y Condiciones',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}