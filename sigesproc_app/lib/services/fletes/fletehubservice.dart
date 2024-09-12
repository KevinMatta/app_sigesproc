import 'package:sigesproc_app/services/apiservice.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FleteHubService {
  static const String hubUrl = '${ApiService.url}/fleteHub';

  // Crea una instancia del HubConnection
  final HubConnection connection =
      HubConnectionBuilder().withUrl(hubUrl, HttpConnectionOptions(
    accessTokenFactory: () async {
      print("Obteniendo API Key");
      return ApiService.apiKey;
    },
  )).build();

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

  Future<void> actualizarPolyline(int emplId, int flenId,
      List<double> latitudes, List<double> longitudes) async {
    if (latitudes.isEmpty || longitudes.isEmpty) {
      print("Error: Las coordenadas son nulas o vacías.");
      return;
    }

    if (latitudes.length != longitudes.length) {
      print(
          "Error: Las listas de latitudes y longitudes deben tener el mismo tamaño.");
      return;
    }

    try {
      print(
          'Enviando polyline a SignalR: EmplId: $emplId, FlenId: $flenId, Coordenadas: $latitudes, $longitudes');
      await connection.invoke("ActualizarPolyline",
          args: [emplId, flenId, latitudes, longitudes]);
      print('Polyline actualizada en SignalR');
    } catch (e) {
      print('Error al actualizar polyline en SignalR: $e');
    }
  }

  void onReceivePolyline(
    Function(int emplId, int flenId, List<double> latitudes, List<double> longitudes)
        onPolylineRecibida) {
  connection.on("RecibirPolyline", (message) {
    if (message != null && message.length == 4) { // Cambia de 3 a 4, ya que ahora recibimos flenId también
      int emplId = message[0] as int;
      int flenId = message[1] as int;
      List<double> latitudes = (message[2] as List).map((lat) => lat as double).toList();
      List<double> longitudes = (message[3] as List).map((lng) => lng as double).toList();
      
      onPolylineRecibida(emplId, flenId, latitudes, longitudes); // Ahora también pasamos el flenId
    }
  });
}


  Future<List<LatLng>?> obtenerPolyline(int emplId, int flenId) async {
    try {
      print(
          'Solicitando polyline desde el servidor para emplId: $emplId y flenId: $flenId');
      final result =
          await connection.invoke('ObtenerPolyline', args: [emplId, flenId]);

      if (result != null && result is List) {
        List<LatLng> polylineCoordinates = [];
        for (var item in result) {
          if (item is Map && item['lat'] != null && item['lng'] != null) {
            polylineCoordinates.add(LatLng(item['lat'], item['lng']));
          }
        }
        return polylineCoordinates;
      }
    } catch (e) {
      print('Error al obtener Polyline desde SignalR: $e');
    }
    return null;
  }
}
