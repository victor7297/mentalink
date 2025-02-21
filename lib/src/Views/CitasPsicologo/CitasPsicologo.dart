import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:mentalink/src/Widgets/footer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mentalink/src/Clases/appbar.dart';
import 'package:mentalink/src/Widgets/drawer.dart';
import 'package:mentalink/src/Servicios/servicio.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class CitasPsicologos extends StatefulWidget {
  const CitasPsicologos({Key? key}) : super(key: key);

  @override
  _CitasPsicologosState createState() => _CitasPsicologosState();
}

class _CitasPsicologosState extends State<CitasPsicologos> {
  Map<String, dynamic> usuarioData = {};
  String? idPsicologo;
  List<dynamic> citas = [];
  bool cargando = true;
  String tipoUsuario = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  appbar appbarAux = appbar("", "");

  late GoogleSignIn _googleSignIn;
  calendar.CalendarApi? _calendarApi;
  String _authenticationResult = '';

  bool horariosCargados = false;
  bool horariosVacios = false;
  bool horasDisponiblesCargadas = false;

  Map<String, List<int>> horariosDisponibles = {};
  Map<String, List<int>> horasDisponibles = {};

  DateTime seleccionarFecha = DateTime.now();
  TimeOfDay hora = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    cargarDatos();

    _googleSignIn = GoogleSignIn(scopes: [calendar.CalendarApi.calendarScope]);
  }

  Future<void> cargarDatos() async {
    await obtenerDatosUsuario();
    await _obtenerCitas();
  }

  Future<void> obtenerDatosUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String usuarioId = prefs.getString('usuario_id') ?? "";
    String? tipoUsuario = prefs.getString('tipo_usuario');
    String? rutaImagenPerfil = prefs.getString('fotoPerfil');

    appbar appbarAux = appbar(usuarioId, rutaImagenPerfil!);
    setState(() {
      this.tipoUsuario = tipoUsuario!;
    });
  }

  Future<void> _obtenerCitas() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String usuarioId = prefs.getString('usuario_id') ?? "";
    final response = await Servicio().CitasPsicologo(int.parse(usuarioId));

    setState(() {
      citas = response;
      cargando = false;

      if (citas.isNotEmpty) {
        idPsicologo = citas[0]['psicologo_id'].toString();
      }
    });
  }

  List<dynamic> _filtrarCitasPorEstado(String estado) {
    return citas.where((cita) {
      String citaEstado = cita['status'] ?? '';
      if (estado == 'programadas' && (citaEstado.isEmpty || citaEstado == 'programada')) return true;
      if (estado == 'canceladas' && citaEstado == 'cancelada') return true;
      return false;
    }).toList();
  }

  String capitalize(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  Future<void> _loadHorariosDisponibles() async {
    try {
      String formattedFecha = DateFormat('yyyy-MM').format(seleccionarFecha);
      final horario = await Servicio().horarioDisponible(int.parse(idPsicologo!), formattedFecha);

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

      Map<String, List<int>> horasConvertidas = {};
      horas.forEach((key, value) {
        horasConvertidas[key] = value.map((hora) => int.parse(hora)).toList();
      });

      setState(() {
        horasDisponibles = horasConvertidas;
        horasDisponiblesCargadas = true;
      });
    } catch (e) {
      print('Error al cargar horas disponibles: $e');
    }
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
  
Future<void> reprogramarCita(String citaId, String? eventoId, DateTime nuevaFechaHora, String tipoCita) async {
  try {

    // Actualizar la cita en el backend
    final response = await Servicio().actualizarCita(citaId, nuevaFechaHora);

    if (response['status'] == 'success') {
      // Manejar citas remotas
      if (tipoCita == 'remota') {
        if (eventoId == null) {
          print('Error: eventoId es null para una cita remota');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: evento ID es nulo para cita remota')),
          );
          return;
        }

        DateTime startDateTime = nuevaFechaHora;
        DateTime endDateTime = nuevaFechaHora.add(Duration(hours: 1));

        var eventPatchData = calendar.Event.fromJson({
          'start': {'dateTime': startDateTime.toIso8601String(), 'timeZone': 'UTC'},
          'end': {'dateTime': endDateTime.toIso8601String(), 'timeZone': 'UTC'},
        });

        try {
          
          await _calendarApi!.events.patch(eventPatchData, 'primary', eventoId);
        } catch (e) {
          print('Error al actualizar el evento en el calendario: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar el evento en el calendario')),
          );
        }
      } 

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cita reprogramada con éxito')),
      );

      _obtenerCitas();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${response['message']}')),
      );
    }
  } catch (e) {
    print('Error al reprogramar la cita: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al reprogramar la cita')),
    );
  }
}

