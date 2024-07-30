import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/bienesraices/procesoventaviewmodel.dart';
import '../apiservice.dart';

class ProcesoVentaService {
  static Future<List<ProcesoVentaViewModel>> listarProcesosVenta() async {
    final url = Uri.parse('${ApiService.apiUrl}/ProcesoVenta/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ProcesoVentaViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<List<ProcesoVentaViewModel>> Buscar(int btrpId, int terrenobienraizId, int bienoterrenoid) async {
    final url = Uri.parse('${ApiService.apiUrl}/ProcesoVenta/Buscar/$btrpId/$terrenobienraizId/$bienoterrenoid');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      // imprime el JSON sin procesar
      // print('JSON Data: $data');

      List<ProcesoVentaViewModel> venta = data.map((json) => ProcesoVentaViewModel.fromJson(json)).toList();

      return venta;
    } else {
      throw Exception('Error al buscar venta');
    }
  }
}
