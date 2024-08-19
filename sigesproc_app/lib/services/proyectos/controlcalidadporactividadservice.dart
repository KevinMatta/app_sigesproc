import 'dart:convert';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/proyectos/controlcalidadporactividadviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/imagenporcontrolcalidadviewmodel.dart';
import '../apiservice.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';


class Respuesta {
  final bool? success;
  final dynamic data;
  final String? message;
  final int? code;

  Respuesta({required this.success, this.data, this.message, this.code});

  factory Respuesta.fromJson(Map<String, dynamic> json) {
    return Respuesta(
      code: json['code'],  // El código de estado HTTP
      success: json['success'] as bool?,
      data: json['data'],
      message: json['message'],
    );
  }
}

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

class ControlDeCalidadesPorActividadesService {

  static Future<Respuesta> insertarControlCalidad(ControlDeCalidadesPorActividadesViewModel controlcalidad) async {
    final url = Uri.parse('${ApiService.apiUrl}/ControlDeCalidad/Insertar');
    
    final headers = {
      'Content-Type': 'application/json',
      ...ApiService.getHttpHeaders(),
    };

    final body = json.encode(controlcalidad.toJson());

    print("JSON enviado: $body");

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    print("Código de estado: ${response.statusCode}");
    print("Respuesta del servidor: ${response.body}");

    if (response.statusCode == 200) {
      return Respuesta.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al insertar el control de calidad: ${response.statusCode} - ${response.body}');
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






 static Future<Respuesta> insertarImagenPorControlCalidad(ImagenPorControlCalidadViewModel imagenControlcalidad) async {
    final url = Uri.parse('${ApiService.apiUrl}/ImagenPorControlCalidad/Insertar');
    
    final headers = {
      'Content-Type': 'application/json',
      ...ApiService.getHttpHeaders(),
    };

    final body = json.encode(imagenControlcalidad.toJson());

    print("JSON enviado: $body");

    final response = await http.post(
      url,
      headers: headers,
      body: body,
    );

    print("Código de estado: ${response.statusCode}");
    print("Respuesta del servidor: ${response.body}");

    if (response.statusCode == 200) {
      return Respuesta.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al insertar imagen por control de calidad: ${response.statusCode} - ${response.body}');
    }
  }




   // Método para listar todos los controles de calidad
  static Future<List<ListarControlDeCalidadesPorActividadesViewModel>> listarControlCalidad() async {
      final url = Uri.parse('${ApiService.apiUrl}/ControlDeCalidad/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ListarControlDeCalidadesPorActividadesViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

}
