import 'package:flutter/material.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'Models/usuarioo_viewmodel.dart';

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

  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('lib/assets/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              SizedBox(height: 10),
              SizedBox(height: 10),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}