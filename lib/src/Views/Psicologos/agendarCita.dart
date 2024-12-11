// ignore_for_file: camel_case_types, prefer_const_constructors, sized_box_for_whitespace, avoid_unnecessary_containers, avoid_print, prefer_final_fields, unused_field

import 'package:flutter/material.dart';
import 'package:mentalink/src/Clases/appbar.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:mentalink/src/Widgets/drawer.dart';
import 'package:mentalink/src/Widgets/footer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class angendarCita extends StatefulWidget {
  const angendarCita({super.key});

  @override
  State<angendarCita> createState() => _angendarCitaState();
}

class _angendarCitaState extends State<angendarCita> {

  appbar appbarAux = appbar("","");
  Map<String, dynamic> usuarioData = {};


  bool deshabilitarFechas(DateTime date, List<DateTime> disabledDates) {
    // Verifica si la fecha está presente en la lista de fechas deshabilitadas
    return !disabledDates.contains(date);
  }

  List<DateTime> coloredDates = [
    //DateTime(2024, 3, 20), // Fecha 1
    //DateTime(2024, 3, 21), // Fecha 2
    //DateTime(2024, 3, 22), // Fecha 3
  ];


  final scaffkey = GlobalKey<ScaffoldState>();


  mostrarMensaje() {
    final snackBar = SnackBar(
      content: Text('¡Hola! Soy un SnackBar.'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  Future<void> obtenerDatosUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String usuarioId = prefs.getString('usuario_id') ?? "";
    String tipoUsuario = prefs.getString('tipo_usuario') ?? "";

    usuarioData = await Servicio().obtenerUsuario(int.parse(usuarioId));

    String? rutaImagenPerfil = prefs.getString('fotoPerfil');

    appbar appbarAux = appbar(usuarioId,rutaImagenPerfil!);
    setState(() {
      this.appbarAux = appbarAux;
    });
    
  }

  @override
  void initState() {
    super.initState();
    obtenerDatosUsuario();
  }


  @override
  Widget build(BuildContext context) {

    
    return Scaffold(

  
      appBar: appbarAux.getAppbar(context),

      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: 30, bottom: 50, left: 20, right: 20),
        
          child: Column(
        
            crossAxisAlignment: CrossAxisAlignment.center,
        
            children: [
              
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(50), // Radio de 50 para lograr la forma redonda
                  image: DecorationImage(image: NetworkImage('https://mentalink.org/assets/images/ImagenPerfil.png'),fit: BoxFit.cover),
                ),
              ),
        
              Container( width: double.infinity, child: Center(child: Text("Dr. Victor Caceres", style: TextStyle(fontWeight: FontWeight.bold),)),),
        
              Container( width: double.infinity, child: Center(child: Text("Psicólogo", style: TextStyle(fontWeight: FontWeight.w200),)),),
        
              Container(
        
                margin: EdgeInsets.only(top: 40),
        
                
                child: Card(
        
                  color: Color.fromRGBO(0, 189, 206, 1),
        
                  child: Padding(
                    padding: EdgeInsets.all(15),
        
                    child: Row(
                    
                      children: [
                    
                        Container( margin: EdgeInsets.only(right: 5), child: Icon(Icons.calendar_month, size: 35,)),
                        Container( child: Text("Agenda tu cita"),),
              
                      ],
                    ),
                  ),
                ),
              ),
        
              Container(
                
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.all(8),

                child: SfDateRangePicker(
                  
                  
                  //backgroundColor: Colors.amber,
                  todayHighlightColor: Color.fromRGBO(0, 189, 206, 1),
                  selectionColor: Color.fromRGBO(0, 189, 206, 1),
                  startRangeSelectionColor: Color.fromRGBO(0, 189, 206, 1),
                  selectionTextStyle: TextStyle(color: Colors.black),
                
                  //cellBuilder: _buildCell,
                  

                  headerStyle: DateRangePickerHeaderStyle(
                    backgroundColor: Color.fromRGBO(0, 189, 206, 1), // Color de fondo del header
                    textStyle: TextStyle(color: Colors.black),
                  ),

                  showActionButtons: true,
                  enablePastDates: false,
                  selectionShape: DateRangePickerSelectionShape.circle,

                  selectableDayPredicate: (DateTime date) {
                    
                    return deshabilitarFechas(date, coloredDates) && date.weekday != DateTime.saturday && date.weekday != DateTime.sunday;
                  },

                  onSelectionChanged:(DateRangePickerSelectionChangedArgs args) {

                    DateTime _selectedDate = args.value;

                    int day = _selectedDate.day;
                    int month = _selectedDate.month;
                    int year = _selectedDate.year;

                    //print('Día seleccionado: $day');
                    //print('Mes seleccionado: $month');
                    ///print('Año seleccionado: $year');
                  },
                  
                  onSubmit: (fecha){
                    //print(fecha);
                    //Intl.defaultLocale = 'es';

                    if(fecha != null){

                      showTimePicker(

                        context: context,
                        initialTime: TimeOfDay.now(),
                        
                        
                        builder: (BuildContext context, Widget? child) {
                          return MediaQuery(
                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                            child: child!,
                          );
                        },
                        
                      )
                      .then((selectedTime) {

                        if (selectedTime != null) {
                          //print(selectedTime.format(context));
                          mostrarMensaje();
                        }

                      });

                      //_selectTime(context);

                    }
                  },

                  
                ),
              ),
        
            ],
          ),
        ),
      ),

      drawer: NowDrawer(currentPage: 'agendarCita',),
      bottomNavigationBar: Footer(),

    );


    
  }


}











