import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/insumos/cotizacionviewmodel.dart';
import '../apiservice.dart';

class CotizacionService {
   static Future<List<CotizacionViewModel>> listarCotizaciones() async {
    final url = Uri.parse('${ApiService.apiUrl}/Cotizacion/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => CotizacionViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }
}
