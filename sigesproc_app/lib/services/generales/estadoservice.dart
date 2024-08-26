import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/generales/estadoviewmodel.dart';
import '../apiservice.dart';

class EstadoService {
  static Future<List<EstadoViewModel>> listarEstadosPorPais(int paisId) async {
    final url = Uri.parse('${ApiService.apiUrl}/Estado/EstadoPorPais/$paisId');
    final response = await http.post(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => EstadoViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los estados para el país ID: $paisId');
    }
  }
}
