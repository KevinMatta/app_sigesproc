import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/models/fletes/fletedetalleviewmodel.dart';
import 'package:sigesproc_app/models/insumos/bodegaviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import 'package:sigesproc_app/services/fletes/fletedetalleservice.dart';
import 'package:sigesproc_app/services/fletes/fleteencabezadoservice.dart';
import 'package:sigesproc_app/services/insumos/bodegaservice.dart';
import 'package:sigesproc_app/services/proyectos/proyectoservice.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1Ijoic2V1Y2VkYWEiLCJhIjoiY2x6b28zYWRtMTRvYTJ5b3Bjd3ExN3Y5YyJ9.zX-cUTaYADoXEfN0mBKlXg';

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
  late Future<dynamic> _destinoFuture;

  LatLng? ubicacionactual;
  Map<String, Polyline> polylines = {};
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _fleteFuture = FleteEncabezadoService.obtenerFleteDetalle(widget.flenId);
    _detallesFuture = FleteDetalleService.listarDetallesdeFlete(widget.flenId);
    _bodegaOrigenFuture = _fetchBodegaOrigen(widget.flenId);
    _destinoFuture = _fetchDestino(widget.flenId);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await iniciarMapa();
    });
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
    LatLng? destino;

    final bodegaOrigen = await _bodegaOrigenFuture;
    final destinoData = await _destinoFuture;

    if (bodegaOrigen != null) {
      inicio = obtenerCoordenadasDeEnlace(bodegaOrigen.bodeLinkUbicacion!) ??
          LatLng(0, 0);
    } else {
      inicio = LatLng(0, 0);
    }

    if (destinoData is ProyectoViewModel) {
      destino = obtenerCoordenadasDeEnlace(destinoData.proyLinkUbicacion);
    } else if (destinoData is BodegaViewModel) {
      destino = obtenerCoordenadasDeEnlace(destinoData.bodeLinkUbicacion);
    }

    if (ubicacionObtenida && destino != null) {
      _actualizarPolyline(ubicacionactual!, destino);
    }
  }

  Future<List<LatLng>> obtenerRutaMapbox(LatLng inicio, LatLng destino) async {
    final url = Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving/${inicio.longitude},${inicio.latitude};${destino.longitude},${destino.latitude}?geometries=geojson&access_token=$MAPBOX_ACCESS_TOKEN');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      List<dynamic> coordinates = data['routes'][0]['geometry']['coordinates'];
      List<LatLng> rutaPuntos =
          coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();

      // Imprime los puntos de la ruta para depuración
      print("Puntos de la ruta:");
      rutaPuntos.forEach((punto) {
        print("Lat: ${punto.latitude}, Lng: ${punto.longitude}");
      });

      return rutaPuntos;
    } else {
      throw Exception('No se pudo obtener la ruta');
    }
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
        child: FutureBuilder<FleteEncabezadoViewModel?>(
          future: _fleteFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SpinKitCircle(
                  color: Color(0xFFFFF0C6),
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
              return Stack(
                children: [
                  Positioned(
                    child: Container(
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
                              child: CircularProgressIndicator(
                                color: Color(0xFFFFF0C6),
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
                                    bodegaOrigen.bodeLinkUbicacion!) ??
                                LatLng(0, 0);
                            LatLng? destino;

                            if (destinoData is ProyectoViewModel) {
                              destino = obtenerCoordenadasDeEnlace(
                                  destinoData.proyLinkUbicacion);
                              if (destino == null) {
                                return Center(
                                  child: Text(
                                    'Ubicación del destino inválida',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              }
                            } else if (destinoData is BodegaViewModel) {
                              destino = obtenerCoordenadasDeEnlace(
                                  destinoData.bodeLinkUbicacion);
                            } else {
                              destino = LatLng(0, 0);
                            }

                            return FlutterMap(
                              options: MapOptions(
                                center: ubicacionactual ?? inicio,
                                zoom: 13,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                                  additionalOptions: const {
                                    'accessToken': MAPBOX_ACCESS_TOKEN,
                                    'id': 'mapbox/streets-v12'
                                  },
                                ),
                                MarkerLayer(
                                  markers: [
                                    if (ubicacionactual != null)
                                      Marker(
                                        point: ubicacionactual!,
                                        builder: (context) => Icon(
                                          Icons.directions_car,
                                          color: Colors.red,
                                          size: 25,
                                        ),
                                      ),
                                    if (ubicacionactual == null)
                                      Marker(
                                        point: inicio,
                                        builder: (context) => Icon(
                                          Icons.location_on,
                                          color: Colors.redAccent,
                                          size: 25,
                                        ),
                                      ),
                                    Marker(
                                      point: destino!,
                                      builder: (context) => Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                                PolylineLayer(
                                  polylines: polylines.values.toList(),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: ExpansionTile(
                      collapsedBackgroundColor: Color(0xFFFFF0C6),
                      backgroundColor: Color(0xFFFFF0C6),
                      title: Text(
                        'Ver Detalles',
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      onExpansionChanged: (bool expanding) =>
                          setState(() => isExpanded = expanding),
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
                              SizedBox(height: 5),
                              Text(
                                'Destino: ${flete.destino}',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Fecha y Hora de salida: ${formatDateTime(flete.flenFechaHoraSalida)}',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Fecha y Hora de llegada: ${flete.flenFechaHoraLlegada == null ? 'No ha llegado.' : formatDateTime(flete.flenFechaHoraLlegada)}',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
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
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      detalle.insuDescripcion ??
                                                          '',
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
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
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  LatLng? obtenerCoordenadasDeEnlace(String? enlace) {
    if (enlace == null || enlace.isEmpty) {
      return null;
    }

    final uri = Uri.parse(enlace);
    final coordenadas = uri.queryParameters['q']?.split(',');
    if (coordenadas != null && coordenadas.length == 2) {
      final lat = double.tryParse(coordenadas[0]);
      final lng = double.tryParse(coordenadas[1]);
      if (lat != null && lng != null) {
        return LatLng(lat, lng);
      }
    }
    return null;
  }

  Future<bool> ubicacionActualizada() async {
    bool servicioAceptado = await Geolocator.isLocationServiceEnabled();
    if (!servicioAceptado) {
      servicioAceptado = await Geolocator.openLocationSettings();
      if (!servicioAceptado) return false;
    }

    LocationPermission permisoAceptado = await Geolocator.checkPermission();
    if (permisoAceptado == LocationPermission.denied) {
      permisoAceptado = await Geolocator.requestPermission();
      if (permisoAceptado != LocationPermission.whileInUse &&
          permisoAceptado != LocationPermission.always) {
        return false;
      }
    }

    final currentLocation = await Geolocator.getCurrentPosition();
    setState(() {
      ubicacionactual = LatLng(
        currentLocation.latitude,
        currentLocation.longitude,
      );
    });
    return true;
  }

  Future<void> _actualizarPolyline(LatLng inicio, LatLng destino) async {
    final List<LatLng> polylineCoordenadas =
        await obtenerRutaMapbox(inicio, destino);

    final polyline = Polyline(
      points: polylineCoordenadas,
      strokeWidth: 2,
      color: Colors.blueAccent,
    );

    setState(() {
      polylines['route'] = polyline;
    });
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '--------';
    }
    return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
  }
}
