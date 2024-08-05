import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import '../apiservice.dart';

class ProyectoService {
  static Future<List<ProyectoViewModel>> listarProyectos() async {
    final url = Uri.parse('${ApiService.apiUrl}/Proyecto/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ProyectoViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

   static Future<List<ProyectoViewModel>> Buscar(int proyId) async {
    final url = Uri.parse('${ApiService.apiUrl}/Proyecto/Buscar/$proyId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      // imprime el JSON sin procesar
      // print('JSON Data: $data');

      List<ProyectoViewModel> venta = data.map((json) => ProyectoViewModel.fromJson(json)).toList();

      return venta;
    } else {
      throw Exception('Error al buscar proyecto');
    }
  }
}
