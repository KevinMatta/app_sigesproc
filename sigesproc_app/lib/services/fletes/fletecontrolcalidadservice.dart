import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/fletes/fletecontrolcalidadviewmodel.dart';
import '../apiservice.dart';

class FleteControlCalidadService {
 
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

  static Future<bool> insertarIncidencia(FleteControlCalidadViewModel modelo) async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteControlCalidad/Insertar');
    final response = await http.post(
      url,
      headers: ApiService.getHttpHeaders(),
      body: json.encode(modelo.toJson()),
    );

    print('Response status insertar incidencia: ${response.statusCode}');
    print('Response body insertar incidencia: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      throw Exception('Error al insertar la incidencia');
    }
  }

  static Future<bool> actualizarIncidencia(FleteControlCalidadViewModel modelo) async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteControlCalidad/Actualizar');
    final response = await http.put(
      url,
      headers: ApiService.getHttpHeaders(),
      body: json.encode(modelo.toJson()),
    );

    print('Response status actualizar incidencia: ${response.statusCode}');
    print('Response body actualizar incidencia: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al actualizar la incidencia');
    }
  }

static Future<bool> eliminarIncidencia(int id) async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteControlCalidad/Eliminar?id=$id');
    final response = await http.delete(url, headers: ApiService.getHttpHeaders());

    print('Response status eliminar incidencia: ${response.statusCode}');
    print('Response body eliminar incidencia: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al eliminar la incidencia');
    }
  }
}


