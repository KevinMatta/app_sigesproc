import 'dart:convert';
import 'package:http/http.dart' as http;
import '../apiservice.dart';
import 'package:sigesproc_app/models/acceso/notificacionviewmodel.dart';

class NotificationServices {
 static Future<List<NotificationViewModel>> BuscarNotificacion(int userId) async {
    final url = Uri.parse('${ApiService.apiUrl}/NotificacionAlertaPorUsuario/BuscarNotificacion/$userId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);  // Cambiado a List<dynamic>
      
      return jsonResponse.map((item) => NotificationViewModel.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar las notificaciones');
    }
  }

    static Future<void> LeerNotificacion(int napuId) async {
    final url = Uri.parse('${ApiService.apiUrl}/NotificacionAlertaPorUsuario/Leer/$napuId');
    print('URL de la solicitud: $url'); 
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode != 200) {
      throw Exception('Error al marcar la notificación como leída');
    }
  }
  static Future<bool> EliminarNotificacion(int id) async {
    final url = Uri.parse('${ApiService.apiUrl}/NotificacionAlertaPorUsuario/Eliminar?id=$id');
    final response = await http.delete(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse['code'] == 200;
    } else {
      throw Exception('Error al eliminar la notificación');
    }
  }

  //  static Future<bool> EliminarNotificacion(int id) async {
  //   final url = Uri.parse('${ApiService.apiUrl}/NotificacionAlertaPorUsuario/Eliminar?id=$id');
    
  //   final response = await http.delete(url, headers: ApiService.getHttpHeaders());

  //   if (response.statusCode == 200) {

  //     Map<String, dynamic> jsonResponse = json.decode(response.body);
  //     if (jsonResponse['code'] == 200) {
  //       return true;  
  //     } else {
  //       return false; 
  //     }
  //   } else {
  //     return false;  
  //   }
  // }


  // Método para enviar una notificación utilizando la API de Rnder en Node.js
   static Future<void> EnviarNotificacion(String token, String title, String body) async {
    final url = Uri.parse('https://sigesproc.onrender.com/send-notification');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': [token], 
        'data': {
          'title': title,
          'body': body,
        }
      }),
    );

    if (response.statusCode == 200) {
      print('Notificación enviada con éxito');
    } else {
      print('Error al enviar la notificación: ${response.statusCode}');
      throw Exception('Error al enviar la notificación');
    }
  }


  //  static Future<void> insertarToken(int usuaId, String token) async {
  //   final url = Uri.parse('${ApiService.apiUrl}/NotificacionAlertaPorUsuario/InsertarToken');

  //   final body = jsonEncode({
  //     'usua_Id': usuaId,
  //     'tokn_JsonToken': token,
  //   });


  //   final response = await http.post(
  //     url,
  //     headers: {'Content-Type': 'application/json'},
  //     body: body,
  //   );

  //   Verificar la respuesta
  //   if (response.statusCode == 200) {
  //     print('Token insertado/actualizado correctamente');
  //   } else {
  //     print('Error al insertar/actualizar el token: ${response.statusCode}');
  //     throw Exception('Error al insertar/actualizar el token');
  //   }
  // }

static Future<void> insertarToken(int usuaId, String token) async {
  final url = Uri.parse('${ApiService.apiUrl}/NotificacionAlertaPorUsuario/InsertarToken');

  final Map<String, dynamic> notificacionAlertaPorUsuarioViewModel = {
    'usua_Id': usuaId,
    'tokn_JsonToken': token,
  };

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      ...ApiService.getHttpHeaders(),
    },
    body: json.encode(notificacionAlertaPorUsuarioViewModel),
  );

  if (response.statusCode == 200) {
    print('Token insertado correctamente');
  } else {
    print('Error al insertar/actualizar el token: ${response.statusCode}');
    throw Exception('Error al insertar/actualizar el token');
  }
} 
static Future<List<String>> ListarTokenAdministradores() async {
    final url = Uri.parse('${ApiService.apiUrl}/NotificacionAlertaPorUsuario/Listartokenadministradores');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      
      // Extraemos y dividimos los tokens por comas
      List<String> tokens = [];
      for (var item in jsonResponse) {
        if (item['tokn_JsonToken'] != null) {
          tokens.addAll(item['tokn_JsonToken'].split(','));
        }
      }
      return tokens;
    } else {
      throw Exception('Error al listar los tokens de administradores');
    }
  }




static Future<void> EnviarNotificacionAAdministradores(String title, String body) async {
  try {
    List<String> adminTokens = await ListarTokenAdministradores();

    for (String token in adminTokens) {
    final url = Uri.parse('https://sigesproc.onrender.com/send-notification');

      final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': [token], 
        'data': {
          'title': title,
          'body': body,
        }
      }),
    );

      if (response.statusCode != 200) {
        print('Error al enviar la notificación a $token: ${response.statusCode}');
      } else {
        print('Notificación enviada con éxito a $token');
      }
    }
  } catch (e) {
    print('Error al enviar la notificación: $e');
    throw Exception('Error al enviar la notificación');
  }
}


}



