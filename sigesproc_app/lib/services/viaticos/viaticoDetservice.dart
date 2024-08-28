import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/viaticos/viaticoDetViewModel.dart';
import '../apiservice.dart';

class ViaticosDetService {
  static Future<List<ViaticoDetViewModel>> listarViaticosDet() async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticosDet/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ViaticoDetViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los detalles de viáticos');
    }
  }

  static Future<ViaticoDetViewModel> buscarViaticoDet(int id) async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticosDet/Buscar/$id');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ViaticoDetViewModel.fromJson(data);
    } else {
      throw Exception('Error al buscar el detalle del viático');
    }
  }

  static Future<void> insertarViaticoDet(ViaticoDetViewModel viaticoDet) async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticosDet/Insertar');
    final response = await http.post(
      url,
      headers: {
        ...ApiService.getHttpHeaders(),
        "Content-Type": "application/json"
      },
      body: json.encode(viaticoDet.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al insertar el detalle del viático');
    }
  }

  static Future<void> actualizarViaticoDet(ViaticoDetViewModel viaticoDet) async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticosDet/Actualizar');
    final response = await http.put(
      url,
      headers: {
        ...ApiService.getHttpHeaders(),
        "Content-Type": "application/json"
      },
      body: json.encode(viaticoDet.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el detalle del viático');
    }
  }

  static Future<void> eliminarViaticoDet(int id) async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticosDet/Eliminar/$id');
    final response = await http.delete(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el detalle del viático');
    }
  }
}
