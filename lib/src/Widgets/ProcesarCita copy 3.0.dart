import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:mentalink/src/Clases/appbar.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mentalink/src/Widgets/ModalPagoMovil.dart';
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
  final String costoCita;
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
    required this.costoCita,
    this.calendarApi,
    Key? key,
  }) : super(key: key);

  @override
  _ProcesarCitaState createState() => _ProcesarCitaState();
}

class _ProcesarCitaState extends State<ProcesarCita> {
  final TextEditingController _conferenceLinkController =
      TextEditingController();
  late GoogleSignIn _googleSignIn;
  String? _errorMensaje;

  double dolarPromedio = 0.0;

  bool cargando = false;
  bool errorDolar = false;

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn();

  }

  appbar appbarAux = appbar("", "");
  Map<String, dynamic> usuarioData = {};
  Map<String, dynamic> dolarData = {};

  obtenerDatosUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String usuarioId = prefs.getString('usuario_id') ?? "";
    String? tipoUsuario = prefs.getString('tipo_usuario');
    appbarAux.setId(usuarioId);

    usuarioData = await Servicio().obtenerUsuario(int.parse(usuarioId));
    appbarAux.setRutaImagenPerfil(usuarioData['foto']);

    await prefs.setString('fotoPerfil', usuarioData['foto']);
  }

  Future<Map<String, dynamic>> _agendarCita(String paypalTransactionId) async {
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
    Map<String, dynamic> response;

    try {
      if (widget.remota && widget.calendarApi != null) {
        var endDateTimeUtc = startDateTimeUtc.add(Duration(hours: 1));
        List<Map<String, dynamic>> attendees = [
          {'email': correo ?? ''}
        ];

        var event = calendar.Event.fromJson({
          'summary': 'Cita Remota',
          'description': widget.descripcion,
          'start': {
            'dateTime': startDateTimeUtc.toIso8601String(),
            'timeZone': 'UTC'
          },
          'end': {
            'dateTime': endDateTimeUtc.toIso8601String(),
            'timeZone': 'UTC'
          },
          'attendees': attendees,
          'conferenceData': {
            "createRequest": {
              "requestId": "mentalink",
              "conferenceSolutionKey": {"type": "hangoutsMeet"}
            }
          }
        });

        var createdEvent = await widget.calendarApi!.events
            .insert(event, 'primary', conferenceDataVersion: 1);
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
          'id_evento': createdEvent.id ?? '',
          'costo': widget.costoCita,
          'pago': paypalTransactionId,
        };

        response = await Servicio().angendarCita(data);

        if (response['status'] != 'success') {
          await widget.calendarApi!.events.delete('primary', createdEvent.id!);
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
          'costo': widget.costoCita,
          'pago': paypalTransactionId,
        };

        response = await Servicio().angendarCita(data);
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error al crear la cita: $e'};
    }

    return response;
  }

  Future<void> _pagarConPayPal() async {
    try {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => PaypalCheckoutView(
          sandboxMode: false,
          clientId:
              "AYOOW-oRjTtyOtJyumPDl-LADSPKXmpj1GfP5WoUkZP-mew8vGWDOqnsDj98W-YD4aIElk2fBPuwY-Fe",
          secretKey:
              "EPaElzV06FgIlJjaL1c58rU9SgV8oYlWF1UNmOXuCAcPN2hwxYnSBmCtPyzgGyHAVpjeBcrWpR4yKJ4N",
          transactions: [
            {
              "amount": {
                "total": widget.costoCita,
                "currency": "USD",
                "details": {
                  "subtotal": widget.costoCita,
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
                    "price": widget.costoCita,
                    "currency": "USD"
                  }
                ],
              },
            }
          ],
          note: "Orden de Pago Cita.",
          onSuccess: (Map params) async {
            log("onSuccess: $params");

            // Obtener el ID de la transacción de la respuesta de PayPal
            String paypalTransactionId = params['data']['id'] ?? '';

            // Agendar la cita, pasando el ID de PayPal
            Map<String, dynamic> agendarResponse =
                await _agendarCita(paypalTransactionId);

            // Verificar si el mensaje es 'success'
            String message = (params['message'] == 'Success')
                ? 'Cita Agendada Exitosamente!'
                : params['message'] ?? 'Pago exitoso';

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(message),
            ));

            // Redirigir a la ruta /citas
            Navigator.pushNamed(context, '/citas');
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
    String fechaHora =
        "${widget.fechaSeleccionada.day}/${widget.fechaSeleccionada.month}/${widget.fechaSeleccionada.year} "
        "${widget.horaSeleccionada.hour > 12 ? widget.horaSeleccionada.hour - 12 : widget.horaSeleccionada.hour}:${widget.horaSeleccionada.minute.toString().padLeft(2, '0')} ${widget.horaSeleccionada.hour >= 12 ? 'PM' : 'AM'}";

    return Scaffold(
      appBar: appbarAux.getAppbar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(12.0),

                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Detalles de la Cita",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(9, 25, 87, 1.0),
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(color: Colors.grey),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: Color.fromRGBO(9, 25, 87, 1.0)),
                            SizedBox(width: 8),
                            Text("Fecha y Hora:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(9, 25, 87, 1.0))),
                          ],
                        ),
                        Flexible(
                          child: Text(fechaHora,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: Color.fromRGBO(9, 25, 87, 1.0))),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(color: Colors.grey),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description,
                                color: Color.fromRGBO(9, 25, 87, 1.0)),
                            SizedBox(width: 8),
                            Text("Descripción:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(9, 25, 87, 1.0))),
                          ],
                        ),
                        Flexible(
                          child: Text(widget.descripcion,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: Color.fromRGBO(9, 25, 87, 1.0))),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Divider(color: Colors.grey),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                color: Color.fromRGBO(9, 25, 87, 1.0)),
                            SizedBox(width: 8),
                            Text("Tipo de Cita:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(9, 25, 87, 1.0))),
                          ],
                        ),
                        Flexible(
                          child: Text(widget.remota ? 'Remota' : 'Presencial',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: Color.fromRGBO(9, 25, 87, 1.0))),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.money,
                                color: Color.fromRGBO(9, 25, 87, 1.0)),
                            SizedBox(width: 8),
                            Text("Costo:",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(9, 25, 87, 1.0))),
                          ],
                        ),
                        Flexible(
                          child: Text(widget.costoCita,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                  color: Color.fromRGBO(9, 25, 87, 1.0))),
                        ),
                      ],
                    ),
                    if (!widget.remota) ...[
                      SizedBox(height: 10),
                      Divider(color: Colors.grey),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: Color.fromRGBO(9, 25, 87, 1.0)),
                              SizedBox(width: 8),
                              Text("Dirección:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(9, 25, 87, 1.0))),
                            ],
                          ),
                          Flexible(
                            child: Text(widget.direccion,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                    color: Color.fromRGBO(9, 25, 87, 1.0))),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Método de Pago",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(9, 25, 87, 1.0),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Botón de PayPal
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _pagarConPayPal,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: Color.fromRGBO(9, 25, 87, 1.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5,
                        ),
                        child: Image.network(
                          'https://mentalink.tepuy21.com/assets/images/logo-paypal-blanco.png',
                          height: 24,
                          width: 100,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Container(
                padding: EdgeInsets.all(18.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        /*onPressed: () {
                          _ModalPagoMovil(context);
                        },*/
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return ModalPagoMovil(
                                costoCita: widget.costoCita,
                                usuarioId: widget.usuarioId,
                                idPsicologo: widget.idPsicologo,
                                correo: widget.correo,
                                direccion: widget.direccion,
                                fechaSeleccionada: widget.fechaSeleccionada,
                                horaSeleccionada: widget.horaSeleccionada,
                                remota: widget.remota,
                                calendarApi: widget.calendarApi,
                                descripcion: widget.descripcion,
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          backgroundColor: Color.fromRGBO(255, 165, 0, 1.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          'Reportar Pago Móvil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 30),

            ],
          ),
        ),
      ),
    );
  }
}
