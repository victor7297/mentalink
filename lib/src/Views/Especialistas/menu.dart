// ignore_for_file: camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, annotate_overrides

import 'package:flutter/material.dart';
import 'package:mentalink/src/Clases/appbar.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:mentalink/src/Widgets/drawer.dart';
import 'package:mentalink/src/Widgets/footer.dart';
import 'package:shared_preferences/shared_preferences.dart';


class menu extends StatefulWidget {
  const menu({super.key});

  @override
  State<menu> createState() => _menuState();
}

class _menuState extends State<menu> {

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

      body: Container(
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

              
              child: InkWell(

                onTap: (){
                  Navigator.of(context).pushNamed("/agendarCita");
                },

                child: Card(
                
                  color: Color.fromRGBO(0, 189, 206, 1),
                
                  child: Padding(
                    padding: EdgeInsets.all(15),
                
                    child: Row(
                    
                      children: [
                    
                        Container( margin: EdgeInsets.only(right: 5), child: Icon(Icons.calendar_month, size: 35,)),
                        Container( child: Text("Agenda una cita"),)
                    
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Container(

              
              child: Card(

                color: Color.fromRGBO(0, 189, 206, 1),

                child: Padding(
                  padding: EdgeInsets.all(15),

                  child: Row(
                  
                    children: [
                  
                      Container( margin: EdgeInsets.only(right: 5), child: Icon(Icons.calendar_month, size: 35,)),
                      Container( child: Text("Necesito hablar ahora"),)
                  
                    ],
                  ),
                ),
              ),
            ),

            Container(

              
              child: Card(

                color: Color.fromRGBO(0, 189, 206, 1),

                child: Padding(
                  padding: EdgeInsets.all(15),

                  child: Row(
                  
                    children: [
                  
                      Container( margin: EdgeInsets.only(right: 5), child: Icon(Icons.calendar_month, size: 35,)),
                      Container( child: Text("Iniciar test evaluativo"),)
                  
                    ],
                  ),
                ),
              ),
            ),

          ],
        ),
      ),

      drawer: NowDrawer(currentPage: 'menuEspecialistas',),
      bottomNavigationBar: Footer(),
    );
  }
}