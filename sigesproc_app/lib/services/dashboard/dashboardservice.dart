import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import '../apiservice.dart';

class RespuestaSoloMensaje {
  final String? message;

  RespuestaSoloMensaje({this.message});

  // Factory constructor para crear una instancia desde el JSON
  factory RespuestaSoloMensaje.fromJson(Map<String, dynamic> json) {
    return RespuestaSoloMensaje(
      message: json['message'],
    );
  }
}

class DashboardService {
  static Future<List<DashboardViewModel>> listarFletesEncabezado() async {
    final url =
        Uri.parse('${ApiService.apiUrl}/Dashboard/DashboardTop5Proveedores');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => DashboardViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }
}
