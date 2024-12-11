import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class Meet extends StatefulWidget {
  const Meet({Key? key}) : super(key: key);

  @override
  _MeetState createState() => _MeetState();
}

class _MeetState extends State<Meet> {
  late GoogleSignIn _googleSignIn;
  late calendar.CalendarApi _calendarApi;
  String _authenticationResult = '';
  String _calendarResponse = '';

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn(scopes: [calendar.CalendarApi.calendarScope]);
  }

  void _initGoogleSignIn() async {
    try {
      await _googleSignIn.signIn();
      var googleAuth = await _googleSignIn.currentUser!.authentication;

      setState(() {
        _authenticationResult = 'Autenticación exitosa con Google: ${_googleSignIn.currentUser!.displayName}';
      });

      // Configurar las credenciales de acceso
      //var expiry = DateTime.now().toUtc().add(Duration(hours: 1));
      var expiry = DateTime.now().toUtc().add(Duration(minutes: 20));
      var credentials = AccessCredentials(
        AccessToken(
          'Bearer',
          googleAuth.accessToken!,
          expiry,
        ),
        null, // No se necesita token de actualización
        [calendar.CalendarApi.calendarScope],
      );


      // Crear un cliente HTTP autenticado
      var httpClient = authenticatedClient(http.Client(), credentials);

      // Inicializar la API de Calendar
      _calendarApi = calendar.CalendarApi(httpClient);

      // Generar enlace de reunión al iniciar sesión exitosamente
      await generateMeetingLink();
    } catch (error) {
      setState(() {
        _authenticationResult = 'Error al iniciar sesión con Google: $error';
      });
    }
  }

  Future<void> _handleSignInAndGenerateLink() async {
    try {
      _initGoogleSignIn();
    } catch (error) {
      print('Error al iniciar sesión y generar enlace de reunión: $error');
      setState(() {
        _authenticationResult = '$error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Generador de enlaces de Google Meet')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _handleSignInAndGenerateLink,
                child: Text('Generar Enlace de Reunión'),
              ),
              SizedBox(height: 20),
              Text(
                _authenticationResult,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                _calendarResponse,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Future<void> generateMeetingLink() async {
    try {
      var startDateTime = DateTime.now().toUtc().toIso8601String();
      var endDateTime =
          DateTime.now().add(Duration(hours: 1)).toUtc().toIso8601String();

      var event = calendar.Event.fromJson({
        'summary': 'Reunión de prueba',
        'description': 'Reunión generada desde Flutter',
        'start': {'dateTime': startDateTime, 'timeZone': 'UTC'},
        'end': {'dateTime': endDateTime, 'timeZone': 'UTC'},
        'conferenceData': {
          "createRequest": {
            "requestId": "mentalink",
            "conferenceSolutionKey": {
              "type": "hangoutsMeet"
            }
          }
        }
      });

      // Insertar el evento en Google Calendar
      var createdEvent = await _calendarApi.events.insert(event, 'primary',
          conferenceDataVersion: 1);

      // Obtener el enlace de la conferencia
      var conferenceData = createdEvent.conferenceData;
      var conferenceLink = conferenceData?.entryPoints?[0].uri ?? '';

      setState(() {
        _calendarResponse =
            'Evento creado en Google Calendar: ${createdEvent.summary}\nEnlace de Google Meet: $conferenceLink';
      });
    } catch (e) {
      setState(() {
        _calendarResponse =
            'Error al generar el enlace de reunión y crear el evento: $e';
      });
    }
  }
}
