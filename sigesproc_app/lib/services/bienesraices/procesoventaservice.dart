import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/bienesraices/procesoventaviewmodel.dart';
import 'package:sigesproc_app/models/bienesraices/terrenoviewmodel.dart';
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

  static Future<void> Eliminar(int btrpId) async {
    final url = Uri.parse('${ApiService.apiUrl}/ProcesoVenta/Eliminar?id=$btrpId');
    final response = await http.delete(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el proceso de venta');
    }
  }

   static Future<void> venderProcesoVenta(ProcesoVentaViewModel venta) async {
    final url = Uri.parse('${ApiService.apiUrl}/ProcesoVenta/Vender');
    final response = await http.put(
      url,
      headers: {
        ...ApiService.getHttpHeaders(),
        "Content-Type": "application/json"
      },
      body: json.encode({
        'btrp_Id': venta.btrpId,
        'btrp_PrecioVenta_Final': venta.btrpPrecioVentaFinal,
        'btrp_FechaVendida': venta.btrpFechaVendida?.toIso8601String(),
        'clie_Id': venta.clieId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al vender la propiedad');
    }
  }

    static Future<List<TerrenosViewModel>> listarTerrenos() async {
    final url = Uri.parse('${ApiService.apiUrl}/Terreno/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => TerrenosViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }
}
