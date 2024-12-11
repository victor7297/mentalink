// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:mentalink/src/Widgets/ProcesarCita.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final void Function(TimeOfDay) onTimeSelected;
  final List<TimeOfDay> availableTimes;

  const CustomTimePicker({
    required this.initialTime,
    required this.onTimeSelected,
    required this.availableTimes,
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
    // Usa la primera hora disponible como la hora seleccionada inicial
    _selectedTime = widget.availableTimes.isNotEmpty ? widget.availableTimes[0] : widget.initialTime;
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
            child: CupertinoPicker(
              itemExtent: 40.0,
              onSelectedItemChanged: (int index) {
                setState(() {
                  _selectedTime = widget.availableTimes[index];
                });
              },
              children: widget.availableTimes.map((time) {
                final formattedTime = DateFormat.jm().format(
                  DateTime(2000, 1, 1, time.hour, time.minute),
                );
                return Center(child: Text(formattedTime));
              }).toList(),
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
  final String? tipo_cita;
  final String? presencial_direccion;
  final String? costo_presencial;
  final String? costo_remota;
  final String? costoInternacional;
  final String? pais;
  
  Calendario(this.psicologoId, this.correo, this.tipo_cita, this.presencial_direccion, this.costo_presencial, this.costo_remota, this.costoInternacional, this.pais, {Key? key}) : super(key: key);

  @override
  _CalendarioState createState() => _CalendarioState();
}

class _CalendarioState extends State<Calendario> {
  late final String? idPsicologo;
  late final String? correo;
  late final String? costo_presencial;
  late final String? costo_remota;
  late GoogleSignIn _googleSignIn;
  calendar.CalendarApi? _calendarApi;
  String _authenticationResult = '';
  String _calendarResponse = '';
  String conferenceLink = '';
  String id_evento = '';
  late String direccion;
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _conferenceLinkController = TextEditingController();
  
  bool eventoCreado = false; 
  bool horariosCargados = false;
  bool horariosVacios = false;
  bool horasDisponiblesCargadas = false;

  Map<String, List<int>> horariosDisponibles = {};
  Map<String, List<int>> horasDisponibles = {};

  Map<String, dynamic> usuarioData = {};

  @override
  void initState() {
    super.initState();
    idPsicologo = widget.psicologoId;
    correo = widget.correo;
    
    _googleSignIn = GoogleSignIn(scopes: [calendar.CalendarApi.calendarScope]);

    // Verifica si presencial_direccion es null o vacío
    direccion = (widget.presencial_direccion == null || widget.presencial_direccion!.isEmpty)
        ? 'Dirección Mentalink'
        : widget.presencial_direccion!;

    _conferenceLinkController.text = conferenceLink;

    _loadHorariosDisponibles();
  }

  Future<void> _loadHorariosDisponibles() async {
    try {
      // Obtén el mes y el año de la fecha seleccionada
      String formattedFecha = DateFormat('yyyy-MM').format(seleccionarFecha);

      final horario = await Servicio().horarioDisponible(int.parse(idPsicologo!), formattedFecha);

      // Convierte List<String> a List<int>
      Map<String, List<int>> horariosConvertidos = {};
      horario.forEach((key, value) {
        horariosConvertidos[key] = value.map((hora) => int.parse(hora)).toList();
      });

      setState(() {
        horariosDisponibles = horariosConvertidos;
        horariosCargados = true;
        horariosVacios = horariosDisponibles.isEmpty;
      });
    } catch (e) {
      print('Error al cargar horarios disponibles: $e');
      setState(() {
        horariosCargados = true;
        horariosVacios = true;
      });
    }
  }

    // Función para verificar si un día es seleccionable
  bool _diasDisponibles(DateTime date) {
    String fechaFormateadaCompleta = DateFormat('yyyy-MM-dd').format(date);
    return horariosDisponibles.containsKey(fechaFormateadaCompleta) && horariosDisponibles[fechaFormateadaCompleta]!.isNotEmpty;
  }

List<DateTime> _getEmptyDays() {
  List<DateTime> emptyDays = [];
  horariosDisponibles.forEach((date, hours) {
    if (hours.isEmpty) {
      emptyDays.add(DateTime.parse(date));
    }
  });
  return emptyDays;
}


  Future<void> _loadHorasDisponibles(DateTime date) async {
    String fecha = DateFormat('yyyy-MM-dd').format(date);
    try {
      final horas = await Servicio().horasDisponibles(int.parse(idPsicologo!), fecha);

      // Imprime las horas obtenidas para verificar
      print('Horas obtenidas: $horas');

      // Convierte List<String> a List<int>
      Map<String, List<int>> horasConvertidas = {};
      horas.forEach((key, value) {
        horasConvertidas[key] = value.map((hora) => int.parse(hora)).toList();
      });

      // Imprime las horas convertidas
      print('Horas convertidas: $horasConvertidas');

      setState(() {
        horasDisponibles = horasConvertidas;
        horasDisponiblesCargadas = true;
      });
    } catch (e) {
      print('Error al cargar horas disponibles: $e');
    }
  }

  ///////////////////////////////// Cita y Cita con Google /////////////////////////////////////////////////////////
  ///

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

    print(localDateTime);
    print(startDateTimeUtc);

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
  }*/

  

  @override

  Widget build(BuildContext context) {
    
  bool mostrarPresencial = widget.tipo_cita == 'presencial' || widget.tipo_cita == 'ambas';
  bool mostrarRemota = widget.tipo_cita == 'remota' || widget.tipo_cita == 'ambas';

  bool esInternacional = widget.pais == 'Venezuela';

  if (!esInternacional) {
    mostrarPresencial = false;
  }

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
          'Hora seleccionada: ${_formatoHora(hora)}',
        ),
      ),
      SizedBox(height: 20),
      Container(
        padding: EdgeInsets.only(left: 25),
        child: Row(
          children: [
            if (mostrarPresencial) ...[
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
            ],
            if (mostrarRemota) ...[
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
              hintText: 'Cuéntame qué te gustaría tratar en nuestra cita.',
              border: InputBorder.none,
            ),
            cursorColor: Color.fromARGB(255, 0, 188, 207),
          ),
        ),
      ),
      /*Center(
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
      ),*/
      Center(
        child: Container(
          margin: EdgeInsets.only(top: 15, bottom: 15),
          width: MediaQuery.of(context).size.width * 0.4,
          child: ElevatedButton(
            onPressed: () async {
              // Verificar que todos los campos estén completos
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
              String costoCita;

              if (presencial) {
                tipoCita = 'presencial';
                costoCita = widget.costo_presencial!;
              } else if (remota) {
                tipoCita = 'remota';
                //costoCita = widget.costo_remota!;
                costoCita = esInternacional ? widget.costo_remota! : widget.costoInternacional!;


                if (_calendarApi == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Por favor, seleccione nuevamente "Remota" para iniciar sesión con Google.',
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

              SharedPreferences prefs = await SharedPreferences.getInstance();
              String usuarioId = prefs.getString('usuario_id') ?? "";

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProcesarCita(
                    fechaSeleccionada: seleccionarFecha,
                    horaSeleccionada: hora,
                    presencial: presencial,
                    remota: remota,
                    descripcion: _descriptionController.text,
                    idPsicologo: idPsicologo,
                    usuarioId: usuarioId,
                    correo: correo,
                    direccion: direccion,
                    calendarApi: remota ? _calendarApi! : null,
                    costoCita: costoCita,
                  ),
                ),
              );
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


      /*Center(
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
                    //enabled: false, // Solo lectura
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
  if (!horariosCargados) {
    return Center(child: CircularProgressIndicator());
  }

  if (horariosVacios) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'El Psicólogo aún no define un horario.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }


  return SfDateRangePicker(
    monthViewSettings: DateRangePickerMonthViewSettings(
      blackoutDates: _getEmptyDays(), // Días vacíos
    ),
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
      return _diasDisponibles(date);
    },
    onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
      setState(() {
        seleccionarFecha = args.value;
        _loadHorariosDisponibles();
        _loadHorasDisponibles(seleccionarFecha);
      });
    },
    onSubmit: (_) {
      _showCustomTimePicker(context);
    },
  );
}

  String _formatoHora(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final formattedTime = DateFormat.jm().format(dateTime);
    return formattedTime;
  }

  void _showCustomTimePicker(BuildContext context) {
    String dayOfWeek = DateFormat('EEEE', 'es').format(seleccionarFecha).toLowerCase();
    List<TimeOfDay> availableTimes = [];

    if (horasDisponibles.containsKey(dayOfWeek)) {
      availableTimes = horasDisponibles[dayOfWeek]!.map((hora) {
        return TimeOfDay(hour: hora, minute: 0);
      }).toList();
      
      // Ordenar las horas
      availableTimes.sort((a, b) {
        if (a.hour != b.hour) {
          return a.hour.compareTo(b.hour);
        }
        return a.minute.compareTo(b.minute);
      });
    }

    // Imprime las horas disponibles
    print('Horas disponibles para el día seleccionado: $availableTimes');

    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return CustomTimePicker(
          initialTime: hora,
          availableTimes: availableTimes,
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