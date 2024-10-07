import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/generales/paisviewmodel.dart';
import '../apiservice.dart';

class PaisService {
  static Future<List<PaisViewModel>> listarPaises() async {
  final url = Uri.parse('${ApiService.apiUrl}/Pais/Listar');
  final response = await http.get(url, headers: ApiService.getHttpHeaders());

  if (response.statusCode == 200) {
    Map<String, dynamic> jsonResponse = json.decode(response.body);

    // Asegúrate de acceder a la lista correcta dentro del JSON
    List<dynamic> data = jsonResponse['data']; // Ajusta 'data' según la estructura de tu API

    return data.map((json) => PaisViewModel.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar los datos');
  }
}


  static Future<PaisViewModel?> obtenerPais(
      int paisId) async {
    final List<PaisViewModel> paises =
        await listarPaises();

    try {
      final pais = paises.firstWhere((cliente) => cliente.paisId == paisId);
      return pais;
    } catch (e) {
      //print('Error: $e');
      throw Exception('Flete con ID $paisId no encontrado');
    }
  }
}
