import 'package:flutter/material.dart';
import 'dart:io'; // Para NetworkInterface
import 'package:flutter/services.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_sign_in/google_sign_in.dart';

class ModalPagoMovil extends StatefulWidget {
  final String costoCita;
  final String usuarioId;
  final String? idPsicologo;
  final String? correo;
  final String direccion;
  final DateTime fechaSeleccionada;
  final TimeOfDay horaSeleccionada;
  final bool remota;
  final dynamic calendarApi;
  final String descripcion;

  ModalPagoMovil({
    required this.costoCita,
    required this.usuarioId,
    required this.idPsicologo,
    this.correo,
    required this.direccion,
    required this.fechaSeleccionada,
    required this.horaSeleccionada,
    required this.remota,
    this.calendarApi,
    required this.descripcion,
  });

  @override
  _ModalPagoMovilState createState() => _ModalPagoMovilState();
}

class _ModalPagoMovilState extends State<ModalPagoMovil> {

  final TextEditingController _conferenceLinkController =
      TextEditingController();

  final TextEditingController referenciaController = TextEditingController();
  final TextEditingController cedulaController = TextEditingController();
  final TextEditingController bancoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController fechaPagoController = TextEditingController();
  final TextEditingController montoController = TextEditingController();
  

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
        String errorMessage = '';
        if (rtnCode == -57) {
          errorMessage = 'La transacción no puede ser localizada. Revise los datos del pago móvil.';
        } else if (rtnCode == -56) {
          errorMessage = 'La transacción ya fue validada.';
        } else if (rtnCode == -99) {
          errorMessage = 'Error general.';
        } else {
          errorMessage = 'Código: $rtnCode, Mensaje: $message';
        }

        return {'status': 'error', 'message': errorMessage};
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

        }
      } catch (e) {
        return {'status': 'error', 'message': /*'Error al crear la cita: $e'*/ 'Por favor verifique su conexión e intente de nuevo.'};
      }

      return response;

    } catch (e) {
      return {
        'status': 'error',
        'message': 'Por favor verifique su conexión e intente de nuevo.'
        //'details': e.toString()
        //'details': 'Por favor verifique su conexión e intente de nuevo.',
      };
    }
  }

  bool cargando = false;
  double dolarPromedio = 0.0;
  bool errorDolar = false;

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

  @override
  void initState() {
    super.initState();
    obtenerDolar();
  }

  void obtenerDolar() async {
    try {
      var dolarData = await Servicio().obtenerDolarOficial();
      dolarPromedio = double.parse(dolarData['promedio'].toString());

      // Verifica que dolarPromedio sea mayor que 0
      if (dolarPromedio > 0) {
        double costoCita = double.parse(widget.costoCita);
        double montoEnBs = costoCita * dolarPromedio;

        setState(() {
          montoController.text = montoEnBs.toStringAsFixed(2);
          errorDolar = false;
        });
      } else {

        setState(() {
          montoController.text = 'El promedio del dólar no es válido.';
          errorDolar = true;
        });
        
      }
    } catch (e) {
      setState(() {
        errorDolar = true;
        montoController.text = 'No se pudo obtener el monto';
      });
    }
  }


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

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length != 6) {
                      return 'Referencia inválida (debe ser de 6 números)';
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Icon(Icons.arrow_drop_down),
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    // Mostrar el listado de bancos con códigos
                    String? selectedBanco = await showModalBottomSheet<String>(
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
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                /*TextFormField(
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
                        ),*/

                TextFormField(
                  controller: montoController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Monto',
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    suffixIcon: errorDolar
                        ? IconButton(
                            icon: Icon(Icons.refresh, color: Colors.red),
                            onPressed: () async {
                              obtenerDolar();
                            },
                          )
                        : null,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
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
                    'Ingresa la cantidad con decimáles, por ejemplo 0.00',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 2.0, left: 16.0),
                  child: Text(
                    'Los precios son manejados a tasa del BCV.',
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
                        setState(() {
                          cargando = true;
                        });

                        if (referenciaController.text.isEmpty ||
                            cedulaController.text.isEmpty ||
                            bancoController.text.isEmpty ||
                            telefonoController.text.isEmpty ||
                            fechaPagoController.text.isEmpty ||
                            montoController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text('Por favor, complete todos los campos.'),
                            backgroundColor: Colors.red,
                          ));

                          setState(() {
                            cargando = false;
                          });

                          return;
                        }

                        String referencia = referenciaController.text;
                        String cedula = cedulaController.text;
                        String banco = bancoController.text;
                        String telefono = telefonoController.text;
                        String fechaPago = fechaPagoController.text;
                        String monto = montoController.text;

                        // Formatear la cédula y la fecha
                        String formatoCedula = "V${cedula.replaceAll('-', '')}";

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
                          cedula: formatoCedula,
                          banco: banco,
                          telefono: telefono,
                          amount: monto,
                          startDate: formattedStartDate,
                          endDate: formattedEndDate,
                          ipAddress: ipAddress,
                        );

                        // Manejar la respuesta
                        /*if (response['status'] == 'success') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text('Cita agendada exitosamente')));
                                  Navigator.pushNamed(context, '/citas');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error al agendar la cita')));
                                }*/

                        /*if (response['status'] == 'success') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Cita agendada exitosamente')),
                                  );
                                  Navigator.pushNamed(context, '/citas');
                                } else {

                                  String errorMensaje = response['message'];

                                  if (response['details'] != null) {
                                    errorMensaje += '\nDetalles: ${response['details']}';
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(errorMensaje)),
                                  );
                                }*/

                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Cita agendada exitosamente')),
                          );
                          Navigator.pushNamed(context, '/citas');
                        } else {
                          String errorMensaje = response['message'];

                          // Si hay detalles, agregar al mensaje
                          if (response['details'] != null) {
                            errorMensaje +=
                                '\nDetalles: ${response['details']}';
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMensaje)),
                          );
                        }

                        // Desactivar el estado de carga
                        setState(() {
                          cargando = false;
                        });
                      },
                      child:
                          Text('Enviar', style: TextStyle(color: Colors.white)),
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
          floatingActionButton: cargando
              ? Container(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ),
    );
    

  }
}
