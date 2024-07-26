import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/insumos/insumoviewmodel.dart';
import '../apiservice.dart';

class InsumoService {
  static Future<List<InsumoViewModel>> listarInsumos() async {
    final url = Uri.parse('${ApiService.apiUrl}/Insumo/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => InsumoViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los insumos');
    }
  }
}
