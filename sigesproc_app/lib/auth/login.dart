import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
import 'package:sigesproc_app/auth/reestablecer.dart';
import 'package:sigesproc_app/screens/inicio.dart';
import 'package:sigesproc_app/screens/menu.dart';
// import '../services/loginservice.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController usuariooController = TextEditingController();
  final TextEditingController contraController = TextEditingController();
  bool usuariovacio = false;
  bool contravacia = false;
  bool incorrectos = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 325,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('lib/assets/fondoarriba.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('lib/assets/fondoabajo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                child: Image.asset(
                  'lib/assets/logo-sigesproc.png',
                  height: 160,
                ),
              ),
              Positioned(
                bottom: 50,
                right: 20,
                child: _buildLoginButton(),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 100),
                      Text(
                        'Inicio de sesión',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildusuariooField(),
                      SizedBox(height: 10),
                      _buildcontraField(),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Reestablecer(),
                              ),
                            );
                          },
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              color: Colors
                                  .black, 
                              decoration:
                                  TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildusuariooField() {
    return TextField(
      controller: usuariooController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.person),
        labelText: 'Usuario',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        errorText: usuariovacio
            ? 'Campo requerido'
            : incorrectos
                ? ''
                : null,
      ),
    );
  }

  Future<void> _login() async {
    // String usuario = usuariooController.text;
    // String contra = contraController.text;

    // //Inicializar la session
    // final SharedPreferences pref = await SharedPreferences.getInstance();

    // if (usuario.isEmpty && contra.isEmpty) {
    //   setState(() {
    //     usuariovacio = true;
    //     contravacia = true;
    //   });
    //   return;
    // }

    // if (usuario.isEmpty) {
    //   setState(() {
    //     usuariovacio = true;
    //     contravacia = false;
    //   });
    //   return;
    // }

    // if (contra.isEmpty) {
    //   setState(() {
    //     contravacia = true;
    //     usuariovacio = false;
    //   });
    //   return;
    // }

    // final LoginService loginService = LoginService();
    // final response = await loginService.login(usuario, contra);

    // if (response != null) {
    //   await pref.setString('person', response['perso_Nombre']);
    //   await pref.setString('IDRegistro', response['regi_Id'].toString());
    //   await pref.setString('EsAdmin', response['usua_EsAdmin'].toString());

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Inicio(), 
        ),
      );
    // } else {
    //   setState(() {
    //     usuariooController.clear();
    //     contraController.clear();
    //     incorrectos = true;
    //   });
    // }
  }

  Widget _buildcontraField() {
    return TextField(
      controller: contraController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.lock),
        labelText: 'Contraseña',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        errorText: contravacia
            ? 'Campo requerido'
            : incorrectos
                ? 'Usuario o contraseña son incorrectos'
                : null,
      ),
      obscureText: true,
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF303030),
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: _login,
      child: Text(
        'Entrar',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
