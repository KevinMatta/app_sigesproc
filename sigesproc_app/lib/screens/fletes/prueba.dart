import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  // final Completer<GoogleMapController> _controller = Completer();

  static const tegus = LatLng(14.105713888889, -87.204008333333);
  static const elprogreso = LatLng(15.400913888889, -87.812019444444);

  LatLng? ubicacionactual;
  Map<PolylineId, Polyline> polylines = {};
  StreamSubscription<LocationData>? locationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async => await iniciarMapa());
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> iniciarMapa() async {
    bool ubicacionObtenida = await ubicacionActualizada();
    if (ubicacionObtenida) {
      locationSubscription = ubicacionController.onLocationChanged.listen((currentLocation) {
        if (currentLocation.latitude != null && currentLocation.longitude != null) {
          LatLng nuevaUbicacion = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          setState(() {
            ubicacionactual = nuevaUbicacion;
          });
          _actualizarPolyline(nuevaUbicacion, elprogreso);
        }
      });
    }
    final coordinates = await polylinePuntos(ubicacionObtenida ? ubicacionactual! : tegus, elprogreso);
    generarPolylineporPuntos(coordinates);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: ubicacionactual == null
            ? const Center(
                child: SpinKitCircle(
                  color: Color(0xFFFFF0C6),
                ),
              )
            : GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: tegus,
                  zoom: 13,
                ),
                markers: {
                  if (ubicacionactual != null)
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

  Future<bool> ubicacionActualizada() async {
    bool servicioAceptado = await ubicacionController.serviceEnabled();
    if (!servicioAceptado) {
      servicioAceptado = await ubicacionController.requestService();
      if (!servicioAceptado) return false;
    }

    PermissionStatus permisoAceptado = await ubicacionController.hasPermission();
    if (permisoAceptado == PermissionStatus.denied) {
      permisoAceptado = await ubicacionController.requestPermission();
      if (permisoAceptado != PermissionStatus.granted) {
        return false;
      }
    }

    final currentLocation = await ubicacionController.getLocation();
    if (currentLocation.latitude != null && currentLocation.longitude != null) {
      setState(() {
        ubicacionactual = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
      });
      return true;
    }
    return false;
  }

  Future<List<LatLng>> polylinePuntos(LatLng inicio, LatLng destino) async {
    final polylines = PolylinePoints();
    print('polynepuntos');
    print(polylines);

    final result = await polylines.getRouteBetweenCoordinates(
      gmak,
      PointLatLng(inicio.latitude, inicio.longitude),
      PointLatLng(destino.latitude, destino.longitude),
      travelMode: TravelMode.driving,
    );
    print('result de polylinepuntos');
    print(result);

    if (result.points.isNotEmpty) {
      print('bueno');
      print(result.points);
      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } else {
      print('malo');
      print(result.points);
      debugPrint(result.errorMessage);
      return [];
    }
  }

  Future<void> generarPolylineporPuntos(List<LatLng> polylineCoordenadas) async {
    const id = PolylineId('polyline');

    final polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordenadas,
      width: 5,
    );

    setState(() => polylines[id] = polyline);
  }

  Future<void> _actualizarPolyline(LatLng inicio, LatLng destino) async {
    final coordinates = await polylinePuntos(inicio, destino);
    generarPolylineporPuntos(coordinates);
  }
}