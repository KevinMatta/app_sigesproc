import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/insumos/proveedorviewmodel.dart';
import '../apiservice.dart';

class ProveedorService {
  static Future<ProveedorViewModel?> Buscar(int provId) async {
  final url = Uri.parse('${ApiService.apiUrl}/Proveedor/Buscar/$provId');
  final response = await http.get(url, headers: ApiService.getHttpHeaders());

  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    return ProveedorViewModel.fromJson(data['data']);  
  } else {
    throw Exception('Error al buscar proveedor');
  }
}
}