Future<void> cancelarCita(String citaId, String? eventoId, String causaCancelacion, String tipoCita) async {

    try {

      final response = await Servicio().cancelarCita(citaId, causaCancelacion);

      if (response['status'] == 'success') {

        // Eliminar el evento del calendario de Google
        await _calendarApi!.events.delete('primary', eventoId!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cita cancelada con éxito'),
          ),
        );

        _obtenerCitas();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response['message']}'),
          ),
        );
      }
    } catch (e) {
      print('Error al cancelar el evento en Google Calendar: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cancelar la cita'),
        ),
      );
    }
  }

Future<String?> _showCancelacionDialog(BuildContext context) async {
  TextEditingController _controller = TextEditingController();

  return await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingrese la causa de cancelación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _controller,
                maxLines: 4,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Escriba aquí...',
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(null);
                    },
                    child: Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(_controller.text);
                    },
                    child: Text('Aceptar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _showReprogramarModal(String citaId, String? eventoId, String tipoCita) async {
  await _loadHorariosDisponibles();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Container(
          width: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDatePicker(citaId, eventoId, tipoCita),
            ],
          ),
        ),
      );
    },
  );
}


Widget _buildDatePicker(String citaId, String? eventoId, String tipoCita) {
  return SfDateRangePicker(
    backgroundColor: Colors.transparent,
    monthViewSettings: DateRangePickerMonthViewSettings(
      blackoutDates: _getEmptyDays(),
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
      _showCustomTimePicker(context, citaId, eventoId, tipoCita);
    },
    onCancel: () {
      Navigator.of(context).pop();
    },
  );
}

