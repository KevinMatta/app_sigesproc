import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:sigesproc_app/consts.dart';

class MapaPrueba extends StatefulWidget {
  const MapaPrueba({super.key});

  @override
  State<MapaPrueba> createState() => _MapaPruebaState();
}

class _MapaPruebaState extends State<MapaPrueba> {
   final ubicacionController = Location();

  static const tegus = LatLng(14.105713888889, -87.204008333333);
  static const elprogreso = LatLng(15.400913888889, -87.812019444444);

  LatLng? ubicacionactual;
  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) async => await iniciarMapa());
  }

  Future<void> iniciarMapa() async {
    await ubicacionActualizada();
    final coordinates = await polylinePuntos();
    generarPolylineporPuntos(coordinates);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ubicacionactual == null
            ? const Center(child: CircularProgressIndicator(
                  color: Color(0xFFFFF0C6),
                ),)
            : GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: tegus,
                  zoom: 13,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('currentLocation'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: ubicacionactual!,
                  ),
                  const Marker(
                    markerId: MarkerId('sourceLocation'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: tegus,
                  ),
                  const Marker(
                    markerId: MarkerId('destinationLocation'),
                    icon: BitmapDescriptor.defaultMarker,
                    position: elprogreso,
                  )
                },
                polylines: Set<Polyline>.of(polylines.values),
              ),
      );

  Future<void> ubicacionActualizada() async {
    bool servicioAceptado;
    PermissionStatus permisoAceptado;

    servicioAceptado = await ubicacionController.serviceEnabled();
    if (servicioAceptado) {
      servicioAceptado = await ubicacionController.requestService();
    } else {
      return;
    }

    permisoAceptado = await ubicacionController.hasPermission();
    if (permisoAceptado == PermissionStatus.denied) {
      permisoAceptado = await ubicacionController.requestPermission();
      if (permisoAceptado != PermissionStatus.granted) {
        return;
      }
    }

    ubicacionController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          ubicacionactual = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );
        });
      }
    });
  }

  Future<List<LatLng>> polylinePuntos() async {
    final polylines = PolylinePoints();

    final result = await polylines.getRouteBetweenCoordinates(
      gmak,
      PointLatLng(tegus.latitude, tegus.longitude),
      PointLatLng(elprogreso.latitude, elprogreso.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } else {
      debugPrint(result.errorMessage);
      return [];
    }
  }

  Future<void> generarPolylineporPuntos(
      List<LatLng> polylineCoordenadas) async {
    const id = PolylineId('polyline');

    final polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordenadas,
      width: 5,
    );

    setState(() => polylines[id] = polyline);
  }
}
