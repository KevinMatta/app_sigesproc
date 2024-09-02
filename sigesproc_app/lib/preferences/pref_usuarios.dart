import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario{
 
  static late SharedPreferences _prefs;


  static Future init() async{
    _prefs = await SharedPreferences.getInstance();
  }

  String get ultimaPagina{
    return _prefs.getString('ultimaPagina') ?? 'Login' ;
  }

  set ultimaPagina(String value){
    _prefs.setString('ultimaPagina', value);
  }

  String get ultimouid{
    return _prefs.getString('ultimouid') ?? '' ;
  }

  set ultimouid(String value){
    _prefs.setString('ultimouid', value);
  }

  String get token{
    return _prefs.getString('token') ?? '';
  }

  set token(String value){
    _prefs.setString('token', value);
  }

    set userId(String id) {
    _prefs.setString('userId', id);
  }

  String get userId {
    return _prefs.getString('userId') ?? '';
  }
  
}