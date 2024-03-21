// ignore_for_file: camel_case_types, prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';

class drawerMenu extends StatefulWidget {
  const drawerMenu({super.key});

  @override
  State<drawerMenu> createState() => _drawerMenuState();
}

class _drawerMenuState extends State<drawerMenu> {
  @override
  Widget build(BuildContext context) {
    return Drawer(

        child: ListView(
        
          children: [
        
            DrawerHeader(
        
              decoration: BoxDecoration(color: Color.fromRGBO(0, 189, 206, 1)),
              child: Column(
            
                children: [
            
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(50), // Radio de 50 para lograr la forma redonda
                      image: DecorationImage(image: NetworkImage('https://mentalink.tepuy21.com/assets/images/ImagenPerfil.png'),fit: BoxFit.cover),
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.only(top: 20),
                    child: Text("Hola Victor!",style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),

            ListTile(
              title: Text("Inicio",style: TextStyle(color: Color.fromRGBO(10, 28, 92, 1), fontWeight: FontWeight.bold)),
              leading: Icon(Icons.home),
              iconColor: Color.fromRGBO(10, 28, 92, 1),
              onTap: () {
                print("home");
              },
            ),

            ListTile(
              title: Text("Perfil",style: TextStyle(color: Color.fromRGBO(10, 28, 92, 1), fontWeight: FontWeight.bold)),
              leading: Icon(Icons.account_circle),
              iconColor: Color.fromRGBO(10, 28, 92, 1),
              onTap: () {
                print("perfil");
              },
            ),

            ListTile(
              title: Text("Salir",style: TextStyle(color: Color.fromRGBO(10, 28, 92, 1), fontWeight: FontWeight.bold),),
              leading: Icon(Icons.logout),
              iconColor: Color.fromRGBO(10, 28, 92, 1),
              onTap: () {
                print("salir");
              },
            )

          ],
        )
      );
  }
}