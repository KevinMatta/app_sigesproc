import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/insumos/articuloviewmodel.dart';
import '../apiservice.dart';

class ArticuloService {
  static Future<List<ArticuloViewModel>> ListarArticulosPorCotizacion(
      int cotiId) async {
    final url = Uri.parse(
        '${ApiService.apiUrl}/Cotizacion/ListarArticulosPorCotizacion/$cotiId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print('Data processed: $data');

      return data.map((json) => ArticuloViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las articulos');
    }
  }
}
