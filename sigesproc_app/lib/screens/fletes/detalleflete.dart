import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:sigesproc_app/consts.dart';
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/models/fletes/fletedetalleviewmodel.dart';
import 'package:sigesproc_app/models/insumos/bodegaviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import 'package:sigesproc_app/services/fletes/fletedetalleservice.dart';
import 'package:sigesproc_app/services/fletes/fleteencabezadoservice.dart';
import 'package:sigesproc_app/services/insumos/bodegaservice.dart';
import 'package:sigesproc_app/services/proyectos/proyectoservice.dart';

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
  late Future<dynamic>
      _destinoFuture; // Puede ser BodegaViewModel o ProyectoViewModel

  final ubicacionController = Location();
  LatLng? ubicacionactual;
  Map<PolylineId, Polyline> polylines = {};
  StreamSubscription<LocationData>? locationSubscription;

  @override
  void initState() {
    super.initState();
    _fleteFuture = FleteEncabezadoService.obtenerFleteDetalle(widget.flenId);
    _detallesFuture = FleteDetalleService.listarDetallesdeFlete(widget.flenId);
    _bodegaOrigenFuture = _fetchBodegaOrigen(widget.flenId);
    _destinoFuture = _fetchDestino(widget.flenId);
    WidgetsBinding.instance
        .addPostFrameCallback((_) async => await iniciarMapa());
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
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

  Future<dynamic> _fetchDestino(int flenId) async {
    try {
      FleteEncabezadoViewModel? flete =
          await FleteEncabezadoService.obtenerFleteDetalle(flenId);
      if (flete != null) {
        if (flete.flenDestinoProyecto!) {
          return await ProyectoService.obtenerProyecto(flete.boatId!);
        } else {
          return await BodegaService.buscar(flete.boatId!);
        }
      }
    } catch (e) {
      print('Error fetching destino: $e');
    }
    return null;
  }

  Future<void> iniciarMapa() async {
    bool ubicacionObtenida = await ubicacionActualizada();
    LatLng inicio;
    LatLng destino;

    final bodegaOrigen = await _bodegaOrigenFuture;
    final destinoData = await _destinoFuture;

    if (bodegaOrigen != null) {
      inicio = obtenerCoordenadasDeEnlace(bodegaOrigen.bodeLinkUbicacion!);
    } else {
      inicio = LatLng(0, 0);
    }

    if (destinoData is ProyectoViewModel) {
      destino = obtenerCoordenadasDeEnlace(destinoData.proyLinkUbicacion!);
    } else if (destinoData is BodegaViewModel) {
      destino = obtenerCoordenadasDeEnlace(destinoData.bodeLinkUbicacion!);
    } else {
      destino = LatLng(0, 0);
    }

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
          _actualizarPolyline(nuevaUbicacion, destino);
        }
      });
    }

    final coordinates = await polylinePuntos(
        ubicacionObtenida ? ubicacionactual! : inicio, destino);
    generarPolylineporPuntos(coordinates);
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
                child: SpinKitCircle(
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
                  Expanded(
                    child: FutureBuilder(
                      future:
                          Future.wait([_bodegaOrigenFuture, _destinoFuture]),
                      builder:
                          (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (ubicacionactual == null) {
                          return Center(
                            child: SpinKitCircle(
                              color: Color(0xFFFFF0C6),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error al cargar ubicaciones',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data == null ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No se encontraron ubicaciones',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        } else {
                          final bodegaOrigen =
                              snapshot.data![0] as BodegaViewModel?;
                          final destinoData = snapshot.data![1];

                          if (bodegaOrigen == null || destinoData == null) {
                            return Center(
                              child: Text(
                                'No se encontraron ubicaciones válidas',
                                style: TextStyle(color: Colors.white),
                              ),
                            );
                          }

                          LatLng inicio = obtenerCoordenadasDeEnlace(
                              bodegaOrigen.bodeLinkUbicacion!);
                          LatLng destino;

                          if (destinoData is ProyectoViewModel) {
                            destino = obtenerCoordenadasDeEnlace(
                                destinoData.proyLinkUbicacion!);
                          } else if (destinoData is BodegaViewModel) {
                            destino = obtenerCoordenadasDeEnlace(
                                destinoData.bodeLinkUbicacion!);
                          } else {
                            destino = LatLng(0, 0);
                          }

                          return GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: ubicacionactual ?? inicio,
                              zoom: 13,
                            ),
                            markers: {
                              if (ubicacionactual != null)
                                Marker(
                                  markerId: const MarkerId('currentLocation'),
                                  icon: BitmapDescriptor.defaultMarker,
                                  position: ubicacionactual!,
                                ),
                              if (ubicacionactual != null)
                              Marker(
                                markerId: const MarkerId('sourceLocation'),
                                icon: BitmapDescriptor.defaultMarker,
                                position: inicio,
                              ),
                              Marker(
                                markerId: const MarkerId('destinationLocation'),
                                icon: BitmapDescriptor.defaultMarker,
                                position: destino,
                              )
                            },
                            polylines: Set<Polyline>.of(polylines.values),
                          );
                        }
                      },
                    ),
                  ),
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
                                    child: SpinKitCircle(
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

  LatLng obtenerCoordenadasDeEnlace(String enlace) {
    final uri = Uri.parse(enlace);
    final coordenadas = uri.queryParameters['q']?.split(',');
    if (coordenadas != null && coordenadas.length == 2) {
      final lat = double.tryParse(coordenadas[0]);
      final lng = double.tryParse(coordenadas[1]);
      if (lat != null && lng != null) {
        return LatLng(lat, lng);
      }
    }
    throw ArgumentError('Enlace de ubicación inválido: $enlace');
  }

  Future<bool> ubicacionActualizada() async {
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

  Future<List<LatLng>> polylinePuntos(LatLng inicio, LatLng destino) async {
    final polylines = PolylinePoints();

    final result = await polylines.getRouteBetweenCoordinates(
      gmak,
      PointLatLng(inicio.latitude, inicio.longitude),
      PointLatLng(destino.latitude, destino.longitude),
      travelMode: TravelMode.driving,
    );
    print('Result de polylinePuntos: $result');
    print('Status: ${result.status}');
    print('Error message: ${result.errorMessage}');
    print('Number of points: ${result.points.length}');

    if (result.points.isNotEmpty) {
      print('Puntos obtenidos: ${result.points}');
      return result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } else {
      print('No se obtuvieron puntos: ${result.points}');
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

  Future<void> _actualizarPolyline(LatLng inicio, LatLng destino) async {
    final coordinates = await polylinePuntos(inicio, destino);
    generarPolylineporPuntos(coordinates);
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '--------';
    }
    return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
  }
}
