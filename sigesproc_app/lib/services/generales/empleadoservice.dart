import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/generales/empleadoviewmodel.dart';
import '../apiservice.dart';

class EmpleadoService {
  static Future<List<EmpleadoViewModel>> listarEmpleados() async {
    final url = Uri.parse('${ApiService.apiUrl}/Empleado/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => EmpleadoViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<EmpleadoViewModel?> obtenerEmpleado(
      int empleId) async {
    final List<EmpleadoViewModel> empleados =
        await listarEmpleados();

    try {
      final empleado = empleados.firstWhere((flete) => flete.emplId == empleId);
      return empleado;
    } catch (e) {
      //print('Error: $e');
      throw Exception('Flete con ID $empleId no encontrado');
    }
  }
}
