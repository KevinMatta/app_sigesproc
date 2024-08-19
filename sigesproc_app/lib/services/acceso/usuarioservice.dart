import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/acceso/usuarioviewmodel.dart';
import '../apiservice.dart';

class UsuarioService {
  
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


static Future<UsuarioViewModel> Buscar(int usuaId) async {
  final url = Uri.parse('${ApiService.apiUrl}/Usuario/Buscar/$usuaId');
  final response = await http.get(url, headers: ApiService.getHttpHeaders());

  if (response.statusCode == 200) {
    print("Respuesta del servidor: ${response.body}");
    Map<String, dynamic> jsonResponse = json.decode(response.body);

    if (jsonResponse['data'] != null) {
      Map<String, dynamic> data = jsonResponse['data'];
      return UsuarioViewModel.fromJson(data);
    } else {
      throw Exception('No se encontraron datos en la respuesta.');
    }
  } else {
    throw Exception('Error al buscar usuario');
  }
}



static Future<int?> Restablecerflutter(int usuaId, String clave, String nuevaclave) async {
  final url = Uri.parse('${ApiService.apiUrl}/Usuario/RestablecerFlutter/$usuaId/$clave/$nuevaclave');
  final response = await http.get(url, headers: ApiService.getHttpHeaders());

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse['code'] == 200) {
      return jsonResponse['data']['codeStatus'];
    } else {
      print("Operación fallida: ${jsonResponse['message']}");
      return null;
    }
  } else {
    print("Error en la solicitud: ${response.statusCode}");
    return null;
  }
}


  static Future<int?> Restablecercorreo(int usuaId, String correo) async {
  final url = Uri.parse('${ApiService.apiUrl}/Usuario/RestablecerCorreo/$usuaId/$correo');
  final response = await http.get(url, headers: ApiService.getHttpHeaders());

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse['code'] == 200) {
      return jsonResponse['data']['codeStatus'];
    } else {
      print("Operación fallida: ${jsonResponse['message']}");
      return null;
    }
  } else {
    print("Error en la solicitud: ${response.statusCode}");
    return null;
  }
}





}
