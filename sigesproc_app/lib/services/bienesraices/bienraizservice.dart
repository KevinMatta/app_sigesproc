import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/bienesraices/bienraizviewmodel.dart';
import '../apiservice.dart';

class BienRaizService {
  static Future<List<BienRaizViewModel>> listarBienesRaices() async {
    final url = Uri.parse('${ApiService.apiUrl}/BienRaiz/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => BienRaizViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }
}
