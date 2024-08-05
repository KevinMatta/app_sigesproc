import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';

class MapaPrueba extends StatefulWidget {
  const MapaPrueba({super.key});

  @override
  State<MapaPrueba> createState() => _MapaPruebaState();
}

class _MapaPruebaState extends State<MapaPrueba> {
  Location _ubicacionController = new Location();
  LatLng? _actualU = null;

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    ObtenerUbicacion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _actualU == null
          ? const Center(
              child: Text("Cargando..."),
            )
          :  GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _actualU!,
          zoom: 13,
        ),
        markers: {
          Marker(
              markerId: MarkerId("_currentLocation"),
              icon: BitmapDescriptor.defaultMarker,
              position: _actualU!),
        },
      ),
    );
  }

  Future<void>ObtenerUbicacion() async{
    bool _servicioaceptado;
    PermissionStatus _permisoConcedido;

    _servicioaceptado = await _ubicacionController.serviceEnabled();
    if (_servicioaceptado) {
      _servicioaceptado = await _ubicacionController.requestService();
    } else {
      return;
    }

    _permisoConcedido = await _ubicacionController.hasPermission();
    if (_permisoConcedido == PermissionStatus.denied) {
      _permisoConcedido = await _ubicacionController.requestPermission();
      if (_permisoConcedido != PermissionStatus.granted) {
        return;
      }
    }

    _ubicacionController.onLocationChanged
        .listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _actualU =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          // _cameraToPosition(_actualU!);
           print(_actualU);
        });
      }
    });
  }
}
