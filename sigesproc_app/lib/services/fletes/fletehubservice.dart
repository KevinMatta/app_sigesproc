import 'package:sigesproc_app/services/apiservice.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FleteHubService {
   static const String hubUrl = 'https://azureapisigesproc-hafzeraacxavbmd7.mexicocentral-01.azurewebsites.net/fleteHub';

  // Crea una instancia del HubConnection
  final HubConnection connection = HubConnectionBuilder()
      .withUrl(hubUrl, HttpConnectionOptions(
        accessTokenFactory: () async {
          print("Obteniendo API Key");
          return ApiService.apiKey;
        },
      ))
      .build();

  // Método para inicializar y empezar la conexión
  Future<void> startConnection() async {
    try {
      await connection.start();
      debugPrint("Conexión a SignalR iniciada");
    } catch (e) {
      debugPrint("Error al iniciar la conexión a SignalR: $e");
    }
  }

  Future<void> actualizarUbicacion(int emplId, LatLng ubicacion) async {
    if (emplId == null || ubicacion == null) {
      print("Error: emplId o ubicacion es nulo.");
      return;
    }
    print(
        'Intentando actualizar ubicación en SignalR: EmplId: $emplId, Ubicación: $ubicacion');
    try {
      await connection.invoke("ActualizarUbicacion",
          args: [emplId, ubicacion.latitude, ubicacion.longitude]);
      print('Ubicación actualizada en SignalR: $ubicacion');
    } catch (e) {
      print('Error al actualizar ubicación en SignalR: $e');
    }
  }

  void onReceiveUbicacion(
      Function(int emplId, double lat, double lng) onUbicacionRecibida) {
    connection.on("RecibirUbicacion", (message) {
      if (message != null && message.length == 3) {
        int emplId = message[0] as int;
        double lat = message[1] as double;
        double lng = message[2] as double;
        onUbicacionRecibida(emplId, lat, lng);
      }
    });
  }
}
