import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/viaticos/CategoriaViaticoViewModel.dart';
import 'package:sigesproc_app/models/viaticos/viaticoDetViewModel.dart';
import '../apiservice.dart';

import 'package:file_picker/file_picker.dart';

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


class ViaticosDetService {
  static Future<List<ViaticoDetViewModel>> listarViaticosDet() async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticosDet/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ViaticoDetViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los detalles de viáticos');
    }
  }

  static Future<ViaticoDetViewModel> buscarViaticoDet(int id) async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticosDet/Buscar/$id');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ViaticoDetViewModel.fromJson(data);
    } else {
      throw Exception('Error al buscar el detalle del viático');
    }
  }

  static Future<void> insertarViaticoDet(ViaticoDetViewModel viaticoDet) async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticosDet/Insertar');
    final response = await http.post(
      url,
      headers: {
        ...ApiService.getHttpHeaders(),
        "Content-Type": "application/json"
      },
      body: json.encode(viaticoDet.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al insertar el detalle del viático');
    }
  }

  static Future<void> actualizarViaticoDet(ViaticoDetViewModel viaticoDet) async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticosDet/Actualizar');
    final response = await http.put(
      url,
      headers: {
        ...ApiService.getHttpHeaders(),
        "Content-Type": "application/json"
      },
      body: json.encode(viaticoDet.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar el detalle del viático');
    }
  }

  static Future<void> eliminarViaticoDet(int id) async {
    final url = Uri.parse('${ApiService.apiUrl}/ViaticosDet/Eliminar/$id');
    final response = await http.delete(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el detalle del viático');
    }
  }


  //--Extras

  // Método para listar todas las categorías de viáticos
  static Future<List<CategoriaVaticoViewModel>> listarCategoriasViatico() async {
    final url = Uri.parse('${ApiService.apiUrl}/CategoriaViatico/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => CategoriaVaticoViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al listar las categorías de viáticos');
    }
  }


  static Future<RespuestaSoloMensaje> uploadImage(PlatformFile imagenControlCalidad, String uniqueFileName) async {
    final url = Uri.parse('${ApiService.apiUrl}/DocumentoBienRaiz/Subir');
    final request = http.MultipartRequest('POST', url);

    // Añadir encabezados desde el servicio
    request.headers.addAll(ApiService.getHttpHeaders());

    // Verificar si el path es válido
    if (imagenControlCalidad.path == null) {
      print('Error: El archivo de imagen no tiene una ruta válida.');
      throw Exception('El archivo de imagen no tiene una ruta válida.');
    }

    // Añadir el archivo usando el path
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imagenControlCalidad.path!, // Usamos el path para cargar el archivo
        filename: uniqueFileName,
      ),
    );

    try {
      // Enviar la solicitud
      final response = await request.send();

      // Procesar la respuesta
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final parsedJson = json.decode(responseData);

      print("JSON recibido: $parsedJson");

      final respuesta = RespuestaSoloMensaje.fromJson(parsedJson);

      // Validar si el mensaje recibido es "Éxito" antes de proceder
      if (respuesta.message != "Éxito") {
        throw Exception("Error al subir la imagen: ${respuesta.message}");
      }

      return respuesta;
    } else {
      throw Exception('Error al subir la imagen. Código de estado: ${response.statusCode}');
    }
    } catch (e) {
      print('Error al procesar la imagen: $e');
      rethrow;
    }
  }
}
