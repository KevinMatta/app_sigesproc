import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/fletes/fletedetalleviewmodel.dart';
import 'package:sigesproc_app/models/insumos/insumoporproveedorviewmodel.dart';
import '../apiservice.dart';

class FleteDetalleService {
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

  static Future<void> insertarFleteDetalle(FleteDetalleViewModel detalle) async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteDetalle/Insertar');
    final body = jsonEncode(detalle.toJson());
    final headers = {
      'Content-Type': 'application/json',
      'XApiKey': ApiService.apiKey,
    };


    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );


    if (response.statusCode != 200) {
      throw Exception('Error al insertar el detalle del flete');
    }
  }

  static Future<void> editarFleteDetalle(FleteDetalleViewModel detalle) async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteDetalle/Actualizar');
    final body = jsonEncode(detalle.toJson());
    final headers = {
      'Content-Type': 'application/json',
      'XApiKey': ApiService.apiKey,
    };


    final response = await http.put(
      url,
      headers: headers,
      body: body,
    );


    if (response.statusCode != 200) {
      throw Exception('Error al editar el detalle del flete');
    }
  }

  static Future<List<FleteDetalleViewModel>> Buscar(int flenId) async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteDetalle/BuscarDetalles/$flenId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => FleteDetalleViewModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }
  
  static Future<List<FleteDetalleViewModel>> listarDetallesdeFlete(int flenId) async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteDetalle/Buscar/$flenId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => FleteDetalleViewModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  
}
