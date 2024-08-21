import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/fletes/fletecontrolcalidadviewmodel.dart';
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import '../apiservice.dart';

class FleteControlCalidadService {
  static Future<List<FleteEncabezadoViewModel>> listarFletesEncabezado() async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteEncabezado/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => FleteEncabezadoViewModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<void> insertarControlCalidad(
      FleteControlCalidadViewModel detalle) async {
    final url = Uri.parse('${ApiService.apiUrl}/ControlCalidad/Insertar');
    final body = jsonEncode(detalle.toJson());
    final headers = {
      'Content-Type': 'application/json',
      'XApiKey': ApiService.apiKey,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Error al insertar el detalle del flete');
    }
  }

  static Future<List<FleteControlCalidadViewModel>> buscarIncidencias(
      int flenId) async {
    final url = Uri.parse(
        '${ApiService.apiUrl}/FleteControlCalidad/BuscarIncidencias/$flenId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    print('Response status buscar cont: ${response.statusCode}');
    print('Response body buscar cont: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => FleteControlCalidadViewModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }
}
