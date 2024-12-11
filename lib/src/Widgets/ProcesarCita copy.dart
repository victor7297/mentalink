import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:paypal_sdk/core.dart';

import 'package:paypal_sdk/catalog_products.dart';
import 'package:paypal_sdk/core.dart';
import 'package:paypal_sdk/orders.dart';
import 'package:paypal_sdk/payments.dart';
import 'package:paypal_sdk/subscriptions.dart';
import 'package:paypal_sdk/webhooks.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final calendar.CalendarApi? calendarApi; // Hacer calendarApi opcional


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
    this.calendarApi, // Cambiar aquí para ser opcional
    Key? key,
  }) : super(key: key);

  @override
  _ProcesarCitaState createState() => _ProcesarCitaState();
}

class _ProcesarCitaState extends State<ProcesarCita> {
  final TextEditingController _conferenceLinkController =
      TextEditingController();
  late GoogleSignIn _googleSignIn;

  String _clientId = 'AdyAw0Fl6dJSxf53dZCtpcRWcwoW-rdjtbZm94uDpyGnPjPD71dCDQJyVgQZkH5GAbS5owVRURBlS4wM';
  String _clientSecret = 'ECSo6h98xVSWnt4i-OAc2zEU2-8FcPmwkgEXOuqHH7k7qu5naRFOcItXQ1wGDn9lvFJgpKBF-Um_gOsM';

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn();
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
        // Solo usar calendarApi si es remota
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
          'id_evento': createdEvent.id ?? ''
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
        } else {
          await widget.calendarApi!.events.delete('primary', createdEvent.id!);
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                response['message'],
                textAlign: TextAlign.center,
              ),
            ),
          );
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
            'Error al crear la cita: $e',
            textAlign: TextAlign.center,
          ),
        ),
      );
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
            "description": "Cita de Psicología",
            "item_list": {
              "items": [
                {
                  "name": "Cita de Psicología",
                  "quantity": 1,
                  "price": '10.12',
                  "currency": "USD"
                }
              ],
            }
          }
        ],
        note: "Contact us for any questions on your order.",
        onSuccess: (Map params) async {
          // Captura los detalles de la transacción
          String idTransaccion = params['id'] ?? 'N/A';
          String total = params['purchase_units'][0]['amount']['value'] ?? 'N/A';
          String status = params['status'] ?? 'N/A';
          String fecha = params['update_time'] ?? 'N/A';

          // Muestra un mensaje de éxito con los detalles
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Pago exitoso! ID: $idTransaccion, Total: $total, Status: $status'),
              duration: Duration(minutes: 5),
            ),
          );

          // Agendar la cita
          await _agendarCita();

        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Error al procesar el pago: $error'),
            ),
          );

        },
        onCancel: (params) {
          print('cancelled: $params');
          Navigator.pop(context); 
        },
      ),
    ));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error: $e'),
      ),
    );
  }
}

  Future<void> _pagarConPayPal2() async {
  try {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => UsePaypal(
        sandboxMode: true,
        clientId: "AW1TdvpSGbIM5iP4HJNI5TyTmwpY9Gv9dYw8_8yW5lYIbCqf326vrkrp0ce9TAqjEGMHiV3OqJM_aRT0",
        secretKey: "EHHtTDjnmTZATYBPiGzZC_AZUfMpMAzj2VZUeqlFUrRJA_C0pQNCxDccB5qoRQSEdcOnnKQhycuOWdP9",
        returnURL: "https://mentalink.tepuy21.com",
        cancelURL: "https://mentalink.tepuy21.com",
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
            "description": "Cita de Psicología",
            "item_list": {
              "items": [
                {
                  "name": "Cita de Psicología",
                  "quantity": 1,
                  "price": '10.12',
                  "currency": "USD"
                }
              ],
            }
          }
        ],
        note: "Contact us for any questions on your order.",
        onSuccess: (Map params) async {
          // Captura los detalles de la transacción
          String idTransaccion = params['id'] ?? 'N/A';
          String total = params['purchase_units'][0]['amount']['value'] ?? 'N/A';
          String status = params['status'] ?? 'N/A';
          String fecha = params['update_time'] ?? 'N/A';

          // Muestra un mensaje de éxito con los detalles
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text('Pago exitoso! ID: $idTransaccion, Total: $total, Status: $status'),
              duration: Duration(minutes: 5),
            ),
          );


          // Aquí puedes enviar los datos a tu servidor
          //await _enviarDatosCompra(idTransaccion, total, status, fecha);

          // Agendar la cita
          await _agendarCita();

        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text('Error al procesar el pago: $error'),
            ),
          );

        },
        onCancel: (params) {
          print('cancelled: $params');
          Navigator.pop(context); 
        },
      ),
    ));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error: $e'),
      ),
    );
  }
}


Future<String> _obtenerTokenDeAcceso() async {
  final url = Uri.parse('https://api-m.sandbox.paypal.com/v1/oauth2/token');

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Basic ' + base64Encode(utf8.encode('$_clientId:$_clientSecret')),
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: 'grant_type=client_credentials', // Usar una cadena en lugar de un mapa
  );

  if (response.statusCode == 200) {
    final responseData = json.decode(response.body);
    return responseData['access_token'];
  } else {
    throw Exception('Error al obtener el token de acceso: ${response.statusCode}');
  }
}



  Future<void> _pagarConPayPal3() async {
    try {
      // Obtener el token de acceso
      final String accessToken = await _obtenerTokenDeAcceso();

      // Configura la URL y el cuerpo de la solicitud
      final url = Uri.parse('https://api-m.sandbox.paypal.com/v2/checkout/orders');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final body = json.encode({
        'intent': 'AUTHORIZE',
        'purchase_units': [
          {
            'reference_id': 'd9f80740-38f0-11e8-b467-0ed5f89f718b',
            'amount': {
              'currency_code': 'USD',
              'value': '10.12',
              'breakdown': {
                'item_total': {
                  'currency_code': 'USD',
                  'value': '10.12',
                },
              },
            },
            'items': [
              {
                'name': 'Cita de Psicología',
                'quantity': '1',
                'unit_amount': {
                  'currency_code': 'USD',
                  'value': '10.12',
                },
              },
            ],
          },
        ],
        'payment_source': {
          'paypal': {
            'experience_context': {
              'payment_method_preference': 'IMMEDIATE_PAYMENT_REQUIRED',
              'brand_name': 'EXAMPLE INC',
              'locale': 'es-VE',
              'landing_page': 'LOGIN',
              'shipping_preference': 'NO_SHIPPING',
              'user_action': 'PAY_NOW',
              'return_url': 'https://example.com/returnUrl',
              'cancel_url': 'https://example.com/cancelUrl',
            },
          },
        },
      });

      // Realiza la solicitud POST
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final approvalLink = responseData['links'].firstWhere((link) => link['rel'] == 'payer-action')['href'];

      print(approvalLink);


    await launch(approvalLink);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Redirigiendo para completar el pago...')),
  );
} else {
  throw Exception('Error al crear la orden: ${response.statusCode}');
}

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error: $e'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _pagarConPayPal2,
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
              'Pagar con PayPal 2',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _pagarConPayPal3,
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
              'Pagar con PayPal 3',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
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
    );
  }
}
