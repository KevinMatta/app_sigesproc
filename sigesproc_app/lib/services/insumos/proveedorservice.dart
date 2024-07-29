import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/insumos/proveedorviewmodel.dart';
import '../apiservice.dart';

class ProveedorService {
  static Future<List<ProveedorViewModel>> listarProveedores() async {
    final url = Uri.parse('${ApiService.apiUrl}/Proveedor/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ProveedorViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }
}
