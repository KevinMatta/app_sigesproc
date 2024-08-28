import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/generales/ciudadviewmodel.dart';
import '../apiservice.dart';

class CiudadService {
  static Future<List<CiudadViewModel>> listarCiudadesPorEstado(int estadoId) async {
    final url = Uri.parse('${ApiService.apiUrl}/Ciudad/CiudadPorEstado/$estadoId');
    final response = await http.post(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => CiudadViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las ciudades para el estado ID: $estadoId');
    }
  }
}
