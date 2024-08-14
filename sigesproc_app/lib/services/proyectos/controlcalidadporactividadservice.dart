import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/proyectos/controlcalidadporactividadviewmodel.dart';
import '../apiservice.dart';

class Respuesta {
  final bool success;
  final dynamic data;

  Respuesta({required this.success, this.data});

  factory Respuesta.fromJson(Map<String, dynamic> json) {
    return Respuesta(
      success: json['success'],
      data: json['data'],
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



}
