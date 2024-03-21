// ignore_for_file: use_key_in_widget_constructors, avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, avoid_print, body_might_complete_normally_nullable, unused_local_variable

import 'package:flutter/material.dart';
import 'package:mentalink/src/Views/Usuarios/Clases/appbar.dart';
import 'package:mentalink/src/Views/Usuarios/Home/Widgets/formularioPreguntas.dart';
import 'package:mentalink/src/Widgets/drawerMenu.dart';
import 'package:mentalink/src/Widgets/footer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {


  int paginaActual = 0;
  bool mostrarFormulario = false;
  List<dynamic> listaPsicologos = [
    {
      "profesion":"Psicólogo"
    },
    {
      "profesion":"Psicólogo"
    },
    {
      "profesion":"Psicólogo"
    },
    {
      "profesion":"Psicólogo"
    },
    {
      "profesion":"Psicólogo"
    },
    {
      "profesion":"Psicólogo"
    },

  ];

  prueba(){

    print("hola victor");
  }

  @override
  void initState() {
    prueba();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    String nombrePsicologo = "";

    return mostrarFormulario ? formularioPreguntas(): 
    Scaffold(

      appBar: appbar().getAppbar(),

      body: Container(

        padding: EdgeInsets.only(top: 30, bottom: 50, left: 20, right: 20),
        
        child: Column(

          children: [


            /**************************Estados Psicologos****************************************/

            Container(

              height: 80,
              //color: Colors.blue,

              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: listaPsicologos.length,
                itemBuilder: (context,index){

                  nombrePsicologo = listaPsicologos[index]['profesion'];

                  return InkWell(
                    onTap: (){
                      print("hola");
                    },
                    child: Container(

                      child: Column(
                    
                        children: [
                    
                          Container(
                            width: 50,
                            height: 50,
                            margin: EdgeInsets.only(left: 5,right: 5,top: 5,bottom: 0),
                            //color: Colors.green,
                            decoration: BoxDecoration(
                              //color: Colors.red,
                              borderRadius: BorderRadius.circular(50), // Radio de 50 para lograr la forma redonda
                              image: DecorationImage(image: NetworkImage('https://mentalink.tepuy21.com/assets/images/ImagenPerfil.png'),fit: BoxFit.cover),
                              border: Border.all(
                                color: Colors.green,
                                width: 2,
                              ),
                            ),
                          ),
                    
                          Container(child: Text("victor", style: TextStyle(fontWeight: FontWeight.bold),),)
                        ],
                      ),
                    )
                  );
                  
                } 
              ),

            ),

            /**********************************Filtro*****************************************************************/

            Container(
              //color: Colors.amber,
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  Container(

                    width: 150,
                    height: 35,
                    
                    child: TextFormField(

                      decoration: InputDecoration(
                        labelText: 'Buscar',
                        filled: false,// Esta propiedad permite quitarle el color de fondo a los textFormField

                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromRGBO(10, 28, 92, 1)), // Borde cuando el campo no está enfocado
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue), // Borde cuando el campo está enfocado
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red), // Borde cuando hay un error
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red), // Borde cuando el campo está enfocado y hay un error
                        ),

                        suffixIcon: Container(
                          child: TextButton(
                              child: Icon(Icons.search),
                              onPressed: (){},
                            ),
                        )

                      ),
                    ),
                  ),

                  Container(
                    child: TextButton(
                      onPressed: () {
                      
                      },
                      child: Icon(Icons.filter_list),
                    ),
                  ),
                ],
              ),
            ),

            /**********************************Lista Psicologos*****************************************************************/

            Expanded(
              child: Container(
            
                //height: 100,
                margin: EdgeInsets.only(top: 20),
            
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: listaPsicologos.length,
                  itemBuilder: (context,index){
            
                    nombrePsicologo = listaPsicologos[index]['profesion'];
            
                    return InkWell(
                      onTap: (){
                        Navigator.of(context).pushNamed("/menuEspecialistas");
                      },
                      child: Container(

                        height: 130,
                        margin: EdgeInsets.only(top: 10),
                    
                        
                        child: Card(
                          color: Colors.white,
                          elevation: 4.0,
            
                          child: Padding(
                            padding: EdgeInsets.all(10),

                            child: Column(

                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                          
                                Container(
                          
                                  child: Row(
                          
                                    children: [
                          
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(50), // Radio de 50 para lograr la forma redonda
                                          image: DecorationImage(image: NetworkImage('https://mentalink.tepuy21.com/assets/images/ImagenPerfil.png'),fit: BoxFit.cover),
                                        ),
                                      ),
            
                                      Container(
            
                                        margin: EdgeInsets.only(left:10),
                                        padding: EdgeInsets.all(5),
            
                                        child: Column(
            
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
            
                                            Container( child: Text("Dr. Victor Caceres", style: TextStyle(fontWeight: FontWeight.bold),),),
                                            Container( child: Text("Psicólogo", style: TextStyle(fontWeight: FontWeight.w200),),)
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
            
                                Container(
            
                                  child: Row(
            
                                    mainAxisAlignment: MainAxisAlignment.end,
            
                                    children: [
            
                                      Container(
                                        margin: EdgeInsets.only(right: 5),

                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(50), // Radio de 50 para lograr la forma redonda
                                      
                                        ),
            
                                        child: TextButton(
                                          onPressed: () {
                                          
                                          },
                                          style: ButtonStyle(elevation:MaterialStateProperty.all(10.0)),
                                          child: Icon(Icons.star,color: Colors.white,),

                                        ),
                                      ),
            
                                      Container(

                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(50), // Radio de 50 para lograr la forma redonda
                                      
                                        ),
                                        child: TextButton(
                                          onPressed: () {
                                          
                                          },
                                          style: ButtonStyle(elevation:MaterialStateProperty.all(10.0)),
                                          child: Icon(Icons.search, color: Colors.white,),
                                        ),
                                      ),
            
            
                                    ],
                                  ),
                                ),
                          
                              ],
                            ),
                          ),
                        ),
                      )
                    );
                    
                  } 
                ),
              ),
            )

          ],
        ),
      ),

      drawer: drawerMenu(),
      bottomNavigationBar: Footer(),
    );
  }
}


/*class HomePrincipal  extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Contenido del Widget Dos
      child: Text('Widget Dos'),
    );
  }
}*/


