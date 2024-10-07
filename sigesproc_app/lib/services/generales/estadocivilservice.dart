import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/generales/estadocivilviewmodel.dart';
import '../apiservice.dart';

class EstadoCivilService {
  static Future<List<EstadoCivilViewModel>> listarEstadosCiviles() async {
    final url = Uri.parse('${ApiService.apiUrl}/EstadoCivil/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => EstadoCivilViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<EstadoCivilViewModel?> obtenerEstadoCivil(
      int estadocivilId) async {
    final List<EstadoCivilViewModel> estadosciviles =
        await listarEstadosCiviles();

    try {
      final estadocivil = estadosciviles.firstWhere((cliente) => cliente.civiId == estadocivilId);
      return estadocivil;
    } catch (e) {
      //print('Error: $e');
      throw Exception('Flete con ID $estadocivilId no encontrado');
    }
  }
}
