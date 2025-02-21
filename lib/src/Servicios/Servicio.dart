// ignore_for_file: avoid_print, unused_import, non_constant_identifier_names, prefer_interpolation_to_compose_strings, unnecessary_cast

import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentalink/src/Views/Psicologos/agendarCita.dart';

class Servicio {
  String ruta = "https://mentalink.org/api-mentalink-prueba-v/public/";
  //String ruta = "https://mentalink.tepuy21.com/api-mentalink/public/";

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

  /*Future<List<Map<String, dynamic>>> UsuariosEspecialistas() async {
    var url = Uri.parse(ruta + "usuarios-especialistas");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('${response.statusCode}');
    }
  }*/

  Future<List<Map<String, dynamic>>> UsuariosEspecialistas(
      String usuarioId) async {
    var url = Uri.parse(ruta + "usuarios-especialistas-favorito/$usuarioId");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> UsuariosAsignados(String usuarioId) async {
    var url = Uri.parse(ruta + "pacientes-asignados/$usuarioId");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> obtenerInformacionUsuarioEspecialista(
      int id) async {
    var url = Uri.parse(ruta + "usuarios-especialistas/$id");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> obtenerUsuario(int id) async {
    var url = Uri.parse(ruta + "usuarios/$id");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> angendarCita(Map<String, dynamic> data) async {
    var url = Uri.parse(ruta + "agendar-cita");
    var response = await http.post(url, body: data);
    var respuestaJson = jsonDecode(response.body);

    return respuestaJson;
  }

  Future<Map<String, dynamic>> marcarUsuario(
      String usuarioId, String pacienteId) async {
    var url = Uri.parse(ruta + "marcar-favorito/$pacienteId/$usuarioId");
    var response = await http.post(url);
    var respuestaJson = jsonDecode(response.body);
    return respuestaJson;
  }

  /*Future<Map<String, dynamic>> actualizarFotoPerfil(int usuarioId, File fotoFile) async {
    var url = Uri.parse(ruta + "usuarios/$usuarioId/foto_perfil");
    
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('foto', fotoFile.path));

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    var respuestaJson = jsonDecode(responseBody);

    if (response.statusCode == 200) {
      return respuestaJson;
    } else {
      throw Exception('${response.statusCode}');
    }
  }*/

  Future<void> actualizarFotoPerfil(File fotoFile, int usuarioId) async {
    var url = Uri.parse(ruta + "usuarios/$usuarioId/foto_perfil");

    var request = http.MultipartRequest('POST', url);
    var multipartFile = http.MultipartFile(
      'foto',
      fotoFile.readAsBytes().asStream(),
      fotoFile.lengthSync(),
      filename: fotoFile.path.split('/').last,
    );
    request.files.add(multipartFile);
    request.headers['Accept'] = 'image.webp';

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var respuestaJson = jsonDecode(responseData);

    return respuestaJson;
  }

  // falta usar esto para mostrar los horarios en algun lado

  Future<Map<String, dynamic>> consultarHorarios(int psicologoId) async {
    var url = Uri.parse(ruta + "/horario-especialista/$psicologoId");
    var response = await http.get(url);

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> testAsignados(int id) async {
    var url = Uri.parse(ruta + "test-asignados/$id");
    var response = await http.get(url);

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> progresoTestCooper(int id) async {
    var url = Uri.parse(ruta + "progreso-cooper/$id");
    var response = await http.get(url);

    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> progresoTestBdi(int id) async {
    var url = Uri.parse(ruta + "progreso-bdi/$id");
    var response = await http.get(url);

      return json.decode(response.body);
  }

  Future<Map<String, dynamic>> progresoTestAnsiedad(int id) async {
    var url = Uri.parse(ruta + "progreso-ansiedad/$id");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> progresoTestAsertividad(int id) async {
    var url = Uri.parse(ruta + "progreso-asertividad/$id");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> progresoTestDesesperanza(int id) async {
    var url = Uri.parse(ruta + "progreso-desesperanza/$id");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> progresoTestLaboral(int id) async {
    var url = Uri.parse(ruta + "progreso-laboral/$id");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('${response.statusCode}');
    }
  }

  Future<void> enviarRespuestaTestCooper(
      int preguntaId, int respuesta, int usuarioId) async {
    var url = Uri.parse(ruta + 'testcooper');

    // formato d epregunta
    var nombrePregunta = 'p${preguntaId + 1}_${respuesta}';

    var body = jsonEncode({
      'alumno_id': usuarioId,
      'nombrePregunta': nombrePregunta,
      'respuesta': respuesta,
    });

    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al enviar datos: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> TestCooperRespuestas(int id) async {
    var url = Uri.parse(ruta + "testcooper/$id");
    var response = await http.get(url);

      return json.decode(response.body);

  }

  Future<void> enviarRespuestaTestBDI(
      int preguntaId, int respuesta, int numOpciones, int usuarioId) async {
    var url = Uri.parse(ruta + 'testbdi');

    // formato d epregunta
    var nombrePregunta = 'p${preguntaId + 1}';

    var body = jsonEncode({
      'alumno_id': usuarioId,
      'nombrePregunta': nombrePregunta,
      'respuesta': respuesta,
      'opciones': numOpciones,
    });

    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al enviar datos: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> TestBDIRespuestas(int id) async {
    var url = Uri.parse(ruta + "testbdi/$id");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('${response.statusCode}');
    }
  }

  Future<void> enviarRespuestaTestAnsiedad(
      int preguntaId, int respuesta, int usuarioId) async {
    var url = Uri.parse(ruta + 'test-ansiedad');

    // formato d epregunta
    var nombrePregunta = 'p${preguntaId + 1}';

    var body = jsonEncode({
      'alumno_id': usuarioId,
      'nombrePregunta': nombrePregunta,
      'respuesta': respuesta,
      'opciones': "4"
    });

    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al enviar datos: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> TestAnsiedadRespuestas(int id) async {
    var url = Uri.parse(ruta + "test-ansiedad/$id");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('${response.statusCode}');
    }
  }

  Future<void> enviarRespuestaTestAsertividad(
      int preguntaId, int respuesta, int usuarioId) async {
    var url = Uri.parse(ruta + 'testasertividad');

    // formato d epregunta
    var nombrePregunta = 'p${preguntaId + 1}';

    var body = jsonEncode({
      'alumno_id': usuarioId,
      'nombrePregunta': nombrePregunta,
      'respuesta': respuesta,
    });

    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al enviar datos: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> TestAsertividadRespuestas(int id) async {
    var url = Uri.parse(ruta + "test-asertividad/$id");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('${response.statusCode}');
    }
  }

  Future<void> enviarRespuestaTestDesesperanza(
      int preguntaId, int respuesta, int usuarioId) async {
    var url = Uri.parse(ruta + 'test-desesperanza');

    // formato d epregunta
    var nombrePregunta = 'p${preguntaId + 1}';

    var body = jsonEncode({
      'alumno_id': usuarioId,
      'nombrePregunta': nombrePregunta,
      'respuesta': respuesta,
    });

    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al enviar datos: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> TestDesesperanzaRespuestas(int id) async {
    var url = Uri.parse(ruta + "test-desesperanza/$id");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('${response.statusCode}');
    }
  }

  Future<void> enviarRespuestaTestLaboral(
      int preguntaId, int respuesta, int usuarioId) async {
    var url = Uri.parse(ruta + "test-laboral");

    // formato d epregunta
    var nombrePregunta = 'p${preguntaId + 1}';

    var body = jsonEncode({
      'alumno_id': usuarioId,
      'nombrePregunta': nombrePregunta,
      'respuesta': respuesta,
      'opciones': "5"
    });

    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Error al enviar datos: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> TestLaboralRespuestas(int id) async {
    var url = Uri.parse(ruta + "test-laboral/$id");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('${response.statusCode}');
    }
  }

  Future<List<dynamic>> CitasPaciente(int id) async {
    var url = Uri.parse(ruta + "citas-paciente/$id");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('${response.statusCode}');
    }
  }

  Future<List<dynamic>> CitasPsicologo(int id) async {
    var url = Uri.parse(ruta + "citas-psicologo/$id");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception('${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> statusCita(String citaId, String status) async {
    var url = Uri.parse(ruta + 'citas/$citaId');

    Map<String, String> data = {
      "status": status,
    };

    var response = await http.put(
      url,
      body: data,
    );

    var respuestaJson = jsonDecode(response.body);
    return respuestaJson;
  }

  Future<dynamic> updateDatosUsuario(id, data) async {
    var url = Uri.parse(ruta + "usuarios/" + id);
    var response = await http.put(url, body: data);
    var respuestaJson = jsonDecode(response.body);

    return respuestaJson;
  }

  Future<dynamic> updatePassword(data) async {
    var url = Uri.parse(ruta + "cambiar-contrasena-perfil");
    var response = await http.put(url, body: data);
    var respuestaJson = jsonDecode(response.body);

    return respuestaJson;
  }

  /*Future<Map<String, dynamic>> actualizarCita(
      String citaId, DateTime nuevaFechaHora) async {
    final response = await http.post(
      Uri.parse(ruta + 'reprogramar-cita'),
      body: json.encode({
        'cita_id': citaId,
        'nueva_fecha_hora': nuevaFechaHora.toIso8601String()
      }),
    );

    var respuestaJson = jsonDecode(response.body);
    return respuestaJson;
  }*/

  Future<Map<String, dynamic>> actualizarCita(
    String citaId, DateTime nuevaFechaHora) async {
    final response = await http.put(
      Uri.parse(ruta + 'reprogramar-cita'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'cita_id': citaId,
        'nueva_fecha_hora': nuevaFechaHora.toIso8601String(),
      }),
    );

      var respuestaJson = jsonDecode(response.body);
      return respuestaJson;

  }

  Future<Map<String, dynamic>> cancelarCita(String citaId, String causa) async {
    final response = await http.put(
      Uri.parse(ruta + 'cancelar-cita'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'cita_id': citaId, 'causa': causa}),
    );

    var respuestaJson = jsonDecode(response.body);
    return respuestaJson;
  }

  /*FutureMap<String, List<String>> horarioDisponible(int id) async {
    var url = Uri.parse(ruta + "horario-especialista-citas/$id");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('${response.statusCode}');
    }
  }*/

  Future<Map<String, List<String>>> horarioDisponible(
      int id, String fecha) async {
    var url = Uri.parse(ruta + "horario-especialista-hola/$id/$fecha");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      // Decodifica la respuesta JSON
      var decodedResponse = json.decode(response.body) as Map<String, dynamic>;

      // Convierte el Map<dynamic, dynamic> a Map<String, List<String>>
      var result = decodedResponse.map(
        (key, value) => MapEntry(
          key,
          (value as List).map((item) => item.toString()).toList(),
        ),
      ) as Map<String, List<String>>;

      return result;
    } else {
      throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  Future<Map<String, List<String>>> horasDisponibles(
      int id, String fecha) async {
    var url = Uri.parse(ruta + "horario-especialista/$id/$fecha");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      // Decodifica la respuesta JSON
      var decodedResponse = json.decode(response.body) as Map<String, dynamic>;

      // Convierte el Map<dynamic, dynamic> a Map<String, List<String>>
      var result = decodedResponse.map(
        (key, value) => MapEntry(
          key,
          (value as List).map((item) => item.toString()).toList(),
        ),
      ) as Map<String, List<String>>;

      return result;
    } else {
      throw Exception('Error ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  Future<dynamic> recuperarPassword(data) async {
    var url = Uri.parse(ruta + "recuperar-cuenta");
    var response = await http.post(url, body: data);
    var respuestaJson = jsonDecode(response.body);

    return respuestaJson;
  }

  Future<dynamic> actualizarPassword(data) async {
    var url = Uri.parse(ruta + "cambiar-contrasena");
    var response = await http.put(url, body: data);
    var respuestaJson = jsonDecode(response.body);

    return respuestaJson;
  }

  Future<dynamic> verificarCorreo(data) async {
    var url = Uri.parse(ruta + "verificar_correo");
    var response = await http.post(url, body: data);
    var respuestaJson = jsonDecode(response.body);

    return respuestaJson;
  }

  Future<dynamic> enviarCorreoCodigo(data) async {
    var url = Uri.parse(ruta + "enviar-codigo-verificacion");
    var response = await http.post(url, body: data);
    var respuestaJson = jsonDecode(response.body);

    return respuestaJson;
  }

  Future<dynamic> verificarCorreoCodigo(data) async {
    var url = Uri.parse(ruta + "verificar-codigo-correo");
    var response = await http.post(url, body: data);
    var respuestaJson = jsonDecode(response.body);

    return respuestaJson;
  }


  Future<dynamic> enviarDatos(
      {String? telefono,
      String? banco,
      String? referencia,
      String? cedula,
      required String correo,
      required String tipoCita,
      required String monto}) async {
    var url = Uri.parse(ruta + "enviar-datos-pago");

    var data = {
      'telefono': telefono,
      'banco': banco,
      'referencia': referencia,
      'cedula': cedula,
      'correo': correo,
      'tipo_cita': tipoCita,
      'monto': monto,
    };

    var response = await http.post(url, body: jsonEncode(data), headers: {
      'Content-Type': 'application/json',
    });

    var respuestaJson = jsonDecode(response.body);

    return respuestaJson;
  }

  Future<dynamic> guardarEncuesta(Map<String, String> data) async {
    var url = Uri.parse(ruta + "guardar_encuesta");
    var response = await http.post(url, body: data);
    var respuestaJson = jsonDecode(response.body);

    return respuestaJson;
  }

  Future<Map<String, dynamic>> validarPago(
      {required String referencia,
      required String cedula,
      required String banco,
      required String telefono,
      required String amount,
      required String startDate,
      required String endDate,
      required String ipAddress}) async {
    // Cuerpo de la solicitud
    Map<String, dynamic> requestBody = {
      "branchCommerce": "93492000000",
      "channelCode": "API",
      "issuingEntity": "0134",
      "ipAddress": ipAddress,
      "data": {
        "dates": {
          "startDate": startDate,
          "endDate": endDate,
        },
        "customerID": cedula,
        "customerPhone": telefono,
        "entity": banco,
        "reference": referencia,
        "bill": "null",
        "amount": amount,
      }
    };

    var url =
        Uri.parse('https://trebol.vippo.mobi:9191/cobromovil/validate_payment');

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey':
            '63B5AD5BD32BFFECFA0DFA377ECF1A131AB253DCE097FE36CD726EFEE1A986D8',
        'account': '93492',
      },
      body: jsonEncode(requestBody),
    );
    var respuestaJson = jsonDecode(response.body);
    return respuestaJson;
  }

  Future<Map<String, dynamic>> obtenerDolarOficial() async {
    var url = Uri.parse('https://ve.dolarapi.com/v1/dolares/oficial');
    var response = await http.get(url);

      return json.decode(response.body);
  }

  Future<dynamic> prueba() async {
    var url = Uri.parse(ruta + "usuarios");
    var response = await http.get(url);
    var respuestaJson = jsonDecode(response.body);

    if (response.statusCode == 200) {
      var data = {"status": response.statusCode};

      return data;
    } else {
      var data = {"status": response.statusCode};

      return data;
    }
  }
}
