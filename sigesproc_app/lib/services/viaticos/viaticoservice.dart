import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/generales/empleadoviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import 'package:sigesproc_app/models/viaticos/detalleviaticoViewModel.dart';
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

static Future<Detalleviaticoviewmodel> buscarViaticoDetalle(int id) async {
  final url = Uri.parse('${ApiService.apiUrl}/ViaticosEnc/BuscarEncDet/$id');
  final response = await http.get(url, headers: ApiService.getHttpHeaders());

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data is List && data.isNotEmpty) {
      // Obtener el objeto de detalle
      final detalle = Detalleviaticoviewmodel.fromJson(data[0]);

      // Concatenar la URL base de la imagen si es necesario
      const String baseUrl = 'http://www.apisigesproc.somee.com';  // Cambia a tu URL real

      // Asegúrate de que el campo de imagen no sea nulo y que contenga una ruta
      if (detalle.videImagenFactura != null && detalle.videImagenFactura!.isNotEmpty) {
        // Convertir la cadena separada por comas en una lista de URLs de las imágenes
        List<String> imagenes = detalle.videImagenFactura!.split(',').map((imagePath) {
          // Quitar espacios en blanco y concatenar con la URL base
          return '$baseUrl${imagePath.trim()}';
        }).toList();

        // Asignar la lista de imágenes procesadas al detalle
        detalle.videImagenFactura = imagenes.join(',');
      }

      return detalle;
    } else {
      throw Exception('No se encontraron datos en la respuesta');
    }
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
