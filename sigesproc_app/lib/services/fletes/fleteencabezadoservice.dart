import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
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


class FleteEncabezadoService {
  static Future<List<FleteEncabezadoViewModel>> listarFletesEncabezado() async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteEncabezado/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map((json) => FleteEncabezadoViewModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<int?> insertarFlete(FleteEncabezadoViewModel flete) async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteEncabezado/Insertar');
    final body = jsonEncode(flete.toJson());
    final headers = {
      'Content-Type': 'application/json',
      'XApiKey': ApiService.apiKey,
    };

    // print('Body: $body');

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    // print('Response insertar enca: ${response.statusCode}');
    // print('Response body enca: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['data']['codeStatus'];
    } else {
      return null;
    }
  }

   static Future<RespuestaSoloMensaje> uploadImage(PlatformFile comprobante, String uniqueFileName) async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteEncabezado/Subir');
    final request = http.MultipartRequest('POST', url);

    request.headers.addAll(ApiService.getHttpHeaders());

    if (comprobante.path == null) {
      // print('Error: El archivo de imagen no tiene una ruta válida.');
      throw Exception('El archivo de imagen no tiene una ruta válida.');
    }

    // Añadir el archivo usando el path
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        comprobante.path!, 
        filename: uniqueFileName,
      ),
    );

    try {
      final response = await request.send();

      // Procesar la respuesta
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final parsedJson = json.decode(responseData);

      // print("JSON recibido: $parsedJson");

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
      // print('Error al procesar la imagen: $e');
      rethrow;
    }
  }

  static Future<int?> editarFlete(FleteEncabezadoViewModel flete) async {
    final url = Uri.parse('${ApiService.apiUrl}/FleteEncabezado/Actualizar');
    final body = jsonEncode(flete.toJson());
    final headers = {
      'Content-Type': 'application/json',
      'XApiKey': ApiService.apiKey,
    };

    // print('Body editar: $body');

    final response = await http.put(
      url,
      headers: headers,
      body: body,
    );

    print('Response body editar flete: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['data']['codeStatus'];
    } else {
      return null;
    }
  }

  static Future<FleteEncabezadoViewModel?> obtenerFleteDetalle(
      int flenId) async {
    final List<FleteEncabezadoViewModel> fletes =
        await listarFletesEncabezado();

    try {
      final flete = fletes.firstWhere((flete) => flete.flenId == flenId);
      return flete;
    } catch (e) {
      // print('Error: $e');
      throw Exception('Flete con ID $flenId no encontrado');
    }
  }

  static Future<void> Eliminar(int flenId) async {
    final url =
        Uri.parse('${ApiService.apiUrl}/FleteEncabezado/Eliminar/$flenId');
    final response =
        await http.delete(url, headers: ApiService.getHttpHeaders());
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el proceso de venta');
    }
  }
}