void _showCustomTimePicker(BuildContext context, String citaId, String? eventoId, String tipoCita) {
  String dayOfWeek = DateFormat('EEEE', 'es').format(seleccionarFecha).toLowerCase();
  List<TimeOfDay> availableTimes = [];

  if (horasDisponibles.containsKey(dayOfWeek)) {
    availableTimes = horasDisponibles[dayOfWeek]!.map((hora) {
      return TimeOfDay(hour: hora, minute: 0);
    }).toList();

    availableTimes.sort((a, b) {
      if (a.hour != b.hour) {
        return a.hour.compareTo(b.hour);
      }
      return a.minute.compareTo(b.minute);
    });
  }

  print('Horas disponibles para el día seleccionado: $availableTimes');

  showModalBottomSheet(
    context: context,
    builder: (BuildContext builder) {
      return CustomTimePicker(
        initialTime: hora, // Usa la variable 'hora' que se mantiene
        availableTimes: availableTimes,
        onTimeSelected: (TimeOfDay selectedTime) {
          setState(() {
            hora = selectedTime; // Actualiza 'hora' con la selección
            print('Hora seleccionada: $hora'); // Imprimir la hora seleccionada
          });

          DateTime nuevaFechaHora = DateTime(
            seleccionarFecha.year,
            seleccionarFecha.month,
            seleccionarFecha.day,
            hora.hour,
            hora.minute,
          );

          print('Nueva fecha y hora a enviar: $nuevaFechaHora');

          // Llama a la función de reprogramarCita
          reprogramarCita(citaId, eventoId, nuevaFechaHora, tipoCita).then((_) {
            Navigator.of(context).pop(); // Cerrar el modal de tiempo
            Navigator.of(context).pop(); // Cerrar el modal de fecha
          });
        },
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: appbarAux.getAppbar(context),
        drawer: NowDrawer(currentPage: 'Citas'),
        body: cargando
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildIcon(Icons.check_circle, 'Programadas', context),
                        _buildIcon(Icons.cancel, 'Canceladas', context),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      children: [
                        _buildSection('programadas', context),
                        _buildSection('canceladas', context),
                      ],
                    ),
                  ),
                ],
              ),
              bottomNavigationBar: Footer(),
      ),
    );
  }

  Widget _buildIcon(IconData icon, String label, BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: Color.fromARGB(255, 0, 188, 207),
          size: 32,
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Color.fromRGBO(9, 25, 87, 1.0),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String status, BuildContext context) {
    List<dynamic> citasFiltradasPorEstado = _filtrarCitasPorEstado(status);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: ListView.builder(
        itemCount: citasFiltradasPorEstado.length,
        itemBuilder: (context, index) {
          final cita = citasFiltradasPorEstado[index];
          DateTime fechaHora = DateTime.parse(cita['fecha_hora']);
          String fechaFormateada = DateFormat('dd/MM/yyyy').format(fechaHora);
          String horaFormateada = DateFormat('h:mm a').format(fechaHora);

          return Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cita Psicológica ' + capitalize(cita['tipo_cita']),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(9, 25, 87, 1.0),
                      ),
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.grey),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Descripción: ' + capitalize(cita['descripcion']),
                            style: TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey),
                        SizedBox(width: 5),
                        Text(
                          'Fecha: ' + fechaFormateada,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Icon(Icons.access_time, color: Colors.grey),
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Hora: ' + horaFormateada,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    if (tipoUsuario == '5') ...[
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.grey),
                          SizedBox(width: 5),
                          Text(
                            'Psicólogo: ' +
                                capitalize(cita['psicologo_nombre']) +
                                ' ' +
                                capitalize(cita['psicologo_apellido']),
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(Icons.mail, color: Colors.grey),
                          SizedBox(width: 5),
                          Text(
                            'Correo: ' + cita['psicologo_correo'],
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ] else if (tipoUsuario == '2') ...[
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.grey),
                          SizedBox(width: 5),
                          Text(
                            'Paciente: ' +
                                capitalize(cita['paciente_nombre']) +
                                ' ' +
                                capitalize(cita['paciente_apellido']),
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Icon(Icons.mail, color: Colors.grey),
                          SizedBox(width: 5),
                          Text(
                            'Correo: ' + cita['paciente_correo'],
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 15),
                    if (cita['tipo_cita'] == 'presencial') ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_city, color: Colors.grey),
                          SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              'Dirección: ${cita['direccion'] ?? 'No especificada'}',
                              style: TextStyle(fontSize: 16, color: Colors.black),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (cita['tipo_cita'] == 'remota') ...[
                      Row(
                        children: [
                          Icon(Icons.add_link, color: Colors.grey),
                          SizedBox(width: 5),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Enlace: \n' + cita['link'],
                                    style: TextStyle(fontSize: 14, color: Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.copy),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: cita['link']));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Enlace copiado al portapapeles'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {

                            if (cita['tipo_cita'] == 'remota') {
                              await _initGoogleSignIn(); // Solo se ejecuta si la cita es remota

                              idPsicologo = cita['psicologo_id'].toString();

                              String? eventoId = cita['id_evento'];
                              _showReprogramarModal(cita['id_cita'], eventoId, cita['tipo_cita']);

                            } else {

                              idPsicologo = cita['psicologo_id'].toString();

                              String? eventoId = cita['id_evento']; 
                              _showReprogramarModal(cita['id_cita'], eventoId, cita['tipo_cita']);
                            }

                          },
                          child: Text('Reprogramar'),
                        ),

                        ElevatedButton(
                          onPressed: () async {

                            await _initGoogleSignIn();

                            String? causaCancelacion = await _showCancelacionDialog(context);

                            if (causaCancelacion != null && causaCancelacion.isNotEmpty) {

                              await cancelarCita(cita['id_cita'], cita['id_evento'], cita['tipo_cita'], causaCancelacion);

                              
                            } else {

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Debe ingresar una causa de cancelación.')),
                              );
                            }
                          },
                          child: Text('Cancelar'),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CustomTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final List<TimeOfDay> availableTimes;
  final void Function(TimeOfDay) onTimeSelected;

  const CustomTimePicker({
    required this.initialTime,
    required this.availableTimes,
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
                itemExtent: 40,
                onSelectedItemChanged: (int index) {
                  if (index < widget.availableTimes.length) {
                    setState(() {
                      _selectedTime = widget.availableTimes[index];
                    });
                  }
                },
                children: widget.availableTimes.map((time) {
                  return Center(
                    child: Text(
                      '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(fontSize: 20),
                    ),
                  );
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