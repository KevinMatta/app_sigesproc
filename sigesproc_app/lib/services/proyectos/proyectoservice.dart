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

   static Future<ProyectoViewModel?> obtenerProyecto(int proyId) async {
    final List<ProyectoViewModel> proyectos = await listarProyectos();

    try {
      return proyectos.firstWhere((proyecto) => proyecto.proyId == proyId);
    } catch (e) {
      throw Exception('Flete con ID $proyId no encontrado');
    }
  }
}
