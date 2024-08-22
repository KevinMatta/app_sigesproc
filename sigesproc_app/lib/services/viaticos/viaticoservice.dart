import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/viaticos/viaticoViewModel.dart';
import '../apiservice.dart';

class viaticoservice {
  static Future<List<viaticosViewModel>>
      listarViaticosPorUsuario(int usuaId) async {
    final url =
        Uri.parse('${ApiService.apiUrl}/ViaticosEnc/Listar?$usuaId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());
    // print('Response status insumos: ${response.statusCode}');
    // print('Response body nsumos: ${response.body}');
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => viaticosViewModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

}