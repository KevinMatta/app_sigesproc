import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/proyectos/etapaporproyectoviewmodel.dart';
import '../apiservice.dart';

class EtapaPorProyectoService {
  static Future<List<EtapaPorProyectoViewModel>> listarEtapasPorProyecto(int id) async {
    final url = Uri.parse('${ApiService.apiUrl}/EtapaPorProyecto/Listar/$id');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => EtapaPorProyectoViewModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<EtapaPorProyectoViewModel> insertarEtapaPorProyecto(EtapaPorProyectoViewModel etapa) async {
    final url = Uri.parse('${ApiService.apiUrl}/EtapaPorProyecto/Insertar');
    final response = await http.post(
      url,
      headers: ApiService.getHttpHeaders(),
      body: json.encode(etapa.toJson()),
    );

    if (response.statusCode == 200) {
      return EtapaPorProyectoViewModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al insertar la etapa por proyecto');
    }
  }

  static Future<EtapaPorProyectoViewModel> actualizarEtapaPorProyecto(EtapaPorProyectoViewModel etapa) async {
    final url = Uri.parse('${ApiService.apiUrl}/EtapaPorProyecto/Actualizar');
    final response = await http.put(
      url,
      headers: ApiService.getHttpHeaders(),
      body: json.encode(etapa.toJson()),
    );

    if (response.statusCode == 200) {
      return EtapaPorProyectoViewModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar la etapa por proyecto');
    }
  }

  static Future<void> eliminarEtapaPorProyecto(int id) async {
    final url = Uri.parse('${ApiService.apiUrl}/EtapaPorProyecto/Eliminar/$id');
    final response = await http.delete(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la etapa por proyecto');
    }
  }
}
