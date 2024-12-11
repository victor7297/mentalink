// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NowDrawer extends StatelessWidget {
  final String currentPage;

  NowDrawer({required this.currentPage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color.fromRGBO(9, 25, 87, 1.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 18),
              width: MediaQuery.of(context).size.width * 0.85,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 12),
                        width: 160,
                        child: Image.network(
                          'https://mentalink.org/assets/images/Logo_Mentalink.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: IconButton(
                          icon: Icon(Icons.menu,
                              color: Colors.white.withOpacity(0.82),
                              size: 24.0),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: ListView(
                padding: EdgeInsets.only(top: 30, left: 8, right: 16),
                children: [
                  _buildDrawerTile(
                    icon: FontAwesomeIcons.home,
                    title: "Home",
                    isSelected: currentPage == "Home",
                    onTap: () {
                      Navigator.of(context).pushNamed("/Home");
                    },
                  ),
                  _buildDrawerTile(
                    icon: FontAwesomeIcons.newspaper,
                    title: "Citas",
                    isSelected: currentPage == "Citas",
                    onTap: () {
                      redirigirCita(context);
                    },
                  ),
                  _buildDrawerTile(
                    icon: FontAwesomeIcons.user,
                    title: "Perfil",
                    isSelected: currentPage == "Perfil",
                    onTap: () {
                      redirigir(context);
                    },
                  ),
                  _buildDrawerTile(
                    icon: FontAwesomeIcons.fileInvoice,
                    title: "Mis Test",
                    isSelected: currentPage == "Mis Test",
                    onTap: () {
                      if (currentPage != "Mis Test") {
                        Scaffold.of(context).closeDrawer();
                        Navigator.of(context).pushNamed("/testEvaluativo");
                      }
                    },
                  ),
                  _buildDrawerTile(
                    icon: FontAwesomeIcons.newspaper,
                    title: "Pagos",
                    isSelected: currentPage == "Pagos",
                    onTap: () {
                      if (currentPage != "Pagos") {
                        Navigator.pushNamed(context, '/pagos');
                      }
                    },
                  ),
                  _buildDrawerTile(
                    icon: FontAwesomeIcons.cog,
                    title: "Salir",
                    isSelected: currentPage == "Salir",
                    onTap: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.remove('token');
                      await prefs.remove('usuario_id');
                      await prefs.remove('tipo_usuario');
                      Navigator.of(context).pushNamed("/");
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.only(left: 8, right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                      height: 4,
                      thickness: 0,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0, left: 16, bottom: 8),
                      child: Text(
                        "DOCUMENTACION",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    _buildDrawerTile(
                      icon: FontAwesomeIcons.satellite,
                      title: "Mensaje",
                      isSelected: currentPage == "Mensaje",
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void redirigirCita(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tipoUsuario = prefs.getString('tipo_usuario') ?? '';
    
    if (tipoUsuario == '5') {
      Scaffold.of(context).closeDrawer();
      Navigator.of(context).pushNamed("/citas");
    } else if (tipoUsuario == '2') {
      Scaffold.of(context).closeDrawer();
      Navigator.of(context).pushNamed("/citasPsicologos");
    }
  }

  void redirigir(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tipoUsuario = prefs.getString('tipo_usuario') ?? '';
    if (tipoUsuario == '5') {
      Scaffold.of(context).closeDrawer();
      Navigator.of(context).pushNamed("/perfil");
    } else if (tipoUsuario == '2') {
      Navigator.pushNamed(context, '/perfilEspecialista');
    }
  }

  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isSelected ? Colors.black.withOpacity(0.07) : Colors.transparent,
              offset: const Offset(0, 0.5),
              spreadRadius: 3,
              blurRadius: 10,
            ),
          ],
          color: isSelected ? Color.fromARGB(255, 0, 188, 207) : Colors.transparent,
          borderRadius: const BorderRadius.all(Radius.circular(54)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.white,
            ),
            const SizedBox(width: 8.0),
            Text(
              title,
              style: TextStyle(
                letterSpacing: .3,
                fontSize: 15,
                fontWeight: FontWeight.w200,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
