import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn();
    obtenerDolar();


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

  void obtenerDolar() async {
    try {
      dolarData = await Servicio().obtenerDolarOficial();
      print(dolarData['promedio']);
      setState(() {});
    } catch (e) {
      _errorMessage = e.toString();
      setState(() {});
    }
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

  Future<Map<String, dynamic>> _agendarCitaPagoMovil({
    String? referencia,
    String? cedula,
    String? banco,
    String? telefono,
    required String amount,
    required String startDate,
    required String endDate,
    required String ipAddress,
  }) async {
    String usuarioId = widget.usuarioId;
    String idPsicologo = widget.idPsicologo ?? "";
    String? correo = widget.correo;
    String direccion = widget.direccion;

    try {
      // Validar pago antes de proceder
      Map<String, dynamic> validacionPago = await Servicio().validarPago(
        referencia: referencia ?? '',
        cedula: cedula ?? '',
        banco: banco ?? '',
        telefono: telefono ?? '',
        amount: amount,
        startDate: startDate,
        endDate: endDate,
        ipAddress: ipAddress,
      );

      int rtnCode = validacionPago['rtnCode'];
      String message = validacionPago['message'];

      if (rtnCode != 0) {
        if (rtnCode == -57) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'La transacción no puede ser localizada. Revise los datos del pago móvil.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Código: $rtnCode, Mensaje: $message')),
          );
        }
        return {'status': 'error', 'message': message};
      }

      String referenciaPago =
          validacionPago['result']['validatedPayments'][0]['reference'];

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
          // Si es una cita remota, crear el evento en Google Calendar
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
                "conferenceSolutionKey": {"type": "hangoutsMeet"},
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
            'pago': referenciaPago,
          };

          response = await Servicio().angendarCita(data);

          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cita agendada exitosamente')),
            );
            Navigator.pushNamed(context, '/citas');
          } else {
            await widget.calendarApi!.events
                .delete('primary', createdEvent.id!);
          }
        } else {
          // Si es una cita presencial
          Map<String, dynamic> data = {
            'psicologo_id': idPsicologo,
            'paciente_id': usuarioId,
            'fecha_hora': localDateTime.toIso8601String(),
            'descripcion': widget.descripcion,
            'tipo_cita': 'presencial',
            'direccion': direccion,
            'costo': widget.costoCita,
            'pago': referenciaPago,
          };

          response = await Servicio().angendarCita(data);

          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cita agendada exitosamente')),
            );
            Navigator.pushNamed(context, '/citas');
          }
        }
      } catch (e) {
        return {'status': 'error', 'message': 'Error al crear la cita: $e'};
      }

      return response;
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error al validar el pago',
        'details': e.toString()
      };
    }
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

  bool _isLoading = false;

