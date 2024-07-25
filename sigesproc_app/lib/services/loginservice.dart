import 'dart:convert';
import 'package:http/http.dart' as http;
import 'apiservice.dart';

class LoginService {
  final String apiUrl = ApiService.apiUrl;

  Future<Map<String, dynamic>?> login(String usuario, String contra) async {
    String url = "$apiUrl/Usuario/InicioSesion/$usuario,$contra";
    final response = await http.get(
      Uri.parse(url),
      headers: ApiService.getHttpHeaders(),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['data'] != null && (data['data'] as List).isNotEmpty) {
        return data['data'][0];
      }
    }
    return null;
  }
}
