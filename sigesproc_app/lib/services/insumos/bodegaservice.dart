import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/insumos/bodegaviewmodel.dart';
import '../apiservice.dart';

class BodegaService {
  static Future<List<BodegaViewModel>> listarBodegas() async {
    final url = Uri.parse('${ApiService.apiUrl}/Bodega/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => BodegaViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }
}