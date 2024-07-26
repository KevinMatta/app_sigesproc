import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import '../apiservice.dart';

class FleteEncabezadoService {
  static Future<List<FleteEncabezadoViewModel>> listarFletesEncabezado() async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteEncabezado/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => FleteEncabezadoViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<bool> insertarFlete(FleteEncabezadoViewModel flete) async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteEncabezado/Insertar');
    final response = await http.post(
      url,
      headers: ApiService.getHttpHeaders(),
      body: jsonEncode(flete.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al insertar el flete');
    }
  }
}
