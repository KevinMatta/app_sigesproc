import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/fletes/fletedetalleviewmodel.dart';
import 'package:sigesproc_app/models/insumos/equipoporproveedorviewmodel.dart';
import 'package:sigesproc_app/models/insumos/insumoporproveedorviewmodel.dart';
import '../apiservice.dart';

class FleteDetalleService {
  static Future<List<InsumoPorProveedorViewModel>>
      listarInsumosPorProveedorPorBodega(int bodeId) async {
    final url =
        Uri.parse('${ApiService.apiUrl}/InsumoPorProveedor/Buscar/$bodeId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());
    // print('Response status insumos: ${response.statusCode}');
    // print('Response body nsumos: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => InsumoPorProveedorViewModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<List<EquipoPorProveedorViewModel>>
      listarEquiposdeSeguridadPorBodega(int bodeId) async {
    final url = Uri.parse(
        '${ApiService.apiUrl}/EquipoSeguridad/BuscarEquipoPorProveedor/$bodeId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());
    print('Response status equios: ${response.statusCode}');
    print('Response body equipos: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => EquipoPorProveedorViewModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<List<InsumoPorProveedorViewModel>>
      listarInsumosPorProveedorPorActividadEtapa(int acetId) async {
    final url = Uri.parse(
        '${ApiService.apiUrl}/FleteDetalle/BuscarInsumosPorActividadEtapa/$acetId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());
    print('Response acet insumos: ${response.statusCode}');
    print('Response acet nsumos: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print('data insumos $data');
      return data
          .map((json) => InsumoPorProveedorViewModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<List<EquipoPorProveedorViewModel>>
      listarEquiposdeSeguridadPorActividadEtapa(int acetId) async {
    final url = Uri.parse(
        '${ApiService.apiUrl}/FleteDetalle/BuscarEquiposPorActividadEtapa/$acetId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());
    print('Response acet equios: ${response.statusCode}');
    print('Response acet equipos: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print('data $data');
      return data
          .map((json) => EquipoPorProveedorViewModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<void> insertarFleteDetalle(
      FleteDetalleViewModel detalle) async {
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

    print('Response insertar lete detalle: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Error al insertar el detalle del flete');
    }
  }

  static Future<Map<String, dynamic>> insertarFleteDetalle2(
      FleteDetalleViewModel detalle) async {
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

    print(' body insertar fletedet2: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Error al insertar el detalle del flete');
    }

    // Decodificar el body y devolverlo como Map
    return jsonDecode(response.body) as Map<String, dynamic>;
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

    print('Response body editar detalle: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Error al editar el detalle del flete');
    }
  }

  static Future<List<FleteDetalleViewModel>> Buscar(int flenId) async {
    final url =
        Uri.parse('${ApiService.apiUrl}/FleteDetalle/BuscarDetalles/$flenId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());
    print('Response status detalle: ${response.statusCode}');
    print('Response body detalle: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => FleteDetalleViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<List<FleteDetalleViewModel>> listarDetallesdeFlete(
      int flenId) async {
    final url =
        Uri.parse('${ApiService.apiUrl}/FleteDetalle/BuscarDetalles/$flenId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => FleteDetalleViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<void> Eliminar(int fldeId) async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteDetalle/Eliminar/$fldeId');
    final response =
        await http.delete(url, headers: ApiService.getHttpHeaders());
    print('response eliminar $response');
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el flete detalle');
    }
  }
}
