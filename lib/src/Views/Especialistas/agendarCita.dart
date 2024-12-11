// ignore_for_file: camel_case_types, prefer_const_constructors, sized_box_for_whitespace, avoid_unnecessary_containers, annotate_overrides, unused_local_variable

import 'package:flutter/material.dart';
import 'package:mentalink/src/Clases/appbar.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:mentalink/src/Widgets/drawer.dart';
import 'package:mentalink/src/Widgets/footer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class angendarCita extends StatefulWidget {
  const angendarCita({super.key});

  @override
  State<angendarCita> createState() => _angendarCitaState();
}

class _angendarCitaState extends State<angendarCita> {

  List<DateTime> coloredDates = [
    DateTime(2024, 3, 20), // Fecha 1
    DateTime(2024, 3, 21), // Fecha 2
    DateTime(2024, 3, 22), // Fecha 3
  ];

  //appbar menuappbar = appbar('0');


  Future<void> _recuperarDatos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String usuarioId = prefs.getString('usuario_id') ?? "";

    // Llamar al servicio para obtener el usuario especialista
    //Map<String, dynamic> userData = await Servicio().obtenerUsuarioEspecialista(int.parse(usuarioId));

    //appbar menu = appbar(usuarioId);

    setState(() {
      //menuappbar = menu;
    });
  }


  void initState() {
    super.initState();
    _recuperarDatos();
    

  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      //appBar: menuappbar.getAppbar(),

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
                  image: DecorationImage(image: NetworkImage('https://mentalink.tepuy21.com/assets/images/ImagenPerfil.png'),fit: BoxFit.cover),
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
                  
                  showActionButtons: true,
                  enablePastDates: false,
                  selectionShape: DateRangePickerSelectionShape.circle,
                
                  
                  selectableDayPredicate: (DateTime date){

                    return isDateSelectable(date,coloredDates);
                  },
                  

                  /*cellBuilder: (BuildContext context, DateRangePickerCellDetails cellDetails) {
                    
                    final DateTime date = cellDetails.date!;
                    final bool isColoredDate = coloredDates.contains(date);

                  

                    return Container(

                      padding: EdgeInsets.all(0),

                      color: isColoredDate ? Colors.red : null,
                      
                      /*decoration: BoxDecoration(
                        color: isColoredDate ? Colors.red : null,
                        shape: BoxShape.circle,
                      ),*/
                      
                      child: Center(
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isColoredDate ? Colors.white : null,
                          ),
                        ),
                      ),
                    );
                  },*/
                    
                

                  
                  
                  onSubmit: (fecha){
                    print(fecha);
                  },
                ),
              ),

              Container(
                          child: ElevatedButton(
                            child: Text('Open Time Picker'),
                            onPressed: () {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              ).then((selectedTime) {
                                if (selectedTime != null) {
                                  print('Selected time: ${selectedTime.format(context)}');
                                }
                              });
                            },
                          )
                        )
        
            ],
          ),
        ),
      ),

      drawer: NowDrawer(currentPage: 'agendarCita',),
      bottomNavigationBar: Footer(),

    );
  }
}

bool isDateSelectable(DateTime date, List<DateTime> disabledDates) {
  // Verifica si la fecha está presente en la lista de fechas deshabilitadas
  return !disabledDates.contains(date);
}

