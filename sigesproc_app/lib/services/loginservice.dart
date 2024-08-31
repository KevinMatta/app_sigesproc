import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/acceso/pantallaviewmodel.dart';
import 'package:sigesproc_app/models/acceso/usuarioviewmodel.dart';
import 'apiservice.dart';

class LoginService {


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