/*void _ModalPagoMovil(BuildContext context) {
  final TextEditingController referenciaController = TextEditingController();
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController bancoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController fechaPagoController = TextEditingController();
  final TextEditingController montoController = TextEditingController();

  Map<String, String> bancos = {
    "0102": "Banco de Venezuela, S.A. Banco Universal",
    "0156": "100% Banco, Banco Comercial, C.A",
    "0172": "Bancamiga Banco Universal, C.A.",
    "0114": "Banco del Caribe C.A., Banco Universal",
    "0171": "Banco Activo C.A., Banco Universal",
    "0166": "Banco Agrícola de Venezuela C.A., Banco Universal",
    "0175": "Banco Bicentenario del Pueblo, Banco Universal C.A.",
    "0128": "Banco Caroní C.A., Banco Universal",
    "0163": "Banco del Tesoro C.A., Banco Universal",
    "0115": "Banco Exterior C.A., Banco Universal",
    "0151": "Banco Fondo Común, C.A Banco Universal",
    "0173": "Banco Internacional de Desarrollo C.A., Banco Universal",
    "0105": "Banco Mercantil C.A., Banco Universal",
    "0191": "Banco Nacional de Crédito C.A., Banco Universal",
    "0138": "Banco Plaza, Banco universal",
    "0137": "Banco Sofitasa Banco Universal, C.A.",
    "0104": "Banco Venezolano de Crédito, S.A. Banco Universal",
    "0168": "Bancrecer S.A., Banco Microfinanciero",
    "0134": "Banesco Banco Universal, C.A.",
    "0177": "Banco de la Fuerza Armada Nacional Bolivariana, B.U.",
    "0146": "Banco de la Gente Emprendedora C.A.",
    "0174": "Banplus Banco Universal, C.A.",
    "0108": "Banco Provincial, S.A. Banco Universal",
    "0157": "DelSur, Banco Universal C.A.",
    "0169": "Mi Banco, Banco Microfinanciero, C.A.",
    "0178": "N58 Banco Digital, Banco Microfinanciero",
  };

  Future<String> _getIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(includeLoopback: false);
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      print("Error obteniendo IP: $e");
    }
    return '0.0.0.0';
  }

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Column(
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
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Información de Pago',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Teléfono:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('0414-22568'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Banco:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Banesco'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Documento:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('J-4501545454'),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: 'Teléfono: 0414-22568\nBanco: Banesco\nDocumento: J-4501545454'));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Datos copiados al portapapeles')));
                    },
                    child: Text('Copiar Datos', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(0, 189, 206, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(color: Colors.white),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: cedulaController,
                    decoration: InputDecoration(
                      labelText: 'Cédula',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                  ),
                  Divider(thickness: 1, color: Colors.grey.shade300),
                  TextFormField(
                    controller: referenciaController,
                    decoration: InputDecoration(
                      labelText: 'Referencia',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                  ),
                  Divider(thickness: 1, color: Colors.grey.shade300),
                  TextFormField(
                    controller: bancoController,
                    decoration: InputDecoration(
                      labelText: 'Banco',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                    readOnly: true,
                    onTap: () async {
                      String? selectedBanco = await showModalBottomSheet<String>(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        builder: (context) {
                          return ListView(
                            children: bancos.entries.map((entry) {
                              return ListTile(
                                title: Text('${entry.key} - ${entry.value}', style: TextStyle(fontSize: 14)),
                                onTap: () {
                                  Navigator.pop(context, entry.key);
                                },
                              );
                            }).toList(),
                          );
                        },
                      );

                      if (selectedBanco != null) {
                        bancoController.text = '$selectedBanco - ${bancos[selectedBanco]}';
                      }
                    },
                  ),
                  Divider(thickness: 1, color: Colors.grey.shade300),
                  TextFormField(
                    controller: telefonoController,
                    decoration: InputDecoration(
                      labelText: 'Teléfono',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                  ),
                  Divider(thickness: 1, color: Colors.grey.shade300),
                  TextFormField(
                    controller: fechaPagoController,
                    decoration: InputDecoration(
                      labelText: 'Fecha de Pago (DD-MM-YYYY)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                  ),
                  Divider(thickness: 1, color: Colors.grey.shade300),
                  TextFormField(
                    controller: montoController,
                    decoration: InputDecoration(
                      labelText: 'Monto',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  Divider(thickness: 1, color: Colors.grey.shade300),
                  SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: 250,
                      child: ElevatedButton(
                        onPressed: () async {

                          if (referenciaController.text.isEmpty ||
                              cedulaController.text.isEmpty ||
                              bancoController.text.isEmpty ||
                              telefonoController.text.isEmpty ||
                              fechaPagoController.text.isEmpty ||
                              montoController.text.isEmpty) {

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Por favor, complete todos los campos.'),
                              backgroundColor: Colors.red,
                            ));
                            return;
                          }

                          setState(() {
                            _isLoading = true;
                          });

                          Navigator.pop(context);

                          String referencia = referenciaController.text;
                          String cedula = cedulaController.text;
                          String banco = bancoController.text.split(' - ')[0];
                          String telefono = telefonoController.text;
                          String fechaPago = fechaPagoController.text;
                          double monto = double.tryParse(montoController.text) ?? 0.0;

                          // Formatear la cédula y la fecha
                          String formattedCedula = "V${cedula.replaceAll('-', '')}";
                          DateTime startDate = DateTime.parse(fechaPago.split('-').reversed.join('-'));
                          DateTime endDate = startDate.add(Duration(days: 7));

                          String formattedStartDate = startDate.toIso8601String().substring(0, 10).replaceAll('-', '');
                          String formattedEndDate = endDate.toIso8601String().substring(0, 10).replaceAll('-', '');

                          print("startDate: $formattedStartDate");
                          print("endDate: $formattedEndDate");

                          String ipAddress = await _getIpAddress();

                          Map<String, dynamic> response = await _agendarCitaPagoMovil(
                            referencia: referencia,
                            cedula: formattedCedula,
                            banco: banco,
                            telefono: telefono,
                            amount: monto,
                            startDate: formattedStartDate,
                            endDate: formattedEndDate,
                            ipAddress: ipAddress,
                          );

                          setState(() {
                            _isLoading = false;
                          });

                          // Manejar la respuesta
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cita agendada exitosamente')));
                            Navigator.pushNamed(context, '/citas');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al agendar la cita: ${response['message']}')));
                          }
                        },
                        child: Text('Enviar', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(0, 189, 206, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: BorderSide(color: Colors.white),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}*/

  void _ModalPagoMovil(BuildContext context) {
    final TextEditingController referenciaController = TextEditingController();
    final TextEditingController cedulaController = TextEditingController();
    final TextEditingController bancoController = TextEditingController();
    final TextEditingController telefonoController = TextEditingController();
    final TextEditingController fechaPagoController = TextEditingController();
    final TextEditingController montoController = TextEditingController();

    Map<String, String> bancos = {
      "0102": "Banco de Venezuela, S.A. Banco Universal",
      "0156": "100% Banco, Banco Comercial, C.A",
      "0172": "Bancamiga Banco Universal, C.A.",
      "0114": "Banco del Caribe C.A., Banco Universal",
      "0171": "Banco Activo C.A., Banco Universal",
      "0166": "Banco Agrícola de Venezuela C.A., Banco Universal",
      "0175": "Banco Bicentenario del Pueblo, Banco Universal C.A.",
      "0128": "Banco Caroní C.A., Banco Universal",
      "0163": "Banco del Tesoro C.A., Banco Universal",
      "0115": "Banco Exterior C.A., Banco Universal",
      "0151": "Banco Fondo Común, C.A Banco Universal",
      "0173": "Banco Internacional de Desarrollo C.A., Banco Universal",
      "0105": "Banco Mercantil C.A., Banco Universal",
      "0191": "Banco Nacional de Crédito C.A., Banco Universal",
      "0138": "Banco Plaza, Banco universal",
      "0137": "Banco Sofitasa Banco Universal, C.A.",
      "0104": "Banco Venezolano de Crédito, S.A. Banco Universal",
      "0168": "Bancrecer S.A., Banco Microfinanciero",
      "0134": "Banesco Banco Universal, C.A.",
      "0177": "Banco de la Fuerza Armada Nacional Bolivariana, B.U.",
      "0146": "Banco de la Gente Emprendedora C.A.",
      "0174": "Banplus Banco Universal, C.A.",
      "0108": "Banco Provincial, S.A. Banco Universal",
      "0157": "DelSur, Banco Universal C.A.",
      "0169": "Mi Banco, Banco Microfinanciero, C.A.",
      "0178": "N58 Banco Digital, Banco Microfinanciero",
    };

    Future<String> _getIpAddress() async {
      try {
        final interfaces = await NetworkInterface.list(includeLoopback: false);
        for (var interface in interfaces) {
          for (var addr in interface.addresses) {
            if (addr.type == InternetAddressType.IPv4) {
              return addr.address;
            }
          }
        }
      } catch (e) {
        print("Error obteniendo IP: $e");
      }
      return '0.0.0.0';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          child: Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 5),
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(127, 127, 136, 0.988),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Información de Pago',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Teléfono:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('0424-2179421'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Banco:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Banesco'),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Documento:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('J-505271920'),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                            text:
                                'Teléfono: 0424-2179421\nBanco: Banesco\nDocumento: J-505271920'));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Datos copiados al portapapeles')));
                      },
                      child: Text('Copiar Datos',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(0, 189, 206, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: BorderSide(color: Colors.white),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 24.0),
                        textStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Teléfono
                    TextFormField(
                      controller: telefonoController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.length != 10 ||
                            !RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Número de teléfono inválido';
                        }
                        return null;
                      },
                    ),
                    Divider(thickness: 1, color: Colors.grey.shade300),

                    // Cédula
                    TextFormField(
                      controller: cedulaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Cédula',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Cédula inválida';
                        }
                        return null;
                      },
                    ),
                    Divider(thickness: 1, color: Colors.grey.shade300),

                    // Referencia
                    TextFormField(
                      controller: referenciaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Referencia',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            !RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return 'Referencia inválida';
                        }
                        return null;
                      },
                    ),

                    Divider(thickness: 1, color: Colors.grey.shade300),

                    Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Ingresa solo los últimos 6 digitos.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // Banco
                    TextFormField(
                      controller: bancoController,
                      decoration: InputDecoration(
                        labelText: 'Banco',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Icon(Icons.arrow_drop_down),
                        ),
                      ),
                      readOnly: true,
                      onTap: () async {
                        // Mostrar el listado de bancos con códigos
                        String? selectedBanco =
                            await showModalBottomSheet<String>(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          builder: (context) {
                            return ListView(
                              children: bancos.entries.map((entry) {
                                return ListTile(
                                  title: Text('${entry.key} - ${entry.value}',
                                      style: TextStyle(fontSize: 14)),
                                  onTap: () {
                                    Navigator.pop(context, entry.key);
                                  },
                                );
                              }).toList(),
                            );
                          },
                        );
                        if (selectedBanco != null) {
                          bancoController.text = selectedBanco;
                        }
                      },
                    ),
                    Divider(thickness: 1, color: Colors.grey.shade300),

                    // Fecha de pago
                    TextFormField(
                      controller: fechaPagoController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        labelText: 'Fecha de Pago',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                      ),
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          String formattedDate =
                              "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                          fechaPagoController.text = formattedDate;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Fecha de pago requerida';
                        }
                        return null;
                      },
                    ),
                    Divider(thickness: 1, color: Colors.grey.shade300),

                    // Monto
                    TextFormField(
                      controller: montoController,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Monto',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Monto es requerido';
                        }
                        return null;
                      },
                    ),
                    Divider(thickness: 1, color: Colors.grey.shade300),

                    Padding(
                      padding: EdgeInsets.only(left: 16.0),
                      child: Text(
                        'Ingresa la cantidad con decimáles, por ejemplo 0.00.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    // Botón de envío
                    SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: 250,
                        child: ElevatedButton(
                          onPressed: () async {
                            // Validar campos antes de enviar
                            if (referenciaController.text.isEmpty ||
                                cedulaController.text.isEmpty ||
                                bancoController.text.isEmpty ||
                                telefonoController.text.isEmpty ||
                                fechaPagoController.text.isEmpty ||
                                montoController.text.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    'Por favor, complete todos los campos.'),
                                backgroundColor: Colors.red,
                              ));
                              return;
                            }

                            String referencia = referenciaController.text;
                            String cedula = cedulaController.text;
                            String banco = bancoController.text;
                            String telefono = telefonoController.text;
                            String fechaPago = fechaPagoController.text;
                            String monto = montoController.text;

                            // Formatear la cédula y la fecha
                            String formattedCedula =
                                "V${cedula.replaceAll('-', '')}";

                            // Fecha de inicio (fecha de pago)
                            DateTime startDate = DateTime.parse(
                                fechaPago.split('-').reversed.join('-'));

                            // Fecha de fin (7 días después de la fecha de inicio)
                            DateTime endDate = startDate.add(Duration(days: 7));

                            // Formateo de las fechas en el formato correcto (yyyy-MM-dd)
                            String formattedStartDate =
                                "${startDate.year.toString().padLeft(4, '0')}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}";
                            String formattedEndDate =
                                "${endDate.year.toString().padLeft(4, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}";

                            String ipAddress = await _getIpAddress();

                            Map<String, dynamic> response =
                                await _agendarCitaPagoMovil(
                              referencia: referencia,
                              cedula: formattedCedula,
                              banco: banco,
                              telefono: telefono,
                              amount: monto,
                              startDate: formattedStartDate,
                              endDate: formattedEndDate,
                              ipAddress: ipAddress,
                            );

                            // Manejar la respuesta
                            if (response['status'] == 'success') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Cita agendada exitosamente')));
                              Navigator.pushNamed(context, '/citas');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Error al agendar la cita')));
                            }
                          },
                          child: Text('Enviar',
                              style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(0, 189, 206, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: BorderSide(color: Colors.white),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 24.0),
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
                  //color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  /*boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],*/
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

                    /*Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                
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
                          'Veep',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),*/
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
                        onPressed: () {
                          _ModalPagoMovil(context);
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

              /*ElevatedButton(
                onPressed: _agendarCita,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  backgroundColor: Color.fromRGBO(9, 25, 87, 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
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
              ),*/
            ],
          ),
        ),
      ),
      floatingActionButton: _isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              ),
            )
          : SizedBox.shrink(),
    );
  }
}
