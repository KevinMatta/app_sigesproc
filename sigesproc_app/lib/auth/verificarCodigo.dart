import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigesproc_app/auth/cambiarClave.dart';

import 'package:sigesproc_app/auth/verificarCodigo.dart';
import 'package:sigesproc_app/models/acceso/usuarioviewmodel.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/inicio.dart';
import 'package:sigesproc_app/services/bloc/notifications_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/loginservice.dart';

class Verificar extends StatefulWidget {
  const Verificar({Key? key}) : super(key: key);

  @override
  _VerificarState createState() => _VerificarState();
}

class _VerificarState extends State<Verificar> {
  final TextEditingController codigoController = TextEditingController();
  bool codigovacio = false;
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
                                          'Verificar Código',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        usuariotextb(),                                        
                                        SizedBox(height: 22),
                                        botonVerificar(),
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
      controller: codigoController,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.code,
          color: Colors.black,
        ),
        labelText: 'Código',
        labelStyle: TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.3),
        errorText: codigovacio
            ? 'Campo requerido'
            : incorrectos
                ? ''
                : null,
      ),
    );
  }




  Future<void> _Verificar() async {
    String codigo = codigoController.text;
    int idReestablecer;
    
    //Inicializar la session
    final SharedPreferences pref = await SharedPreferences.getInstance();

    if (codigo.isEmpty) {
      setState(() {
        codigovacio = true;
      });
      return;
    }

        final UsuarioViewModel? response;
        String idParse = pref.getString('usuarioReestablecerId')!;
        idReestablecer = int.parse(idParse);


          response = await LoginService.verificarCodigo(idReestablecer, codigo);
       
          if(response != null)
          {
          await pref.setString('usuarioReestablecerIdVerificado', idReestablecer.toString());


              Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CambiarClave(),
            ),
          );
          }  else {
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Código Inválido.")),
          );
        }


  }


  Widget botonVerificar() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: _Verificar,
      child: Text(
        'Verificar Código',
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
