import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:sigesproc_app/consts.dart';
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/models/fletes/fletedetalleviewmodel.dart';
import 'package:sigesproc_app/models/insumos/bodegaviewmodel.dart';
import 'package:sigesproc_app/services/fletes/fletedetalleservice.dart';
import 'package:sigesproc_app/services/fletes/fleteencabezadoservice.dart';
import 'package:sigesproc_app/services/insumos/bodegaservice.dart';

class DetalleFlete extends StatefulWidget {
  final int flenId;

  DetalleFlete({required this.flenId});

  @override
  _DetalleFleteState createState() => _DetalleFleteState();
}

class _DetalleFleteState extends State<DetalleFlete> {
  late Future<FleteEncabezadoViewModel?> _fleteFuture;
  late Future<List<FleteDetalleViewModel>> _detallesFuture;
  late Future<BodegaViewModel?> _bodegaOrigenFuture;
  late Future<BodegaViewModel?> _bodegaDestinoFuture;

  final Location ubicacionController = Location();
  LatLng? ubicacionactual;
  Map<PolylineId, Polyline> polylines = {};
  StreamSubscription<LocationData>? locationSubscription;

  @override
  void initState() {
    super.initState();
    _fleteFuture = FleteEncabezadoService.obtenerFleteDetalle(widget.flenId);
    _detallesFuture = FleteDetalleService.listarDetallesdeFlete(widget.flenId);
    _bodegaOrigenFuture = _fetchBodegaOrigen(widget.flenId);
    _bodegaDestinoFuture = _fetchBodegaDestino(widget.flenId);

    _initializeLocation();
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    bool ubicacionObtenida = await _checkLocationPermissions();
    if (ubicacionObtenida) {
      locationSubscription =
          ubicacionController.onLocationChanged.listen((currentLocation) {
        if (currentLocation.latitude != null &&
            currentLocation.longitude != null) {
          LatLng nuevaUbicacion =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
          setState(() {
            ubicacionactual = nuevaUbicacion;
          });
          _updatePolyline(ubicacionactual!);
        }
      });
    } else {
      _updatePolyline(
          null); // Si no se obtiene la ubicación, actualizar con ubicaciones de origen y destino
    }
  }

