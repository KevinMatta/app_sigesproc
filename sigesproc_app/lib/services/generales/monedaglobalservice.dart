import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/generales/monedaglobalviewmodel.dart';
import '../apiservice.dart';

class MonedaGlobalService {

      static Future<MonedaGlobalViewModel> listarFormatoMoneda() async {
        final url = Uri.parse('${ApiService.apiUrl}/Moneda/Buscar/1');
        final response = await http.get(url, headers: ApiService.getHttpHeaders());

        if (response.statusCode == 200) {
          // Decodifica el JSON en un Map
          Map<String, dynamic> jsonResponse = json.decode(response.body);
          
          // Retorna el objeto MonedaGlobalViewModel desde el JSON
          return MonedaGlobalViewModel.fromJson(jsonResponse);
        } else {
          throw Exception('Error al cargar la moneda');
        }
      }


}
