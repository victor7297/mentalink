// ignore_for_file: avoid_print, unused_import, non_constant_identifier_names, prefer_interpolation_to_compose_strings

import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Servicio {

  String ruta = "https://mentalink.tepuy21.com/api-mentalink_app/public/";

  Future<Map<String, dynamic>> registrarUsuario(

    Map<String, dynamic> data) async {
    var url = Uri.parse(ruta + "usuarios");
    var response = await http.post(url, body: data);
    var respuestaJson = jsonDecode(response.body);

    return respuestaJson;
  }

  Future<dynamic> validarLogin(data) async {

    var url = Uri.parse(ruta + "login");
    var response = await http.post(url, body: data);
    var respuestaJson = jsonDecode(response.body);

    return respuestaJson;
  }

    
}
