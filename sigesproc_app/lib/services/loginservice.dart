import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/acceso/pantallaviewmodel.dart';
import 'package:sigesproc_app/models/acceso/usuarioviewmodel.dart';
import 'apiservice.dart';

class LoginService {

  // Método para listar todos los usuarios
  static Future<List<UsuarioViewModel>> listarUsuarios() async {
    final url = Uri.parse('${ApiService.apiUrl}/Usuario/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => UsuarioViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }


    static Future<UsuarioViewModel?> login(String usuario, String contra) async {
    const String apiUrl = ApiService.apiUrl;

    String url = "$apiUrl/Usuario/InicioSesion/$usuario/$contra";
    final response = await http.get(
      Uri.parse(url),
      headers: ApiService.getHttpHeaders(),
    );

    try {
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // Verifica si responseData es una lista vacía
        if (responseData is List && responseData.isEmpty) {
          // El usuario es incorrecto o no se encontró
          return null;
        }

        // Verifica si responseData es una lista con datos
        if (responseData is List && responseData.isNotEmpty) {
          final Map<String, dynamic> data = responseData[0];
          return UsuarioViewModel.fromJson(data);
        } else {
          throw Exception('Error inesperado en la estructura de la respuesta.');
        }
      } else if (response.statusCode == 401) { // 401 Unauthorized
        throw Exception('Usuario o contraseña incorrectos.');
      } else {
        throw Exception('Error al cargar los datos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }



  static Future<UsuarioViewModel?> reestablecer(int id, String correo, String usuario) async {
    const String apiUrl = ApiService.apiUrl;

    String url = "$apiUrl/Usuario/RestablecerContraWebb/$id/$correo/$usuario";
    final response = await http.get(
      Uri.parse(url),
      headers: ApiService.getHttpHeaders(),
    );

    try {
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // Verifica si responseData es una lista vacía
        if (responseData is List && responseData.isEmpty) {
          // El usuario es incorrecto o no se encontró
          return null;
        }

        // Verifica si responseData es una lista con datos
        if (responseData is Map && responseData.containsKey('data')) {
        final Map<String, dynamic> data = responseData['data'];
        return UsuarioViewModel.fromJson(data);
      } else {
        throw Exception('Error inesperado en la estructura de la respuesta.');
      }
      } else if (response.statusCode == 401) { // 401 Unauthorized
        return null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<UsuarioViewModel?> verificarCodigo(int id, String codigo) async {
  const String apiUrl = ApiService.apiUrl;

  String url = "$apiUrl/Usuario/VerificarCodigoReestablecerWeb/$id/$codigo";
  final response = await http.get(
    Uri.parse(url),
    headers: ApiService.getHttpHeaders(),
  );

  try {
    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);

      // Verifica si responseData es un Map y tiene la clave 'success'
      if (responseData is Map && responseData['success'] == true) {
        // Verifica si el 'data' dentro del responseData es un Map
        if (responseData['data'] is Map<String, dynamic>) {
          final Map<String, dynamic> data = responseData['data'];
          return UsuarioViewModel.fromJson(data);
        } else {
          throw Exception('Error inesperado en la estructura de la respuesta.');
        }
      } else {
        // Si success es false o la estructura es inesperada, retornamos null
        return null;
      }
    } else if (response.statusCode == 401) { // 401 Unauthorized
      return null;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}


static Future<UsuarioViewModel?> cambiarClave(UsuarioReestablecerViewModel usuario) async {
  const String apiUrl = ApiService.apiUrl;

  String url = "$apiUrl/Usuario/Reestablecer";
  final response = await http.put(
    Uri.parse(url),
    headers: {
    'Content-Type': 'application/json',
    ...ApiService.getHttpHeaders(),
  },  
    body: json.encode(usuario.toJson()),
  );

  try {
    if (response.statusCode == 200) {
      final dynamic responseData = json.decode(response.body);

      // Verifica si responseData es un Map y tiene la clave 'success'
      if (responseData is Map && responseData['success'] == true) {
        // Verifica si el 'data' dentro del responseData es un Map
        if (responseData['data'] is Map<String, dynamic>) {
          final Map<String, dynamic> data = responseData['data'];
          return UsuarioViewModel.fromJson(data);
        } else {
          throw Exception('Error inesperado en la estructura de la respuesta.');
        }
      } else {
        // Si success es false o la estructura es inesperada, retornamos null
        return null;
      }
    } else if (response.statusCode == 401) { // 401 Unauthorized
      return null;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}


      // Método para listar todas las pantallas por rol
    static Future<List<PantallaViewModel>> listarPantallasPorRol() async {
    final url = Uri.parse('${ApiService.apiUrl}/Pantalla/ListarPorRol');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => PantallaViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }




}
