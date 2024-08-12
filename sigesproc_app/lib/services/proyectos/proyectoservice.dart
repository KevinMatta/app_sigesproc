import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import '../apiservice.dart';

class ProyectoService {
  // Método para listar todos los proyectos
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

  // Método para obtener un proyecto específico por ID
  static Future<ProyectoViewModel?> obtenerProyecto(int proyId) async {
    final List<ProyectoViewModel> proyectos = await listarProyectos();

    try {
      return proyectos.firstWhere((proyecto) => proyecto.proyId == proyId);
    } catch (e) {
      throw Exception('Proyecto con ID $proyId no encontrado');
    }
  }

  // Método para eliminar un proyecto por ID
  static Future<void> eliminarProyecto(int id) async {
    final url = Uri.parse('${ApiService.apiUrl}/Proyecto/Eliminar');
    final response = await http.put(
      url,
      headers: ApiService.getHttpHeaders(),
      body: json.encode(id),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el proyecto');
    }
  }

  // Método para insertar un nuevo proyecto
  static Future<ProyectoViewModel> insertarProyecto(ProyectoViewModel proyecto) async {
    final url = Uri.parse('${ApiService.apiUrl}/Proyecto/Insertar');
    final response = await http.post(
      url,
      headers: ApiService.getHttpHeaders(),
      body: json.encode(proyecto.toJson()),
    );

    if (response.statusCode == 200) {
      return ProyectoViewModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al insertar el proyecto');
    }
  }

  // Método para actualizar un proyecto existente
  static Future<ProyectoViewModel> actualizarProyecto(ProyectoViewModel proyecto) async {
    final url = Uri.parse('${ApiService.apiUrl}/Proyecto/Actualizar');
    final response = await http.put(
      url,
      headers: ApiService.getHttpHeaders(),
      body: json.encode(proyecto.toJson()),
    );

    if (response.statusCode == 200) {
      return ProyectoViewModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar el proyecto');
    }
  }
}
