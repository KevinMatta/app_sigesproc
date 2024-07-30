import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/insumos/cotizacionviewmodel.dart';
import '../apiservice.dart';

class CotizacionService {
  static Future<List<CotizacionViewModel>> listarCotizacionesPorProveedor(int provId) async {
    final url = Uri.parse('${ApiService.apiUrl}/Cotizacion/ListarPorProveedor/$provId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => CotizacionViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las cotizaciones');
    }
  }
}
