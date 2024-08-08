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
      return data
          .map((json) => FleteEncabezadoViewModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<int?> insertarFlete(FleteEncabezadoViewModel flete) async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteEncabezado/Insertar');
    final body = jsonEncode(flete.toJson());
    final headers = {
      'Content-Type': 'application/json',
      'XApiKey': ApiService.apiKey,
    };

    // print('Body: $body');

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['data']['codeStatus'];
    } else {
      return null;
    }
  }

   static Future<FleteEncabezadoViewModel?> obtenerFleteDetalle(int flenId) async {
    final List<FleteEncabezadoViewModel> fletes = await listarFletesEncabezado();

    try {
      return fletes.firstWhere((flete) => flete.flenId == flenId);
    } catch (e) {
      throw Exception('Flete con ID $flenId no encontrado');
    }
  }

  static Future<void> Eliminar(int flenId) async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteEncabezado/Eliminar/$flenId');
    final response = await http.delete(url, headers: ApiService.getHttpHeaders());
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el proceso de venta');
    }
  }
}
