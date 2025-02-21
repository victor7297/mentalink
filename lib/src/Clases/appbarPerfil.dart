import 'package:flutter/material.dart';

class AppBarPerfil{
  
  PreferredSizeWidget? appBar = AppBar(
    
    title: Container(

      child: Row(

        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [

          
        ],
      ),
    ),
    //toolbarHeight: 65,
    backgroundColor: Colors.transparent,
    foregroundColor: const Color.fromARGB(255, 3, 3, 3),
    elevation: 0,
  );

  getAppbar(){

    return appBar;
  }
}
