import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final void Function(TimeOfDay) onTimeSelected;

  const CustomTimePicker({
    required this.initialTime,
    required this.onTimeSelected,
    Key? key,
  }) : super(key: key);

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
      ),
      child: Container(
        height: MediaQuery.of(context).size.width * 0.6,
        child: Column(
          children: [
            SizedBox(
              height: 160,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(2000, 1, 1, _selectedTime.hour, _selectedTime.minute),
                onDateTimeChanged: (DateTime dateTime) {
                  setState(() {
                    _selectedTime = TimeOfDay.fromDateTime(dateTime);
                  });
                },
              ),
            ),
            TextButton(
              onPressed: () {
                widget.onTimeSelected(_selectedTime);
              },
              child: Text(
                'Seleccionar',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Calendario extends StatefulWidget {
  final String? psicologoId;
  final String? correo;

  Calendario(this.psicologoId, this.correo, {Key? key}) : super(key: key);

  @override
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  late final String? idPsicologo;
  late final String? correo;
  late GoogleSignIn _googleSignIn;
  calendar.CalendarApi? _calendarApi;
  String _authenticationResult = '';
  String _calendarResponse = '';
  String conferenceLink = '';
  String id_evento = '';
  String direccion = 'Dirección Mentalink'; // Dirección fija para citas presenciales
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _conferenceLinkController = TextEditingController();
  
  bool eventoCreado = false; 

  @override
  void initState() {
    super.initState();
    idPsicologo = widget.psicologoId;
    correo = widget.correo;
    _googleSignIn = GoogleSignIn(scopes: [calendar.CalendarApi.calendarScope]);
    _conferenceLinkController.text = conferenceLink;
  }

  Future<void> _initGoogleSignIn() async {
    try {
      await _googleSignIn.signIn();
      var googleAuth = await _googleSignIn.currentUser!.authentication;

      var expiry = DateTime.now().toUtc().add(Duration(minutes: 20));
      var credentials = auth.AccessCredentials(
        auth.AccessToken(
          'Bearer',
          googleAuth.accessToken!,
          expiry,
        ),
        null,
        [calendar.CalendarApi.calendarScope],
      );

      var httpClient = auth.authenticatedClient(http.Client(), credentials);

      _calendarApi = calendar.CalendarApi(httpClient);

      if (remota) {
        await _handleSignInAndGenerateLink();
      }
    } catch (error) {
      setState(() {
        _authenticationResult = 'Error al iniciar sesión con Google: $error';
      });
    }
  }

  Future<void> _handleSignInAndGenerateLink() async {
    try {
      await _initGoogleSignIn();
    } catch (error) {
      print('Error al iniciar sesión y generar enlace de reunión: $error');
      setState(() {
        _authenticationResult = '$error';
      });
    }
  }

  List<DateTime> coloredDates = [];
  DateTime seleccionarFecha = DateTime.now();
  TimeOfDay hora = TimeOfDay.now();
  bool presencial = false;
  bool remota = false;

  /*Future<void> _agendarCita() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String usuarioId = prefs.getString('usuario_id') ?? "";

    if (_descriptionController.text.isEmpty || seleccionarFecha == null || hora == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Complete Todos Los Campos!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color.fromARGB(255, 0, 188, 207),
        ),
      );
      return;
    }

    String tipoCita;
    if (presencial) {
      tipoCita = 'presencial';
    } else if (remota) {
      tipoCita = 'remota';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Seleccione al menos un tipo de cita (presencial o remota)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Color.fromARGB(255, 0, 188, 207),
        ),
      );
      return;
    }

    DateTime startDateTime = DateTime(
      seleccionarFecha.year,
      seleccionarFecha.month,
      seleccionarFecha.day,
      hora.hour,
      hora.minute,
    ).toUtc();

    try {

      var endDateTime = startDateTime.add(Duration(hours: 1));

      List<Map<String, dynamic>> attendees = [{'email': correo}];

      var event = calendar.Event.fromJson({
        'summary': 'Cita Remota',
        'description': _descriptionController.text,
        'start': {'dateTime': startDateTime.toIso8601String(), 'timeZone': 'UTC'},
        'end': {'dateTime': endDateTime.toIso8601String(), 'timeZone': 'UTC'},
        'attendees': attendees,
        'conferenceData': {
          "createRequest": {
            "requestId": "mentalink",
            "conferenceSolutionKey": {"type": "hangoutsMeet"}
          }
        }
      });

      var createdEvent = await _calendarApi!.events.insert(event, 'primary',
          conferenceDataVersion: 1);

      var conferenceData = createdEvent.conferenceData;
      String conferenceLink = conferenceData?.entryPoints?[0].uri ?? '';

      // Actualizar el controlador del enlace de conferencia
      _conferenceLinkController.text = conferenceLink;

      // Llamar al servicio para agendar la cita
      Map<String, dynamic> data = {
        'psicologo_id': idPsicologo,
        'paciente_id': usuarioId,
        'fecha_hora': startDateTime.toIso8601String(),
        'descripcion': _descriptionController.text,
        'tipo_cita': tipoCita,
        'link': conferenceLink, // Usar conferenceLink obtenido del evento en Google Calendar
      };

      final response = await Servicio().angendarCita(data);

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              response['message'],
              textAlign: TextAlign.center,
            ),
          ),
        );

        setState(() {
          _calendarResponse = 'Evento creado en Google Calendar: ${createdEvent.summary}';
          this.conferenceLink = conferenceLink;
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              response['message'],
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error al crear la reunión remota.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    Map<String, dynamic> data;
    if (presencial) {
      data = {
        'psicologo_id': idPsicologo,
        'paciente_id': usuarioId,
        'fecha_hora': startDateTime.toIso8601String(),
        'descripcion': _descriptionController.text,
        'tipo_cita': tipoCita,
        'direccion': direccion, // Dirección para citas presenciales
      };
    } else {
      data = {
        'psicologo_id': idPsicologo,
        'paciente_id': usuarioId,
        'fecha_hora': startDateTime.toIso8601String(),
        'descripcion': _descriptionController.text,
        'tipo_cita': tipoCita,
        'link': conferenceLink, // Enlace para citas remotas
      };
    }

    try {
      final response = await Servicio().angendarCita(data);

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              response['message'],
              textAlign: TextAlign.center,
            ),
          ),
        );

        if (presencial) {
          Clipboard.setData(ClipboardData(text: direccion));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dirección copiada al portapapeles'),
            ),
          );
        }

        if (remota && conferenceLink.isNotEmpty) {
          Clipboard.setData(ClipboardData(text: conferenceLink));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Enlace copiado al portapapeles'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              response['message'],
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Error al crear la reunión.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }*/


/*Future<void> _agendarCita() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String usuarioId = prefs.getString('usuario_id') ?? "";

  if (_descriptionController.text.isEmpty || seleccionarFecha == null || hora == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡Complete Todos Los Campos!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 0, 188, 207),
      ),
    );
    return;
  }

  String tipoCita;
  if (presencial) {
    tipoCita = 'presencial';
  } else if (remota) {
    tipoCita = 'remota';
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Seleccione al menos un tipo de cita (presencial o remota)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 0, 188, 207),
      ),
    );
    return;
  }

  DateTime startDateTime = DateTime(
    seleccionarFecha.year,
    seleccionarFecha.month,
    seleccionarFecha.day,
    hora.hour,
    hora.minute,
  ).toUtc();

  try {
    if (remota) {
      var endDateTime = startDateTime.add(Duration(hours: 1));
      List<Map<String, dynamic>> attendees = [{'email': correo}];

      var event = calendar.Event.fromJson({
        'summary': 'Cita Remota',
        'description': _descriptionController.text,
        'start': {'dateTime': startDateTime.toIso8601String(), 'timeZone': 'UTC'},
        'end': {'dateTime': endDateTime.toIso8601String(), 'timeZone': 'UTC'},
        'attendees': attendees,
        'conferenceData': {
          "createRequest": {
            "requestId": "mentalink",
            "conferenceSolutionKey": {"type": "hangoutsMeet"}
          }
        }
      });

      var createdEvent = await _calendarApi!.events.insert(event, 'primary', conferenceDataVersion: 1);
      var conferenceData = createdEvent.conferenceData;
      String conferenceLink = conferenceData?.entryPoints?[0].uri ?? '';
      String id_evento = createdEvent.id ?? '';

      _conferenceLinkController.text = conferenceLink;

      Map<String, dynamic> data = {
        'psicologo_id': idPsicologo,
        'paciente_id': usuarioId,
        'fecha_hora': startDateTime.toIso8601String(),
        'descripcion': _descriptionController.text,
        'tipo_cita': tipoCita,
        'link': conferenceLink,
        'id_evento': id_evento
      };

      final response = await Servicio().angendarCita(data);

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              response['message'],
              textAlign: TextAlign.center,
            ),
          ),
        );
        setState(() {
          eventoCreado = true;
          this.conferenceLink = conferenceLink;
        });
      } else {
        await _calendarApi!.events.delete('primary', createdEvent.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Error al crear la cita: ${response['message']}',
              textAlign: TextAlign.center,
            ),
          ),
        );
        return;
      }
    } else {
      // Para citas presenciales
      Map<String, dynamic> data = {
        'psicologo_id': idPsicologo,
        'paciente_id': usuarioId,
        'fecha_hora': startDateTime.toIso8601String(),
        'descripcion': _descriptionController.text,
        'tipo_cita': tipoCita,
        'direccion': direccion, // Dirección para citas presenciales
      };

      final response = await Servicio().angendarCita(data);

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              response['message'],
              textAlign: TextAlign.center,
            ),
          ),
        );
        setState(() {
          eventoCreado = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Error al crear la cita: ${response['message']}',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Error al crear la cita.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}*/

Future<void> _agendarCita() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String usuarioId = prefs.getString('usuario_id') ?? "";

  if (_descriptionController.text.isEmpty || seleccionarFecha == null || hora == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡Complete Todos Los Campos!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 0, 188, 207),
      ),
    );
    return;
  }

  String tipoCita;
  if (presencial) {
    tipoCita = 'presencial';
  } else if (remota) {
    tipoCita = 'remota';
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Seleccione al menos un tipo de cita (presencial o remota)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 0, 188, 207),
      ),
    );
    return;
  }

  // Crea el DateTime en la zona horaria local
  DateTime localDateTime = DateTime(
    seleccionarFecha.year,
    seleccionarFecha.month,
    seleccionarFecha.day,
    hora.hour,
    hora.minute,
  );

  // Convierte a UTC para Google Calendar
  DateTime startDateTimeUtc = localDateTime.toUtc();

  try {
    if (remota) {
      var endDateTimeUtc = startDateTimeUtc.add(Duration(hours: 1));
      List<Map<String, dynamic>> attendees = [{'email': correo}];

      var event = calendar.Event.fromJson({
        'summary': 'Cita Remota',
        'description': _descriptionController.text,
        'start': {'dateTime': startDateTimeUtc.toIso8601String(), 'timeZone': 'UTC'},
        'end': {'dateTime': endDateTimeUtc.toIso8601String(), 'timeZone': 'UTC'},
        'attendees': attendees,
        'conferenceData': {
          "createRequest": {
            "requestId": "mentalink",
            "conferenceSolutionKey": {"type": "hangoutsMeet"}
          }
        }
      });

      var createdEvent = await _calendarApi!.events.insert(event, 'primary', conferenceDataVersion: 1);
      var conferenceData = createdEvent.conferenceData;
      String conferenceLink = conferenceData?.entryPoints?[0].uri ?? '';
      String id_evento = createdEvent.id ?? '';

      _conferenceLinkController.text = conferenceLink;

      // Usa la hora local para el servicio propio
      Map<String, dynamic> data = {
        'psicologo_id': idPsicologo,
        'paciente_id': usuarioId,
        'fecha_hora': localDateTime.toIso8601String(),
        'descripcion': _descriptionController.text,
        'tipo_cita': tipoCita,
        'link': conferenceLink,
        'id_evento': id_evento
      };

      final response = await Servicio().angendarCita(data);

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              response['message'],
              textAlign: TextAlign.center,
            ),
          ),
        );
        setState(() {
          eventoCreado = true;
          this.conferenceLink = conferenceLink;
        });
      } else {
        await _calendarApi!.events.delete('primary', createdEvent.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Error al crear la cita: ${response['message']}',
              textAlign: TextAlign.center,
            ),
          ),
        );
        return;
      }
    } else {
      // Para citas presenciales
      Map<String, dynamic> data = {
        'psicologo_id': idPsicologo,
        'paciente_id': usuarioId,
        'fecha_hora': localDateTime.toIso8601String(),
        'descripcion': _descriptionController.text,
        'tipo_cita': tipoCita,
        'direccion': direccion, // Dirección para citas presenciales
      };

      final response = await Servicio().angendarCita(data);

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              response['message'],
              textAlign: TextAlign.center,
            ),
          ),
        );
        setState(() {
          eventoCreado = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Error al crear la cita: ${response['message']}',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          'Error al crear la cita.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 10,
          margin: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 10),
          child: Container(
            padding: EdgeInsets.all(5),
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  secondary: Theme.of(context).primaryColor,
                ),
              ),
              child: _buildDatePicker(),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 25, bottom: 10),
          width: MediaQuery.of(context).size.width * 0.5,
          child: ElevatedButton(
            onPressed: () {
              _showCustomTimePicker(context);
            },
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
              'Seleccionar Hora',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 30),
          child: Text(
            'Fecha seleccionada: ${DateFormat('dd/MM/yyyy', 'es').format(seleccionarFecha)}',
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 30),
          child: Text(
            'Hora seleccionada: ${_formatHora(hora)}',
          ),
        ),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.only(left: 25),
          child: Row(
            children: [
              Checkbox(
                value: presencial,
                onChanged: (value) {
                  setState(() {
                    presencial = value!;
                    remota = false;
                  });
                },
              ),
              Text('Presencial'),
              SizedBox(width: 20),
              Checkbox(
                value: remota,
                onChanged: (value) {
                  setState(() {
                    remota = value!;
                    presencial = false;
                    if (remota) {
                      _handleSignInAndGenerateLink();
                    }
                  });
                },
              ),
              Text('Remota'),
            ],
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: EdgeInsets.only(left: 25),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.75,
            padding: EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey),
            ),
            child: TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Descripción',
                border: InputBorder.none,
              ),
              cursorColor: Color.fromARGB(255, 0, 188, 207),
            ),
          ),
        ),
        Center(
          child: Container(
            margin: EdgeInsets.only(top: 15, bottom: 15),
            width: MediaQuery.of(context).size.width * 0.4,
            child: ElevatedButton(
              onPressed: () {
                _agendarCita();
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Color.fromRGBO(9, 25, 87, 1.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(width: 2.0, color: Colors.white),
                ),
                elevation: 5,
              ),
              child: Text(
                'Agendar Cita',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Container(
            margin: EdgeInsets.only(top: 15, bottom: 15),
            width: MediaQuery.of(context).size.width * 0.4,
            child: ElevatedButton(
              onPressed: () {
                reportarPago(context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Color.fromRGBO(9, 25, 87, 1.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(width: 2.0, color: Colors.white),
                ),
                elevation: 5,
              ),
              child: Text(
                'Reportar Pago',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        /*Padding(
          padding: EdgeInsets.only(left: 25, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_calendarResponse.isNotEmpty)
                Text(
                  _calendarResponse,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 10),
              if (remota)
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: TextField(
                    enabled: eventoCreado, // Habilitar el campo solo si el evento fue creado
                    controller: _conferenceLinkController,
                    decoration: InputDecoration(
                      hintText: 'Enlace de la reunión',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.content_copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: conferenceLink));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Enlace copiado al portapapeles'),
                            ),
                          );
                        },
                      ),
                      border: InputBorder.none,
                    ),
                    cursorColor: Color.fromARGB(255, 0, 188, 207),
                  ),
                ),
              if (presencial)
                Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: TextField(
                    enabled: true,
                    controller: TextEditingController(text: direccion),
                    decoration: InputDecoration(
                      hintText: 'Dirección de reunión',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.content_copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: direccion));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Dirección copiada al portapapeles'),
                            ),
                          );
                        },
                      ),
                      border: InputBorder.none,
                    ),
                    cursorColor: Color.fromARGB(255, 0, 188, 207),
                  ),
                ),
            ],
          ),
        ),*/
        Padding(
          padding: EdgeInsets.only(left: 25, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_calendarResponse.isNotEmpty)
                Text(
                  _calendarResponse,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 10),
              if (eventoCreado) ...[
                if (remota)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      enabled: eventoCreado,
                      controller: _conferenceLinkController,
                      decoration: InputDecoration(
                        hintText: 'Enlace de la reunión',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.content_copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: conferenceLink));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Enlace copiado al portapapeles'),
                              ),
                            );
                          },
                        ),
                        border: InputBorder.none,
                      ),
                      cursorColor: Color.fromARGB(255, 0, 188, 207),
                    ),
                  ),
                if (presencial)
                  Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: TextField(
                      enabled: false, // Solo lectura
                      controller: TextEditingController(text: direccion),
                      decoration: InputDecoration(
                        hintText: 'Dirección de reunión',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.content_copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: direccion));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Dirección copiada al portapapeles'),
                              ),
                            );
                          },
                        ),
                        border: InputBorder.none,
                      ),
                      cursorColor: Color.fromARGB(255, 0, 188, 207),
                    ),
                  ),
                
              ],
            ],
          ),
        ),

      ],
    );
  }

  Widget _buildDatePicker() {
    return SfDateRangePicker(
      todayHighlightColor: Color.fromRGBO(0, 189, 206, 1),
      selectionColor: Color.fromRGBO(0, 189, 206, 1),
      startRangeSelectionColor: Color.fromRGBO(0, 189, 206, 1),
      selectionTextStyle: TextStyle(color: Colors.black),
      headerStyle: DateRangePickerHeaderStyle(
        textStyle: TextStyle(color: Colors.black),
      ),
      navigationDirection: DateRangePickerNavigationDirection.horizontal,
      showActionButtons: true,
      enablePastDates: false,
      selectionShape: DateRangePickerSelectionShape.circle,
      showNavigationArrow: true,
      selectableDayPredicate: (DateTime date) {
        return !coloredDates.contains(date) &&
            date.weekday != DateTime.saturday &&
            date.weekday != DateTime.sunday;
      },
      onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
        setState(() {
          seleccionarFecha = args.value;
        });
      },
      onSubmit: (_) {
        _showCustomTimePicker(context);
      },
    );
  }

  String _formatHora(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final formattedTime = DateFormat.jm().format(dateTime);
    return formattedTime;
  }

  void _showCustomTimePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return CustomTimePicker(
          initialTime: hora,
          onTimeSelected: (TimeOfDay selectedTime) {
            setState(() {
              hora = selectedTime;
            });
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  /*void reportarPago(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return ConstrainedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 5),
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(127, 127, 136, 0.988),
                  borderRadius:
                      BorderRadius.circular(2),
                ),
              ),
              Text(
                'Reportar Pago',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Número de Transacción',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Fecha de Transacción',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {

                },
                child: Text('Enviar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(9, 25, 87, 1.0),
                ),
              ),
            ],
          ),
        );
      },
    );
  }*/

  void reportarPago(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 5),
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(127, 127, 136, 0.988),
                    borderRadius:
                        BorderRadius.circular(2),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text(
                    'Reportar Pago',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Cédula',
                  labelStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey[600],
                  ),
                  filled: true,
                  fillColor: Colors.blueGrey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  isDense: true,
                ),
              ),

              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Referencia',
                  labelStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey[600],
                  ),
                  filled: true,
                  fillColor: Colors.blueGrey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  isDense: true,
                ),
              ),

              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  labelStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey[600],
                  ),
                  filled: true,
                  fillColor: Colors.blueGrey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  isDense: true,
                ),
              ),

              SizedBox(height: 16),

              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Banco',
                  labelStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey[600],
                  ),
                  filled: true,
                  fillColor: Colors.blueGrey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  isDense: true,
                ),
              ),

              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  labelStyle: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey[600],
                  ),
                  filled: true,
                  fillColor: Colors.blueGrey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  isDense: true, 
                ),
              ),

              SizedBox(height: 24),

              Center(
                child: SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      
                    },
                    child: Text('Enviar'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.transparent, backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                      side: BorderSide(color: Colors.transparent),
                      elevation: 0,
                    )
                  ),
                ),
              ),

            ],
          ),
        );
      },
    );
  }

}
