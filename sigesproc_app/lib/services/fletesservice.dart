import 'dart:convert';
import 'package:http/http.dart' as http;
import 'apiservice.dart';

class FleteService {
  static Future<List<dynamic>> listarFletes() async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteEncabezado/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al cargar los datos de Fletes');
    }
  }
}
