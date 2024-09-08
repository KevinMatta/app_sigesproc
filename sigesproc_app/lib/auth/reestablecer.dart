import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sigesproc_app/auth/reestablecer.dart';
import 'package:sigesproc_app/auth/verificarCodigo.dart';
import 'package:sigesproc_app/models/acceso/usuarioviewmodel.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/inicio.dart';
import 'package:sigesproc_app/services/bloc/notifications_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/loginservice.dart';

class Reestablecer extends StatefulWidget {
  const Reestablecer({Key? key}) : super(key: key);

  @override
  _ReestablecerState createState() => _ReestablecerState();
}

class _ReestablecerState extends State<Reestablecer> {
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
                                          'Reestablecer Contraseña',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        usuariotextb(),                                        
                                        SizedBox(height: 22),
                                        botonReestablecer(),
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




  Future<void> _Reestablecer() async {
    String usuario = usuariooController.text;
    
    //Inicializar la session
    final SharedPreferences pref = await SharedPreferences.getInstance();


    if (usuario.isEmpty) {
      setState(() {
        usuariovacio = true;
      });
      return;
    }


    final UsuarioViewModel? response;

    // Obtener la lista de usuarios del Future
    Future<List<UsuarioViewModel>>? _usuariosFuture = LoginService.listarUsuarios();
    
    // Espera a que se completen los datos del Future
    List<UsuarioViewModel>? usuarios = await _usuariosFuture;
    
    // Verificar si la lista no es nula y contiene datos
    if (usuarios != null && usuarios.isNotEmpty) {
        // Variables para almacenar usuaId y correo
        int? usuaId;
        String? correo;
        
        // Iterar sobre la lista de usuarios
        for (var usuarioItem in usuarios) {
            if (usuarioItem.usuaUsuario == usuario) {
                usuaId = usuarioItem.usuaId;
                correo = usuarioItem.correoEmpleado;
                
                print("Usuario encontrado: ID = $usuaId, Correo = $correo");
                
                break; // Romper el bucle si encuentras el usuario
            }
        }
        // Verificar si se encontraron los datos
        if (usuaId != null && correo != null) {
          response = await LoginService.reestablecer(usuaId, correo);
          await pref.setString('usuarioReestablecerId', usuaId.toString());
       
          if(response != null)
          {

              Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Verificar(),
            ),
          );
          }

        } else {
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Usuario Inválido.")),
    );
        }
    } else {
        print("No se encontraron usuarios o la lista está vacía.");
    }


  // try {
  //     final UsuarioViewModel? response = await LoginService.reestablecer(48, '111');

  //     if (response != null) {
  //       await pref.setString('emplNombre', response.nombreEmpleado ?? '');
  //       await pref.setString('emplId', response.empleadoId?.toString() ?? '');
  //       await pref.setString('usuaId', response.usuaId?.toString() ?? '');
  //       await pref.setString('usuaUsuario', response.usuaUsuario?.toString() ?? '');
  //       await pref.setString('EsAdmin', response.usuaEsAdministrador?.toString() ?? '');

  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => Inicio(),
  //         ),
  //       );
  //     } else {
  //       setState(() {
  //         usuariooController.clear();
  //         incorrectos = true;
  //       });
  //     }      
  //       } catch (e) {
  //   // Muestra el mensaje de error al usuario
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("Usuario no encontrado."),
  //              backgroundColor: Colors.red,),
  //   );
  // }


  }


  Widget botonReestablecer() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: _Reestablecer,
      child: Text(
        'Enviar Código',
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }


  Widget botonCancelar() {
    return ElevatedButton(
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
    );
  }
}
