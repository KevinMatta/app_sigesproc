import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
import 'package:sigesproc_app/auth/reestablecer.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/inicio.dart';
import 'package:sigesproc_app/services/bloc/notifications_bloc.dart';
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

  Widget _cuadritoflotante() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 8),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
   
    context.read<NotificationsBloc>().requestPermision();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Positioned(
                  top: 50,
                  left: 30,
                  child: _cuadritoflotante(),
                ),
                Positioned(
                  bottom: 110,
                  right: 30,
                  child: _cuadritoflotante(),
                ),
                Positioned(
                  top: 10,
                  right: 70,
                  child: _cuadritoflotante(),
                ),
                Positioned(
                  bottom: 80,
                  left: 70,
                  child: _cuadritoflotante(),
                ),
                Positioned(
                  top: 150,
                  right: 20,
                  child: _cuadritoflotante(),
                ),
                Positioned(
                  top: 250,
                  left: 10,
                  child: _cuadritoflotante(),
                ),
                Positioned(
                  top: 350,
                  right: 10,
                  child: _cuadritoflotante(),
                ),
                Positioned(
                  top: 550,
                  left: 20,
                  child: _cuadritoflotante(),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Column(
                      mainAxisSize: MainAxisSize
                          .min, // Cambiar el comportamiento del eje principal
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Card(
                                  color: Color.fromARGB(224, 255, 255, 255),
                                  elevation: 5,
                                  child: Padding(
                                    padding: const EdgeInsets.all(30.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                            height: 50), // Reducir el tamaño
                                        Text(
                                          'Inicio de sesión',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        usuariotextb(),
                                        SizedBox(height: 10),
                                        contratextb(),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const Reestablecer(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              '¿Olvidaste tu contraseña?',
                                              style: TextStyle(
                                                color: Colors.black,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        botonLogin()
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: -90, // Ajuste para centrar el logo
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Card(
                                    color: Colors.black,
                                    elevation: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 40.0),
                                      child: Image.asset(
                                        'lib/assets/logo-sigesproc.png',
                                        height: 150, // Tamaño del logo
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget usuariotextb() {
    return TextField(
      controller: usuariooController,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.person,
          color: Colors.black,
        ),
        labelText: 'Usuario',
        labelStyle: TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.3),
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

  Widget contratextb() {
    return TextField(
      controller: contraController,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.key,
          color: Colors.black,
        ),
        labelText: 'Contraseña',
        labelStyle: TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.3),
        errorText: contravacia
            ? 'Campo requerido'
            : incorrectos
                ? 'Usuario o contraseña son incorrectos'
                : null,
      ),
      obscureText: true,
    );
  }

  Widget botonLogin() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
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
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
