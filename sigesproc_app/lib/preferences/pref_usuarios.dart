import 'package:shared_preferences/shared_preferences.dart';

class PreferenciasUsuario {
  static late SharedPreferences _prefs;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String get ultimaPagina {
    return _prefs.getString('ultimaPagina') ?? 'Login';
  }

  set ultimaPagina(String value) {
    _prefs.setString('ultimaPagina', value);
  }

  String get ultimouid {
    return _prefs.getString('ultimouid') ?? '';
  }

  set ultimouid(String value) {
    _prefs.setString('ultimouid', value);
  }

  String get token {
    return _prefs.getString('token') ?? '';
  }

  set token(String value) {
    _prefs.setString('token', value);
  }

  set userId(String id) {
    _prefs.setString('userId', id);
  }

  String get userId {
    return _prefs.getString('userId') ?? '';
  }

  set usernombre(String nombre) {
    _prefs.setString('usernombre', nombre);
  }

  String get usernombre {
    return _prefs.getString('usernombre') ?? '';
  }

  set userCorreo(String correo) {
    _prefs.setString('userCorreo', correo);
  }

  String get userCorreo {
    return _prefs.getString('userCorreo') ?? 'e';
  }

  set userTelefono(String telefono) {
    _prefs.setString('userTelefono', telefono);
  }

  String get userTelefono {
    return _prefs.getString('userTelefono') ?? '';
  }

  set userCargo(String cargo) {
    _prefs.setString('userCargo', cargo);
  }

  String get userCargo {
    return _prefs.getString('userCargo') ?? '';
  }

  set userImagenEmpleado(String imagen) {
    _prefs.setString('userImagenEmpleado', imagen);
  }

  String get userImagenEmpleado {
    return _prefs.getString('userImagenEmpleado') ?? '';
  }

    set userRol(String rol) {
    _prefs.setString('userRol', rol);
  }

  String get userRol {
    return _prefs.getString('userRol') ?? '';
  }

      set nombreusuario(String usuario) {
    _prefs.setString('usuario', usuario);
  }

  String get nombreusuario {
    return _prefs.getString('usuario') ?? '';
  }
}
