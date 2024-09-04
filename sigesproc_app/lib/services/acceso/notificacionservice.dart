import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import '../apiservice.dart';
import 'package:sigesproc_app/models/acceso/notificacionviewmodel.dart';

class NotificationServices {
 static Future<List<NotificationViewModel>> BuscarNotificacion(int userId) async {
    final url = Uri.parse('${ApiService.apiUrl}/NotificacionAlertaPorUsuario/BuscarNotificacion/$userId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body); 
      
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


  // Método para enviar una notificación utilizando la api de Rnder
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




// static Future<void> EnviarNotificacionAAdministradores(String title, String body) async {
//   try {
//     List<String> adminTokens = await ListarTokenAdministradores();

//     for (String token in adminTokens) {
//     final url = Uri.parse('https://sigesproc.onrender.com/send-notification');

//       final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'token': [token], 
//         'data': {
//           'title': title,
//           'body': body,
//         }
//       }),
//     );

//       if (response.statusCode != 200) {
//         print('Error al enviar la notificación a $token: ${response.statusCode}');
//       } else {
//         print('Notificación enviada con éxito a $token');
//       }
//     }
//   } catch (e) {
//     print('Error al enviar la notificación: $e');
//     throw Exception('Error al enviar la notificación');
//   }
// }
 
static Future<void> EnviarNotificacionAAdministradores(String title, String body) async {
  try {
    // Obtener los tokens de los administradores
    List<String> adminTokens = await ListarTokenAdministradores();

    // Obtener el token del dispositivo actual para marcarlo como origen de la acción
    var prefs = PreferenciasUsuario();
    String currentDeviceToken = prefs.token; // Token del dispositivo actual

    // Asegurarse de que los tokens no estén vacíos
    if (adminTokens.isNotEmpty) {
      // Verificar si el dispositivo actual está en la lista de tokens y remover duplicación
      bool currentDeviceIsAdmin = adminTokens.contains(currentDeviceToken);

      // Construir la URL para el envío de la notificación
      final url = Uri.parse('https://sigesproc.onrender.com/send-notification');

      // Crear el cuerpo de la solicitud de notificación
      final bodyRequest = jsonEncode({
        'token': adminTokens, 
        'data': {
          'title': title,
          'body': body,
        }
      });

      // Enviar la notificación a los administradores (incluyendo el dispositivo actual, si es admin)
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: bodyRequest,
      );

      // Verificar si el dispositivo actual está recibiendo duplicación
      if (currentDeviceIsAdmin) {
        print('El dispositivo actual es un administrador y ha recibido la notificación solo una vez.');
      }

      // Verificar el estado de la respuesta
      if (response.statusCode != 200) {
        print('Error al enviar la notificación: ${response.statusCode}');
        print('Respuesta del servidor: ${response.body}');
      } else {
        print('Notificación enviada con éxito a todos los administradores.');
      }
    } else {
      print('No hay tokens de administradores para enviar la notificación.');
    }
  } catch (e) {
    print('Error al enviar la notificación: $e');
    throw Exception('Error al enviar la notificación');
  }
}


 
 static Future<void> eliminarTokenUsuario(int userId, String token) async {
    final url = Uri.parse('${ApiService.apiUrl}/NotificacionAlertaPorUsuario/EliminarToken?id=$userId&token=$token');

    final response = await http.delete(
      url,
      headers: ApiService.getHttpHeaders(),
    );

    if (response.statusCode == 200) {
      print('Token eliminado en el servidor con éxito');
    } else {
      print('Error al eliminar el token en el servidor: ${response.statusCode}');
      throw Exception('Error al eliminar el token en el servidor');
    }
  }
static Future<List<Map<String, dynamic>>> ListarTokenEIdsAdministradores() async {
  final url = Uri.parse('${ApiService.apiUrl}/NotificacionAlertaPorUsuario/Listartokenadministradores');
  final response = await http.get(url, headers: ApiService.getHttpHeaders());

  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = json.decode(response.body);

    List<Map<String, dynamic>> administradores = [];
    for (var item in jsonResponse) {
      if (item['tokn_JsonToken'] != null) {
        List<String> tokens = item['tokn_JsonToken'].split(',');
        for (String token in tokens) {
          administradores.add({
            'token': token,
            'usua_Id': item['usua_Id'],  // Suponiendo que 'usua_Id' esté en la respuesta
          });
        }
      }
    }
    return administradores;
  } else {
    throw Exception('Error al listar los tokens e IDs de administradores');
  }
}

Future<void> enviarNotificacionYRegistrarEnBD(String title, String body, int usuarioCreacionId) async {
  try {
    // Obtener la lista de tokens e IDs de los administradores
    final List<Map<String, dynamic>> administradores = await ListarTokenEIdsAdministradores();

    if (administradores.isNotEmpty) {
      // Crear un conjunto para almacenar los IDs únicos de los usuarios
      final Set<int> usuariosNotificados = {};

      // Crear una lista temporal para los detalles
      final List<Map<String, dynamic>> detalles = [];

      // Construir la lista de detalles para enviar en el cuerpo de la solicitud
      for (var admin in administradores) {
        int userId = admin['usua_Id'];
        if (!usuariosNotificados.contains(userId)) {
          usuariosNotificados.add(userId);  // Agregar el usuario al conjunto de IDs únicos
          detalles.add({
            'noti_Descripcion': body,
            'noti_Fecha': DateTime.now().toIso8601String(),
            'noti_Ruta': '#',
            'usua_Creacion': usuarioCreacionId,
            'usua_Id': userId, 
            'napu_Ruta': '#',
          });
        }
      }

      // Enviar la solicitud al endpoint
      if (detalles.isNotEmpty) {
        final response = await http.post(
          Uri.parse('${ApiService.apiUrl}/Notificacion/InsertarNotificaciones'),
          headers: {
            'Content-Type': 'application/json',
            ...ApiService.getHttpHeaders(), // Incluir los encabezados de autenticación aquí
          },
          body: jsonEncode(detalles),
        );

        if (response.statusCode == 200) {
          print('Notificación enviada y registrada exitosamente');
        } else {
          print('Error al enviar y registrar la notificación');
          print('Status Code: ${response.statusCode}');
          print('Response Body: ${response.body}');
        }
      } else {
        print('No hay detalles para enviar');
      }
    } else {
      print('No se encontraron administradores para notificar');
    }
  } catch (e) {
    print('Error: $e');
  }
}

}



