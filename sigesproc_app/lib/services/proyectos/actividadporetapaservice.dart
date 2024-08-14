import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/proyectos/actividadporetapaviewmodel.dart';
import '../apiservice.dart';

class ActividadesPorEtapaService {
  // static Future<List<ActividadesPorEtapaViewModel>> listarActividadesPorEtapa() async {
  //   final url = Uri.parse('${ApiService.apiUrl}/ActividadPorEtapa/ListarActividad');
  //   final response = await http.get(url, headers: ApiService.getHttpHeaders());

  //   if (response.statusCode == 200) {
  //     List<dynamic> data = json.decode(response.body);
  //     return data
  //         .map((json) => ActividadesPorEtapaViewModel.fromJson(json))
  //         .toList();
  //   } else {
  //     throw Exception('Error al cargar los datos');
  //   }
  // }

  // static Future<List<ActividadesPorEtapaViewModel>> obtenerActividadesPorProyecto(int proyId) async {
  //   final List<ActividadesPorEtapaViewModel> actividades = await listarActividadesPorEtapa();

  //   return actividades.where((actividad) => actividad.proyId == proyId).toList();
  // }
  
  static Future<List<ActividadesPorEtapaViewModel>> listarActividadPorEtapa(int id) async {
  final url = Uri.parse('${ApiService.apiUrl}/ActividadPorEtapa/Listar/$id');
  final response = await http.get(
    url,
    headers: {
      // 'Content-Type': 'application/json', 
      ...ApiService.getHttpHeaders(), 
    },
    // body: json.encode(id), // Se envía el id en el cuerpo de la solicitud
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseData = json.decode(response.body);

    if (responseData['success'] == true && responseData['code'] == 200) {
      List<dynamic> data = responseData['data'];
      return data
          .map((json) => ActividadesPorEtapaViewModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error en la operación: ${responseData['message']}');
    }
  } else {
    throw Exception('Error al cargar los datos');
  }
}





  // Método para eliminar una actividad por etapa
  static Future<void> eliminarActividadPorEtapa(int id) async {
    final url = Uri.parse('${ApiService.apiUrl}/ActividadPorEtapa/Eliminar/$id');
    final response = await http.delete(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la actividad por etapa');
    }
  }

  // Método para insertar una nueva actividad por etapa
  static Future<ActividadesPorEtapaViewModel> insertarActividadPorEtapa(ActividadesPorEtapaViewModel actividad) async {
    final url = Uri.parse('${ApiService.apiUrl}/ActividadPorEtapa/Insertar');
    final response = await http.post(
      url,
      headers: ApiService.getHttpHeaders(),
      body: json.encode(actividad.toJson()),
    );

    if (response.statusCode == 200) {
      return ActividadesPorEtapaViewModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al insertar la actividad por etapa');
    }
  }

  // Método para actualizar una actividad por etapa existente
  static Future<ActividadesPorEtapaViewModel> actualizarActividadPorEtapa(ActividadesPorEtapaViewModel actividad) async {
    final url = Uri.parse('${ApiService.apiUrl}/ActividadPorEtapa/Actualizar');
    final response = await http.put(
      url,
      headers: ApiService.getHttpHeaders(),
      body: json.encode(actividad.toJson()),
    );

    if (response.statusCode == 200) {
      return ActividadesPorEtapaViewModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar la actividad por etapa');
    }
  }

}
