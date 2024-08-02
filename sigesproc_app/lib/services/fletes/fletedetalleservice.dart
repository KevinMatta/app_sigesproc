import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/fletes/fletedetalleviewmodel.dart';
import 'package:sigesproc_app/models/insumos/insumoporproveedorviewmodel.dart';
import '../apiservice.dart';

class FleteDetalleService {
  // static Future<List<InsumoPorProveedorViewModel>> listarInsumosPorProveedor() async {
  //   final url = Uri.parse('${ApiService.apiUrl}/InsumoPorProveedor/Listar');
  //   final response = await http.get(url, headers: ApiService.getHttpHeaders());

  //   if (response.statusCode == 200) {
  //     List<dynamic> data = json.decode(response.body);
  //     return data.map((json) => InsumoPorProveedorViewModel.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Error al cargar los datos');
  //   }
  // }
  static Future<List<InsumoPorProveedorViewModel>> listarInsumosPorProveedorPorBodega(int bodeId) async {
    final url = Uri.parse('${ApiService.apiUrl}/InsumoPorProveedor/Buscar/$bodeId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => InsumoPorProveedorViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }
}
