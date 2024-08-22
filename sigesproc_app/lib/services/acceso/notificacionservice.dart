import 'dart:convert';
import 'package:http/http.dart' as http;
import '../apiservice.dart';
import 'package:sigesproc_app/models/acceso/notificacionviewmodel.dart';

class NotificationServices {
  static Future<List<NotificationViewModel>> BuscarNotificacion(int userId) async {
    final url = Uri.parse('${ApiService.apiUrl}/NotificacionAlertaPorUsuario/BuscarNotificacion/$userId');
    final response = await http.get(url, headers: ApiService.getHttpHeaders());

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      
      if (jsonResponse['code'] == 200 && jsonResponse['data'] != null) {
        List<dynamic> data = jsonResponse['data'];
        return data.map((item) => NotificationViewModel.fromJson(item)).toList();
      } else {
        throw Exception('Error en la respuesta del servidor');
      }
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
}
