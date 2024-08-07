import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/proyectos/actividadesporetapaviewmodel.dart';
import '../apiservice.dart';

class ActividadPorEtapaService {
  static Future<List<ActividadPorEtapaViewModel>> listarActividadesPorEtapa() async {
    final url = Uri.parse('${ApiService.apiUrl}/ActividadPorEtapa/ListarActividad');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => ActividadPorEtapaViewModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<List<ActividadPorEtapaViewModel>> obtenerActividadesPorProyecto(int proyId) async {
    final List<ActividadPorEtapaViewModel> actividades = await listarActividadesPorEtapa();

    return actividades.where((actividad) => actividad.proyId == proyId).toList();
  }
}
