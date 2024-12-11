import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:mentalink/src/Clases/appbar.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class ProcesarCita extends StatefulWidget {
  final DateTime fechaSeleccionada;
  final TimeOfDay horaSeleccionada;
  final bool presencial;
  final bool remota;
  final String descripcion;
  final String? idPsicologo;
  final String usuarioId;
  final String? correo;
  final String direccion;
  final calendar.CalendarApi? calendarApi;

  const ProcesarCita({
    required this.fechaSeleccionada,
    required this.horaSeleccionada,
    required this.presencial,
    required this.remota,
    required this.descripcion,
    required this.idPsicologo,
    required this.usuarioId,
    required this.correo,
    required this.direccion,
    this.calendarApi,
    Key? key,
  }) : super(key: key);

  @override
  _ProcesarCitaState createState() => _ProcesarCitaState();
}

class _ProcesarCitaState extends State<ProcesarCita> {
  final TextEditingController _conferenceLinkController = TextEditingController();
  late GoogleSignIn _googleSignIn;
  String? _errorMessage; // Variable para guardar mensajes de error

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn();
  }

  appbar appbarAux = appbar("","");
  Map<String, dynamic> usuarioData = {};

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

  Future<void> _agendarCita() async {
    String usuarioId = widget.usuarioId;
    String idPsicologo = widget.idPsicologo ?? "";
    String? correo = widget.correo;
    String direccion = widget.direccion;

    DateTime localDateTime = DateTime(
      widget.fechaSeleccionada.year,
      widget.fechaSeleccionada.month,
      widget.fechaSeleccionada.day,
      widget.horaSeleccionada.hour,
      widget.horaSeleccionada.minute,
    );

    DateTime startDateTimeUtc = localDateTime.toUtc();

    try {
      if (widget.remota && widget.calendarApi != null) {
        var endDateTimeUtc = startDateTimeUtc.add(Duration(hours: 1));
        List<Map<String, dynamic>> attendees = [{'email': correo ?? ''}];

        var event = calendar.Event.fromJson({
          'summary': 'Cita Remota',
          'description': widget.descripcion,
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

        var createdEvent = await widget.calendarApi!.events.insert(event, 'primary', conferenceDataVersion: 1);
        var conferenceData = createdEvent.conferenceData;
        String conferenceLink = conferenceData?.entryPoints?[0].uri ?? '';

        _conferenceLinkController.text = conferenceLink;

        Map<String, dynamic> data = {
          'psicologo_id': idPsicologo,
          'paciente_id': usuarioId,
          'fecha_hora': localDateTime.toIso8601String(),
          'descripcion': widget.descripcion,
          'tipo_cita': 'remota',
          'link': conferenceLink,
          'id_evento': createdEvent.id ?? ''
        };

        final response = await Servicio().angendarCita(data);

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text(response['message'], textAlign: TextAlign.center),
          ));
        } else {
          await widget.calendarApi!.events.delete('primary', createdEvent.id!);
          setState(() {
            _errorMessage = 'Error al crear la cita: ${response['message']}';
          });
        }
      } else {
        // Cita presencial
        Map<String, dynamic> data = {
          'psicologo_id': idPsicologo,
          'paciente_id': usuarioId,
          'fecha_hora': localDateTime.toIso8601String(),
          'descripcion': widget.descripcion,
          'tipo_cita': 'presencial',
          'direccion': direccion,
        };

        final response = await Servicio().angendarCita(data);

        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text(response['message'], textAlign: TextAlign.center),
          ));
        } else {
          setState(() {
            _errorMessage = 'Error al crear la cita: ${response['message']}';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al crear la cita: $e';
      });
    }
  }

  Future<void> _pagarConPayPal() async {
    try {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => PaypalCheckoutView(
          sandboxMode: true,
          clientId: "AdyAw0Fl6dJSxf53dZCtpcRWcwoW-rdjtbZm94uDpyGnPjPD71dCDQJyVgQZkH5GAbS5owVRURBlS4wM",
          secretKey: "ECSo6h98xVSWnt4i-OAc2zEU2-8FcPmwkgEXOuqHH7k7qu5naRFOcItXQ1wGDn9lvFJgpKBF-Um_gOsM",
          transactions: const [
            {
              "amount": {
                "total": '10.12',
                "currency": "USD",
                "details": {
                  "subtotal": '10.12',
                  "shipping": '0',
                  "shipping_discount": 0
                }
              },
              "description": "Cita Psicológica",
              "item_list": {
                "items": [
                  {
                    "name": "Cita Psicológica",
                    "quantity": 1,
                    "price": '10.12',
                    "currency": "USD"
                  }
                ],
              },
            }
          ],
          note: "Orden de Pago Cita.",
          onSuccess: (Map params) async {
            log("onSuccess: $params");
            await _agendarCita();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Pago exitoso: ${params.toString()}'),
            ));
            Navigator.pop(context);
          },
          onError: (error) {
            log("onError: $error");
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text('Error: $error'),
            ));
            //Navigator.pop(context);
          },
          onCancel: () {
            log('cancelled:');
            //Navigator.pop(context);
          },
        ),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: appbarAux.getAppbar(context),

      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detalles de la Cita', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Psicólogo: ${widget.idPsicologo ?? 'No asignado'}', style: TextStyle(fontSize: 16)),
                  Text('Fecha: ${widget.fechaSeleccionada.toLocal()}'.split(' ')[0], style: TextStyle(fontSize: 16)),
                  Text('Hora: ${widget.horaSeleccionada.format(context)}', style: TextStyle(fontSize: 16)),
                  Text('Tipo de Cita: ${widget.remota ? 'Remota' : 'Presencial'}', style: TextStyle(fontSize: 16)),
                  Text('Descripción: ${widget.descripcion}', style: TextStyle(fontSize: 16)),
                  if (widget.remota) Text('Enlace de Conferencia: ${_conferenceLinkController.text}', style: TextStyle(fontSize: 16)),
                  SizedBox(height: 20),
                ],
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ElevatedButton(
              onPressed: _pagarConPayPal,
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
                'Pagar con PayPal',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),
            /*ElevatedButton(
              onPressed: _pagarConVeepo,
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
                'Pagar con Veepo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),*/
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _agendarCita,
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
                'Confirmar Cita',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
