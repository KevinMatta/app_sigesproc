import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/models/generales/clienteviewmodel.dart';
import '../apiservice.dart';

class ClienteService {
  static Future<List<ClienteViewModel>> listarClientes() async {
    final url = Uri.parse('${ApiService.apiUrl}/Cliente/Listar');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => ClienteViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los datos');
    }
  }

  static Future<ClienteViewModel?> obtenerCliente(
      int clieId) async {
    final List<ClienteViewModel> clientes =
        await listarClientes();

    try {
      final cliente = clientes.firstWhere((venta) => venta.clieId == clieId);
      return cliente;
    } catch (e) {
      print('Error: $e');
      throw Exception('Flete con ID $clieId no encontrado');
    }
  }

  static Future<int?> insertarCliente(ClienteViewModel cliente) async {
    final url = Uri.parse('${ApiService.apiUrl}/Cliente/Insertar');
    final body = jsonEncode(cliente.toJson());
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

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      return responseBody['data']['codeStatus'];
    } else {
      return null;
    }
  }
}
