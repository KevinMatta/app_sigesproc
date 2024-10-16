import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/planillas/viaticoencabezadoviewmodel.dart';
import '../apiservice.dart';

class ViaticoEncabezadoService {
  static Future<List<ViaticoEncabezadoViewModel>> listarViaticosEncabezados() async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticoEncabezado/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ViaticoEncabezadoViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }
}
