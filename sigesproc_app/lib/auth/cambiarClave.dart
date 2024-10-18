import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sigesproc_app/auth/cambiarClave.dart';
import 'package:sigesproc_app/auth/login.dart';
import 'package:sigesproc_app/models/acceso/usuarioviewmodel.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/inicio.dart';
import 'package:sigesproc_app/services/bloc/notifications_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/loginservice.dart';

class CambiarClave extends StatefulWidget {
  const CambiarClave({Key? key}) : super(key: key);

  @override
  _CambiarClaveState createState() => _CambiarClaveState();
}

class _CambiarClaveState extends State<CambiarClave> {
  final TextEditingController claveController = TextEditingController();
  final TextEditingController claveConfirmarController = TextEditingController();
  bool clavevacio = false;
  bool claveConfirmarvacio = false;
  bool incorrectos = false;


  Widget _cuadritoflotante() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 224, 223, 223),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 3),
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
                                          'Nueva Contraseña',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        usuariotextb(),    
                                        SizedBox(height: 20),
                                        confirmartextb(),                                      
                                        SizedBox(height: 22),
                                        botonCambiarClave(),
                                        botonCancelar()

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
      controller: claveController,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.key,
          color: Colors.black,
        ),
        labelText: 'Contraseña',
        labelStyle: TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.3),
        errorText: clavevacio
            ? 'Campo requerido'
            : incorrectos
                ? ''
                : null,
      ),
      obscureText: true,

    );
  }

Widget confirmartextb() {
    return TextField(
      controller: claveConfirmarController,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.key,
          color: Colors.black,
        ),
        labelText: 'Confirmar Contraseña',
        labelStyle: TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.3),
        errorText: claveConfirmarvacio
            ? 'Campo requerido'
            : incorrectos
                ? ''
                : null,
      ),
      obscureText: true,
    );
  }



  Future<void> _CambiarClave() async {
    String clave = claveController.text;
    String confirmarClave = claveConfirmarController.text;

    int usuarioReestablecer;
    
    //Inicializar la session
    final SharedPreferences pref = await SharedPreferences.getInstance();


    if (clave.isEmpty && confirmarClave.isEmpty) {
      setState(() {
        clavevacio = true;
        claveConfirmarvacio = true;
      });
      return;
    }

    if (clave.isEmpty) {
      setState(() {
        clavevacio = true;
      });
      return;
    }

      if (confirmarClave.isEmpty) {
      setState(() {
        claveConfirmarvacio = true;
      });
      return;
    }

      if (clave != confirmarClave) {

          ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("La contraseña no coincide."),),
    );      
      return;
    }

    final UsuarioViewModel? response;
        String idParse = pref.getString('usuarioReestablecerIdVerificado')!;
        usuarioReestablecer = int.parse(idParse);

                final usuarioModel = UsuarioReestablecerViewModel(
                usuaId: usuarioReestablecer,
                usuaUsuario: '',
                clave: clave,
                usuaEsAdministrador: true,
                rolId: 0,
                empleadoId:  0,
                usuaCreacion: usuarioReestablecer,
                usuaModificacion: usuarioReestablecer,
                );

          response = await LoginService.cambiarClave(usuarioModel);
       
          if(response != null)
          {
              Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Login(),
            ),
          );
          }  else {
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("No se pudo actualizar la contraseña.")),
          );
        }


  }


  Widget botonCambiarClave() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: _CambiarClave,
      child: Text(
        'Actualizar',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget botonCancelar() {
  return Container(
    margin: EdgeInsets.only(top: 10), // margen superior de 20 píxeles
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color.fromARGB(255, 224, 223, 223),
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        'Cancelar',
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
      ),
    ),
  );
}

}