  Future<bool> _checkLocationPermissions() async {
    bool servicioAceptado = await ubicacionController.serviceEnabled();
    if (!servicioAceptado) {
      servicioAceptado = await ubicacionController.requestService();
      if (!servicioAceptado) return false;
    }

    PermissionStatus permisoAceptado =
        await ubicacionController.hasPermission();
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

  Future<void> _updatePolyline(LatLng? currentLocation) async {
    final bodegaDestino = await _bodegaDestinoFuture;
    final bodegaOrigen = await _bodegaOrigenFuture;

    if (bodegaDestino != null && bodegaOrigen != null) {
      LatLng origen = _parseLocation(bodegaOrigen.bodeLinkUbicacion!);
      LatLng destino = _parseLocation(bodegaDestino.bodeLinkUbicacion!);

      final coordinates =
          await _getPolylineCoordinates(currentLocation ?? origen, destino);
      _generatePolyline(coordinates);
    } else {
      print('Datos insuficientes para trazar la polyline');
    }
  }

  Future<void> _generatePolyline(List<LatLng> polylineCoordinates) async {
    const id = PolylineId('polyline');

    final polyline = Polyline(
      polylineId: id,
      color: Colors.blueAccent,
      points: polylineCoordinates,
      width: 5,
    );

    setState(() {
      polylines[id] = polyline;
    });
  }

  Future<List<LatLng>> _getPolylineCoordinates(LatLng start, LatLng end) async {
    final polylines = PolylinePoints();

    final result = await polylines.getRouteBetweenCoordinates(
      gmak,
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(end.latitude, end.longitude),
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

  Future<BodegaViewModel?> _fetchBodegaOrigen(int flenId) async {
    try {
      FleteEncabezadoViewModel? flete =
          await FleteEncabezadoService.obtenerFleteDetalle(flenId);
      if (flete != null) {
        return await BodegaService.buscar(flete.bollId!);
      }
    } catch (e) {
      print('Error fetching bodega origen: $e');
    }
    return null;
  }

  Future<BodegaViewModel?> _fetchBodegaDestino(int flenId) async {
    try {
      FleteEncabezadoViewModel? flete =
          await FleteEncabezadoService.obtenerFleteDetalle(flenId);
      if (flete != null) {
        return await BodegaService.buscar(flete.boatId!);
      }
    } catch (e) {
      print('Error fetching bodega destino: $e');
    }
    return null;
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '--------';
    }
    return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset(
              'lib/assets/logo-sigesproc.png',
              height: 60,
            ),
            SizedBox(width: 5),
            Text(
              'SIGESPROC',
              style: TextStyle(
                color: Color(0xFFFFF0C6),
                fontSize: 20,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: Column(
            children: [
              Text(
                'Detalle Flete',
                style: TextStyle(
                  color: Color(0xFFFFF0C6),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.0),
              Container(
                height: 2.0,
                color: Color(0xFFFFF0C6),
              ),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFFF0C6)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<FleteEncabezadoViewModel?>(
          future: _fleteFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFF0C6),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar los detalles del flete',
                  style: TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text(
                  'No se encontraron detalles para el flete con ID: ${widget.flenId}',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else {
              final flete = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder(
                    future: Future.wait(
                        [_bodegaOrigenFuture, _bodegaDestinoFuture]),
                    builder: (context,
                        AsyncSnapshot<List<BodegaViewModel?>> bodegaSnapshot) {
                      if (bodegaSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFFF0C6),
                          ),
                        );
                      } else if (bodegaSnapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error al cargar los detalles de las bodegas',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (!bodegaSnapshot.hasData ||
                          bodegaSnapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'No se encontraron bodegas',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      } else {
                        final bodegaOrigen = bodegaSnapshot.data![0];
                        final bodegaDestino = bodegaSnapshot.data![1];
                        print('Bodega Origen: $bodegaOrigen');
                        print('Bodega Destino: $bodegaDestino');
                        if (bodegaOrigen != null) {
                          print(
                              'bodegaOrigen.bodeLinkUbicacion: ${bodegaOrigen.bodeLinkUbicacion}');
                        }
                        if (bodegaDestino != null) {
                          print(
                              'bodegaDestino.bodeLinkUbicacion: ${bodegaDestino.bodeLinkUbicacion}');
                        }
                        LatLng cameraPosition = ubicacionactual ??
                            _parseLocation(bodegaDestino!.bodeLinkUbicacion!);
                        return Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: cameraPosition,
                                    zoom: 13,
                                  ),
                                  markers: {
                                    if (ubicacionactual != null)
                                      Marker(
                                        markerId:
                                            const MarkerId('currentLocation'),
                                        icon: BitmapDescriptor.defaultMarker,
                                        position: ubicacionactual!,
                                      ),
                                    if (bodegaOrigen?.bodeLinkUbicacion != null)
                                      Marker(
                                        markerId:
                                            const MarkerId('originLocation'),
                                        icon: BitmapDescriptor.defaultMarker,
                                        position: _parseLocation(
                                            bodegaOrigen!.bodeLinkUbicacion!),
                                      ),
                                    if (bodegaDestino?.bodeLinkUbicacion !=
                                        null)
                                      Marker(
                                        markerId: const MarkerId(
                                            'destinationLocation'),
                                        icon: BitmapDescriptor.defaultMarker,
                                        position: _parseLocation(
                                            bodegaDestino!.bodeLinkUbicacion!),
                                      ),
                                  },
                                  polylines: Set<Polyline>.of(polylines.values),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  ExpansionTile(
                    collapsedBackgroundColor: Color(0xFFFFF0C6),
                    backgroundColor: Color(0xFFFFF0C6),
                    title: Text(
                      'Ver Detalles',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Encargado: ${flete.encargado}',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Fecha y Hora de salida: ${formatDateTime(flete.flenFechaHoraSalida)}',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Fecha y Hora de llegada: ${flete.flenFechaHoraLlegada == null ? 'No ha llegado.' : formatDateTime(flete.flenFechaHoraLlegada)}',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            FutureBuilder<List<FleteDetalleViewModel>>(
                              future: _detallesFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFFFF0C6),
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Center(
                                    child: Text(
                                      'Error al cargar los detalles del flete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  );
                                } else if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Center(
                                    child: Text(
                                      'No se encontraron materiales para el flete.',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  );
                                } else {
                                  final detalles = snapshot.data!;
                                  return Container(
                                    height: 100, //  Tamano
                                    child: SingleChildScrollView(
                                      child: Table(
                                        border: TableBorder.all(
                                            color: Colors.black),
                                        columnWidths: {
                                          0: FlexColumnWidth(3),
                                          1: FlexColumnWidth(1),
                                        },
                                        children: [
                                          TableRow(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Materiales',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  'Cantidad',
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ],
                                          ),
                                          ...detalles.map((detalle) {
                                            return TableRow(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    detalle.insuDescripcion ??
                                                        '',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    detalle.fldeCantidad
                                                        .toString(),
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  LatLng _parseLocation(String locationLink) {
    final uri = Uri.parse(locationLink);
    final latLng = uri.queryParameters['q']!.split(',');
    return LatLng(double.parse(latLng[0]), double.parse(latLng[1]));
  }
}
