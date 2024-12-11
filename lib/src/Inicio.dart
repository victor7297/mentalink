// ignore_for_file: use_key_in_widget_constructors, use_build_context_synchronously, avoid_print, deprecated_member_use, prefer_const_constructors, sized_box_for_whitespace, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mentalink/src/Clases/gmail.dart';
import 'package:mentalink/src/Servicios/Servicio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Inicio extends StatefulWidget {
  const Inicio({Key? key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  String? aux2;
  bool Terminos = false;

  @override
  void initState() {
    super.initState();
    validarSession();
  }

  /*validarSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? aux = prefs.getString('token');

    if (aux != null) {
      Navigator.of(context).pushNamed("/Home");
    } else {
      print("es nulo");
    }
  }*/

  validarSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? aux = prefs.getString('token');
    String? tipoUsuario = prefs.getString('tipo_usuario');

    if (aux != null) {
      if (tipoUsuario == 2) {
        Navigator.of(context).pushNamed("/HomeE");
      } else {
        Navigator.of(context).pushNamed("/Home");
      }
    } else {
      print("El token es nulo");
    }
  }

  /*void modalTerminosyCondiciones() {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Text('Términos y Condiciones'),
        ),
        message: Container(
          height: 500,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return Column(
                children: [
                  SizedBox(height: 16),
                  Text('1. Uso de la Aplicación: La aplicación está destinada a usuarios mayores de 18 años.',
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 16),
                  Text('2. Privacidad de Datos: Nos comprometemos a proteger tu información personal. Los datos recopilados se usarán únicamente para mejorar la experiencia del usuario.',
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 16),
                  Text('3. Conducta del Usuario: Se espera que los usuarios se comporten de manera respetuosa y ética. Cualquier conducta inapropiada puede resultar en la suspensión de la cuenta.',
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 16),
                  Text('4. Responsabilidad: La aplicación no se hace responsable por interacciones entre los usuarios.',
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 16),
                  Text('5. Modificaciones: Nos reservamos el derecho de modificar estos términos en cualquier momento.',
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 16),
                  Text('6. Terminación de Servicios: La aplicación puede terminar o suspender el acceso de un usuario si se violan estos términos.',
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 16),
                  /*Row(
                    children: [
                      CupertinoCheckbox(
                        value: Terminos,
                        onChanged: (bool? value) {
                          setModalState(() {
                            Terminos = value ?? false;
                            print(Terminos);
                          });
                        },
                      ),
                      Text('Acepto los Términos y Condiciones'),
                    ],
                  ),*/
                  Divider(),
                  CupertinoButton(
                    child: Text('Cerrar'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Divider(),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}*/


  /*void modalTerminosyCondiciones() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            child: Text('Términos y Condiciones'),
          ),
          message: Container(
            height: 500,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
                return Column(
                  children: [
                    SizedBox(height: 16),
                    Text('1. Uso de la Aplicación: La aplicación está destinada a usuarios mayores de 18 años.',
                    textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    Text('2. Privacidad de Datos: Nos comprometemos a proteger tu información personal. Los datos recopilados se usarán únicamente para mejorar la experiencia del usuario.',
                    textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '3. Conducta del Usuario: Se espera que los usuarios se comporten de manera respetuosa y ética. Cualquier conducta inapropiada puede resultar en la suspensión de la cuenta.',
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    Text('4. Responsabilidad: La aplicación no se hace responsable por interacciones entre los usuarios.',
                    textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    Text('5. Modificaciones: Nos reservamos el derecho de modificar estos términos en cualquier momento.',
                    textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    Text('6. Terminación de Servicios: La aplicación puede terminar o suspender el acceso de un usuario si se violan estos términos.',
                    textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        CupertinoCheckbox(
                          value: Terminos,
                          onChanged: (bool? value) {
                            setModalState(() {
                              Terminos = value ?? false;
                              print(Terminos);
                            });
                          },
                        ),
                        Text('Acepto los Términos y Condiciones'),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }*/

  /*void modalTerminosyCondiciones(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Términos y Condiciones',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        message: Container(
          height: 530,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              PageController _pageController = PageController();
              int currentPage = 0;
              bool Terminos = false; // Inicializa la variable Terminos

              return Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setModalState(() {
                          currentPage = index;
                        });
                      },
                      children: [
                        // Página 1 - Introducción
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 18),
                              Text(
                                '1. Introducción\n'
                                'Bienvenido a [Nombre de la Aplicación] (“la Aplicación”). Estos Términos y Condiciones (“Términos”) rigen el uso de nuestros servicios de atención psicológica virtual. Al utilizar la Aplicación, aceptas estos Términos en su totalidad. Si no estás de acuerdo con estos Términos, no debes utilizar la Aplicación.',
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                        // Página 2 - Servicios Ofrecidos
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Servicios Ofrecidos',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              Text(
                                'La Aplicación proporciona acceso a servicios de atención psicológica virtual, incluyendo sesiones de terapia en línea, recursos educativos y herramientas de autoayuda. Los servicios son proporcionados por profesionales de la salud mental licenciados.',
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Elegibilidad',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              Text(
                                'Para utilizar la Aplicación, debes ser mayor de 18 años o tener el consentimiento de un padre o tutor legal. Al registrarte, confirmas que cumples con este requisito.',
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Registro y Cuenta',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              Text(
                                'Para acceder a los servicios, debes crear una cuenta proporcionando información precisa y actualizada. Eres responsable de mantener la confidencialidad de tu cuenta y contraseña, y de todas las actividades que ocurran bajo tu cuenta.',
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Privacidad y Confidencialidad',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              Text(
                                'Nos comprometemos a proteger tu privacidad. Toda la información personal y de salud proporcionada será tratada de acuerdo con nuestra Política de Privacidad. La confidencialidad de las sesiones de terapia es una prioridad, y utilizamos medidas de seguridad para proteger tus datos.',
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Uso Aceptable',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              Text(
                                'Te comprometes a utilizar la Aplicación de manera responsable y a no participar en actividades que puedan dañar la Aplicación o a otros usuarios. Esto incluye, el uso de la Aplicación para actividades ilegales, el acoso o la difusión de contenido ofensivo.',
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Limitación de Responsabilidad',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              Text(
                                'Los servicios proporcionados a través de la Aplicación son de naturaleza informativa y no sustituyen el consejo, diagnóstico o tratamiento médico profesional. No somos responsables de cualquier daño o pérdida resultante del uso de la Aplicación.',
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Modificaciones a los Términos',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              Text(
                                'Nos reservamos el derecho de modificar estos Términos en cualquier momento. Las modificaciones serán efectivas al ser publicadas en la Aplicación. Es tu responsabilidad revisar los Términos periódicamente.',
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Terminación',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              Text(
                                'Podemos suspender o terminar tu acceso a la Aplicación en cualquier momento, sin previo aviso, si violas estos Términos o por cualquier otra razón a nuestra discreción.',
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Ley Aplicable',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              Text(
                                'Estos Términos se regirán e interpretarán de acuerdo con las leyes de [País], sin tener en cuenta sus disposiciones sobre conflictos de leyes.',
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 14),
                              Text(
                                '11. Contacto',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              Text(
                                'Si tienes alguna pregunta sobre estos Términos, por favor contáctanos en [Correo Electrónico de Contacto].',
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentPage > 0)
                        CupertinoButton(
                          child: Text('Anterior'),
                          onPressed: () {
                            _pageController.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                        ),
                      if (currentPage < 4)
                        CupertinoButton(
                          child: Text('Siguiente'),
                          onPressed: () {
                            _pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                        ),
                      if (currentPage == 4)
                        Row(
                          children: [
                            CupertinoCheckbox(
                              value: Terminos,
                              onChanged: (bool? value) {
                                setModalState(() {
                                  Terminos = value ?? false;
                                });
                              },
                            ),
                            Text(
                              'Acepto los Términos y Condiciones',
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ],
                        ),
                    ],
                  ),
                  Divider(),
                  CupertinoButton(
                    child: Text('Cerrar'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Divider(),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}*/

void modalTerminosyCondiciones(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (BuildContext context) {
      return CupertinoActionSheet(
        title: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            'Términos y Condiciones de Uso',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        message: Container(
          height: 560,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              PageController _pageController = PageController();
              int currentPage = 0;
              bool Terminos = false; // Inicializa la variable Terminos

              return Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setModalState(() {
                          currentPage = index;
                        });
                      },
                      children: [
                        // Página 1 - Introducción
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 14),
                              Text(
                                'Introducción\n',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              Text(
                                'Este instrumento establece las condiciones que regirán la relación entre La Sociedad Mercantil ' + 
                                '“Mindsolutions C.A”, los psicólogos adscritos a la misma y los pacientes que requieren a través de su plataforma digital, de terapia psicológica entre otros servicios.',
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Descripción del Servicio',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              SizedBox(height: 14),
                              Text(
                                'A través de la Plataforma Digital “Mentalink”. “Mindsolutions C.A” ofrece a los pacientes los servicios de terapia psicológica bajo la modalidad online, con profesionales de la Psicología altamente calificados' +
                                'y debidamente certificados. A través del acceso a la plataforma, el paciente podrá agendar su cita con el Psicólogo de su preferencia y realizar el pago correspondiente a través de los medios bancarios disponibles por el canal digital. ',
                                textAlign: TextAlign.left,
                              ),
                              
                            ],
                          ),
                        ),
                        // Página 2 - Servicios Ofrecidos
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 14),
                              Text(
                                'Condiciones del Servicio',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              SizedBox(height: 14),
                              Text(
                                '-	El paciente deberá registrarse en la Plataforma, ingresando sus datos personales, y  podrá agendar su cita con el psicólogo de su preferencia, de acuerdo al horario disponible.',
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                '-	El paciente tendrá hasta 48 horas para cancelar su próxima consulta, en caso de que desee tener continuidad de atención con un Psicólogo especifico, de lo contrario perderá la disponibilidad de atención en la fecha y hora agendada, por lo que deberá reprogramar de acuerdo a la disponibilidad del mismo.',
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                '-	El paciente deberá contar con una conexión a internet adecuada y disponer del tiempo de duración de la sesión terapéutica. ',
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                '-	En caso de no poder asistir a la misma, deberá notificar a la Plataforma, con una anticipación de dos (02) horas previos a la consulta, y a través de los medios de contacto para que la misma sea reagendada. Queda entendido que el incumplimiento de ésta disposición ocasionará la imposibilidad de reagendar y la devolución del importe pagado por la sesión terapéutica.  ',
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 14),
                              
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 14),
                              Text(
                                '-	El Paciente podrá notificar cualquier reclamo sobre los servicios recibidos a nivel de la Plataforma y por parte del Psicólogo tratante, a través de los medios de contacto de la Plataforma Digital.',
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                '-	El Paciente exime de cualquier responsabilidad a “Mindsolutions C.A”, por las actuaciones del Psicólogo que éste adscrito a la Plataforma Digital, de nacionalidad extranjera y que considere atenten contra las normas y principios que rigen el libre ejercicio de su profesión. De darse el mismo supuesto pero con un Psicólogo de nacionalidad Venezolana, que se encuentre prestando el servicio dentro del territorio nacional, frente a cualquier acción jurídica o denuncia ante algún órgano administrativo o judicial, “Mindsolutions C.A”, limita su responsabilidad en facilitar a éstos últimos, cualquier información relacionada al Psicólogo que consideren necesaria.',
                                textAlign: TextAlign.left,
                              ),
  
                            ],
                          ),
                        ),
                        // Página 3 - Privacidad y Confidencialidad
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Condición de privacidad',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Al usar o acceder a la  Plataforma Digital “Mentalink” el paciente o  usuario está aceptando la siguiente condición: Cuando usted visita nuestra plataforma, proporciona información personal de manera directa,  como su nombre, apellido, datos de contacto, nombre de usuario, etc; toda vez que se les son solicitadas; y de manera indirecta, toda vez que interactúa con nuestra plataforma por voluntad propia. En cualquiera de los casos, es decisión del usuario suministrar, o no, dicha información. ',
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Seguridad',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              SizedBox(height: 14),
                              Text(
                                'La participación en nuestra plataforma es voluntaria. Usted es responsable de mantener la confidencialidad de su ingreso y es totalmente responsable de todas las actividades que ocurran durante su interacción. ',
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Conducta de los miembros',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              SizedBox(height: 15),
                              Text(
                                'Usted acepta no utilizar el sitio para:',
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 15),
                              Text(
                                '– hacerse pasar por cualquier persona o entidad.',
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                '– publicar, enviar por correo electrónico, transmitir o poner a disposición de cualquier otro modo cualquier contenido que infrinja cualquier patente, marca comercial, secreto comercial, derechos de autor u otros derechos de propiedad de  “Mindsolutions C.A”, puestos a su disposición en la Plataforma Digital “Mentalink”.',
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                '– publicar, enviar por correo electrónico, transmitir o poner a disposición cualquier material que contenga virus de software o cualquier otro código informático, archivos o programas diseñados para interrumpir, destruir o limitar la funcionalidad de cualquier software o hardware informático o equipo de telecomunicaciones.',
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                '– interferir o interrumpir el sitio o los servidores o redes conectados al sitio, o desobedecer cualquier requisito, procedimiento, política o reglamento de las redes conectadas al sitio.',
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                '– recopilar o almacenar datos personales sobre otros usuarios.',
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                        // Página 4 - Modificaciones a los Términos
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 14),
                              Text(
                                'Al aceptar estos términos y condiciones, usted acepta que “Mindsolutions C.A” tiene el derecho de (pero no la obligación), a su entera discreción, de editar, eliminar, rechazar o mover cualquier contenido que esté disponible a través del sitio. Usted acepta que debe evaluar y asumir todos los riesgos asociados con el uso de cualquier contenido.',
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Usted reconoce y acepta que “Mindsolutions C.A” puede preservar el contenido y también puede divulgarlo si así lo exige la ley o si cree de buena fe que dicha preservación o divulgación es razonablemente necesaria para: (a) cumplir con un proceso legal; (b) hacer cumplir las Condiciones de uso y servicios para los usuarios de redes sociales y plataformas digitales; (c) responder a reclamos de que cualquier contenido que viole los derechos de terceros; o (d) proteger los derechos, la propiedad o la seguridad personal de “Mindsolutions C.A”, sus usuarios y el público.',
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 14),
                              Text(
                                'Admoniciones especiales para uso internacional',
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Reconociendo la naturaleza global de Internet, usted se compromete a cumplir con todas las reglas locales relativas a la conducta en línea y al contenido aceptable. Específicamente, usted acepta cumplir con todas las leyes aplicables en relación con la transmisión de datos técnicos desde el país en el que reside.',
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Indemnización',
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Usted acepta indemnizar y eximir de responsabilidad a “Mindsolutions C.A” por cualquier reclamación o demanda, incluidos los honorarios profesionales de los abogados, presentada por usted en contra del Psicólogo encargado de su atención psicológica, en virtud de la responsabilidad directa que recae sobre éste último.',
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 14),
                              Text(
                                'No reventa del servicio',
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Usted se compromete a no reproducir, duplicar, copiar, vender, revender o explotar con fines comerciales, ninguna parte del sitio del servicio y su Plataforma Digital.',
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Modificaciones al Servicio',
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              SizedBox(height: 14),
                              Text(
                                '“Mindsolutions C.A” se reserva el derecho de modificar o interrumpir, de forma temporal o permanente, el sitio (o cualquier parte del mismo) en cualquier momento. Usted acepta que “Mindsolutions C.A” no será responsable ante usted ni ante ningún tercero por cualquier modificación, suspensión o interrupción del sitio.',
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Acciones de defensa',
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              SizedBox(height: 14),
                              Text(
                                '“Mindsolutions C.A” está en pleno derecho de bloquear de todas sus redes y plataformas a aquellos usuarios que no cumplan con las condiciones y términos aquí descritos. ',
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 14),
                              Text(
                                'Condiciones de uso, avisos y revisiones',
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Nos reservamos el derecho de cambiar nuestra Política de Privacidad y nuestras Condiciones de Uso en cualquier momento. Si hacemos cambios, los publicaremos e informaremos a la comunidad de los cambios. Si hacemos cambios significativos a esta política, se lo notificaremos a través de un aviso en nuestra página de inicio. Le animamos a que consulte este documento de forma continuada para que entienda nuestra Política de Privacidad las cuales éstan previstas en la página web de “Mindsolutions C.A” y en la “Plataforma Digital Mentalink”.',
                                textAlign: TextAlign.left,
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Contacto con el sitio web',
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                              SizedBox(height: 14),
                              Text(
                                'Si tiene alguna pregunta sobre esta política de privacidad, algún requerimiento o reclamo,  por favor contacte al “Mindsolutions C.A” a través de cualquiera de nuestros medios de contacto.',
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (currentPage < 2)
                        CupertinoButton(
                          child: Text('Anterior'),
                          onPressed: () {
                            _pageController.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                        ),
                      if (currentPage < 2)
                        CupertinoButton(
                          child: Text('Siguiente'),
                          onPressed: () {
                            _pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                        ),
                      
                    ],
                  ),
                  
                  Divider(),
                  CupertinoButton(
                    child: Text('Cerrar'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Divider(),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}




  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage("https://mentalink.org/assets/images/fondo.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 14),
                Container(
                  width: 160,
                  child: Image.network(
                    'https://mentalink.org/assets/images/Logo_Mentalink.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  margin: EdgeInsets.only(bottom: 15),
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/RegistroParte1');
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
                      'Crear una cuenta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                            width: 2.0, color: Color.fromARGB(255, 0, 188, 207)),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      'Ya Tengo Una Cuenta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ' O inicia con Google',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: ElevatedButton(
                    /*onPressed: () async {
                      try{

                        final user = await gmail.login();

                        final GoogleSignInAuthentication googleAuth = await user!.authentication;

                        Map<String,dynamic> data = {
                          "correo": user.email
                        };

                        data = await Servicio().verificarCorreo(data);

                        if(data['status'] == "success"){

                          data = data['data'];

                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString('token', data['token_seguridad']);
                          await prefs.setString('usuario_id', data['usuario_id']);
                          await prefs.setString('tipo_usuario', data['perfil_id']);

                          await gmail.disconnect();
                          
                          Navigator.of(context).pushNamed("/Home");

                        }
                        else{

                          final snackBar = SnackBar(
                            content: Text(
                              'Usuario no encontrado.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Color.fromARGB(255, 0, 188, 207),
                          );

                          // Muestra el SnackBar
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);

                          await gmail.disconnect();

                        }

                      }
                      catch(e){
                        print(e);
                        await gmail.disconnect();
                      }
                    },*/

                    onPressed: () async {
                      try {
                        final user = await gmail.login();

                        if (user == null) {
                          // Si el usuario no se logró autenticar
                          final snackBar = SnackBar(
                            content: Text('No se pudo autenticar con Google.'),
                            backgroundColor: Colors.red,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          return;
                        }

                        final GoogleSignInAuthentication googleAuth = await user.authentication;

                        Map<String, dynamic> data = {
                          "correo": user.email
                        };

                        // Llamamos al servicio para verificar el correo
                        data = await Servicio().verificarCorreo(data);
                      

                        if (data['status'] == "success") {
                          
                          data = data['data'];

                          // Guardamos la información en SharedPreferences
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString('token', data['token_seguridad']);
                          await prefs.setString('usuario_id', data['usuario_id']);
                          await prefs.setString('tipo_usuario', data['perfil_id']);

                          await gmail.disconnect();
                          
                          Navigator.of(context).pushNamed("/Home");

                        } else {
                          final snackBar = SnackBar(
                            content: Text('Usuario no encontrado.'),
                            backgroundColor: Colors.blue,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);

                          await gmail.disconnect();
                        }

                      } catch (e) {

                        print("Error: $e");

                        final snackBar = SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

                        await gmail.disconnect();
                      }
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.google,
                          size: 20,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CupertinoButton(
                        onPressed: () => modalTerminosyCondiciones(context),
                        child: Text(
                          'Términos y Condiciones',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        aux2 ?? "",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
