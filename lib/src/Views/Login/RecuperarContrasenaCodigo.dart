import 'package:flutter/material.dart';

class RecuperarContrasenaCodigo extends StatefulWidget {
  const RecuperarContrasenaCodigo({Key? key}) : super(key: key);

  @override
  State<RecuperarContrasenaCodigo> createState() =>
      _RecuperarContrasenaCodigoState();
}

class _RecuperarContrasenaCodigoState extends State<RecuperarContrasenaCodigo> {
  final TextEditingController _emailController = TextEditingController();
  List<TextEditingController> _codigoControllers =
      List.generate(6, (index) => TextEditingController());
  bool _emailValido = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codigoControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;

    double containerWidth = screenWidth * 0.8;
    double containerHeight = screenHeight * 0.06;

    // MediaQuery de flutter
    if (screenWidth > 1300) {
      containerWidth = screenWidth * 0.6;
      containerHeight = screenHeight * 0.07;
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: screenHeight * 0.4,
                child: Image.asset(
                  'Psicologo.jpg',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 14),
              Container(
                margin: EdgeInsets.only(top: 20),
                width: 160,
                child: Image.asset(
                  'logo-text.png',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    color: Color.fromARGB(255, 56, 55, 58),
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: 35),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    6,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      width: (containerWidth - 60) / 6, // Ajuste del tamaño de TextField
                      child: TextField(
                        controller: _codigoControllers[index],
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          counter: Offstage(),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (value.isEmpty) {
                            if (index > 0) {
                              _codigoControllers[index - 1].clear();
                              _codigoControllers[index - 1].selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                  offset: _codigoControllers[index - 1].text.length,
                                ),
                              );
                              FocusScope.of(context).previousFocus();
                            }
                          } else {
                            if (index < 5) {
                              // Mover de cuadrito en cuadrito
                              FocusScope.of(context).nextFocus();
                            } else {
                              FocusScope.of(context).unfocus();
                            }
                          }
                        },
                        onSubmitted: (value) {
                          if (index > 0 && value.isEmpty) {
                            _codigoControllers[index - 1].clear();
                            _codigoControllers[index - 1].selection =
                                TextSelection.fromPosition(
                              TextPosition(
                                offset: _codigoControllers[index - 1].text.length,
                              ),
                            );
                            FocusScope.of(context).previousFocus();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
