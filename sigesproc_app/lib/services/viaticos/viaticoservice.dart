import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/generales/empleadoviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import 'package:sigesproc_app/models/viaticos/viaticoViewModel.dart';
import '../apiservice.dart';

class ViaticosEncService {
  static Future<List<ViaticoEncViewModel>> listarViaticos(int usuarioId) async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticosEnc/Listar?usua_Id=$usuarioId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ViaticoEncViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos de viáticos');
    }
  }

  static Future<ViaticoEncViewModel> buscarViatico(int id) async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticosEnc/Buscar/$id');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ViaticoEncViewModel.fromJson(data);
    } else {
      throw Exception('Error al buscar el viático');
    }
  }

  static Future<ViaticoEncViewModel> buscarViaticoDetalle(int id) async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticosEnc/BuscarEncDet/$id');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ViaticoEncViewModel.fromJson(data);
    } else {
      throw Exception('Error al buscar el detalle del viático');
    }
  }

  static Future<void> eliminarViatico(int id) async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticosEnc/Eliminar/$id');
    final response = await http.delete(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el viático');
    }
  }

  static Future<void> finalizarViatico(int id) async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticosEnc/Finalizar/$id');
    final response = await http.delete(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode != 200) {
      throw Exception('Error al finalizar el viático');
    }
  }

static Future<void> insertarViatico(ViaticoEncViewModel viatico) async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticosEnc/Insertar');
    final response = await http.post(
      url,
      headers: {
        ...ApiService.getHttpHeaders(),
        "Content-Type": "application/json"
      },
      body: json.encode(viatico.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al insertar el viático: ${response.body}');
    }
  }

  static Future<void> actualizarViatico(ViaticoEncViewModel viatico) async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticosEnc/Actualizar');
    final response = await http.put(
      url,
      headers: {
        ...ApiService.getHttpHeaders(),
        "Content-Type": "application/json"
      },
      body: json.encode(viatico.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el viático');
    }
  }

  //'''''''''''' Extras




  // Método para buscar un empleado por DNI
  static Future<EmpleadoViewModel> buscarEmpleadoPorDNI(String dni) async {
    final url = Uri.parse('${ApiService.apiUrl}/Empleado/BuscarPorDNI/$dni');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return EmpleadoViewModel.fromJson(data);
    } else {
      throw Exception('Error al buscar el empleado por DNI');
    }
  }

  // Método para listar todos los empleados
  static Future<List<EmpleadoViewModel>> listarEmpleados() async {
    final url = Uri.parse('${ApiService.apiUrl}/Empleado/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => EmpleadoViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al listar los empleados');
    }
  }

  // Método para buscar un proyecto por nombre
  static Future<ProyectoViewModel> buscarProyectoPorNombre(String nombre) async {
    final url = Uri.parse('${ApiService.apiUrl}/Proyecto/BuscarPorNombre?proy_Nombre=$nombre');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ProyectoViewModel.fromJson(data);
    } else {
      throw Exception('Error al buscar el proyecto por nombre');
    }
  }

  // Método para listar todos los proyectos
  static Future<List<ProyectoViewModel>> listarProyectos() async {
    final url = Uri.parse('${ApiService.apiUrl}/Proyecto/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ProyectoViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al listar los proyectos');
    }
  }
}
