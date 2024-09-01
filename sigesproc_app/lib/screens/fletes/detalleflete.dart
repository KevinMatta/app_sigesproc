import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigesproc_app/consts.dart';
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/models/fletes/fletedetalleviewmodel.dart';
import 'package:sigesproc_app/models/insumos/bodegaviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import 'package:sigesproc_app/services/fletes/fletedetalleservice.dart';
import 'package:sigesproc_app/services/fletes/fleteencabezadoservice.dart';
import 'package:sigesproc_app/services/fletes/fletehubservice.dart';
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
  late Future<dynamic> _bodegaOrigenFuture;
  late Future<dynamic>
      _destinoFuture; // Puede ser BodegaViewModel o ProyectoViewModel

  final ubicacionController = Location();
  LatLng? ubicacionactual;
  Map<PolylineId, Polyline> polylines = {};
  StreamSubscription<LocationData>? locationSubscription;
  BitmapDescriptor? carritoIcono;
  bool isExpanded = false;
  int? emplId;
  bool esFletero = false;

  @override
  void initState() {
    super.initState();
    _loadEmplId(); // Cargar el emplId desde las preferencias compartidas
    FleteHubService().onReceiveUbicacion((emplId, lat, lng) {
      setState(() {
        // Actualiza la ubicación del fletero en el mapa
        LatLng nuevaUbicacion = LatLng(lat, lng);
        if (emplId != this.emplId) {
          if (ubicacionactual != null) {
            // Generar polyline desde la última ubicación actualizada
            polylines[PolylineId('realPolyline')]?.points.add(nuevaUbicacion);
            _actualizarPolyline(
                ubicacionactual!, nuevaUbicacion, Colors.red, 'realPolyline');
          }
          ubicacionactual = nuevaUbicacion;
        }
      });
    });

    _fleteFuture = FleteEncabezadoService.obtenerFleteDetalle(widget.flenId);
    _detallesFuture = FleteDetalleService.listarDetallesdeFlete(widget.flenId);
    _bodegaOrigenFuture = _fetchBodegaOrigen(widget.flenId);
    _destinoFuture = _fetchDestino(widget.flenId);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      carritoIcono = await createBitmapDescriptorFromIcon(
          Icons.directions_car, Colors.red, 80);
      await iniciarMapa();
    });
  }

  @override
  void dispose() {
    locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadEmplId() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      emplId = int.tryParse(pref.getString('emplId') ?? '');
      // emplId = 88;
      print(emplId);
    });
  }

  Future<BitmapDescriptor> createBitmapDescriptorFromIcon(
      IconData iconData, Color color, double size) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint()..color = color;
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);

    textPainter.text = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: iconData.fontFamily,
        color: color,
      ),
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);
    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }

  Future<dynamic> _fetchBodegaOrigen(int flenId) async {
    try {
      FleteEncabezadoViewModel? flete =
          await FleteEncabezadoService.obtenerFleteDetalle(flenId);
      if (flete != null) {
        if (flete.flenSalidaProyecto!) {
          return await ProyectoService.obtenerProyecto(flete.boasId!);
        } else {
          return await BodegaService.buscar(flete.boasId!);
        }
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
    final FleteEncabezadoViewModel? flete = await _fleteFuture;
    if (flete == null) {
      print('No se encontró el flete');
      return;
    }

    final bool esFletero = flete.emtrId == emplId;
    print('aver ${flete.emtrId} $emplId');

    // Si el flete ya ha sido completado
    if (flete.flenEstado == true) {
      _mostrarRutasAnteriores();
      return;
    }

    if (esFletero) {
      // El fletero aún está llevando el flete
      bool ubicacionObtenida = await ubicacionActualizada();
      if (ubicacionObtenida) {
        // Envía la ubicación actual a la API
        FleteHubService().actualizarUbicacion(emplId!, ubicacionactual!);

        // Genera una nueva polyline roja
        LatLng inicio = ubicacionactual!;
        LatLng? destino = await _obtenerDestino();

        if (destino != null) {
          final coordinates = await polylinePuntos(inicio, destino);
          final id = PolylineId(
              'polyline_roja_${emplId}_${DateTime.now().millisecondsSinceEpoch}');
          generarPolylineporPuntos2(coordinates, Colors.red, id);
        } else {
          print('Ubicación del destino inválida');
        }
      }
    } else {
      // No es el fletero, mostrar solo la ruta predestinada
      LatLng? inicio = await _obtenerOrigen();
      LatLng? destino = await _obtenerDestino();

      if (inicio != null && destino != null) {
        final coordinates = await polylinePuntos(inicio, destino);
        final id = PolylineId('polyline_azul_${widget.flenId}');
        generarPolylineporPuntos2(coordinates, Colors.blue, id);
      } else {
        print('Ubicaciones inválidas');
      }
    }
  }

// Función para mostrar las rutas anteriores
  Future<void> _mostrarRutasAnteriores() async {
    // Aquí recuperas las rutas anteriores y las dibujas en el mapa
    // Puedes guardar estas rutas en SharedPreferences o recuperarlas desde la API

    // Ejemplo:
    List<List<LatLng>> rutasAnteriores = await _obtenerRutasAnteriores();
    for (int i = 0; i < rutasAnteriores.length; i++) {
      final id = PolylineId('ruta_anterior_$i');
      generarPolylineporPuntos2(rutasAnteriores[i], Colors.red, id);
    }
  }

  Future<void> generarPolylineporPuntos2(
    List<LatLng> polylineCoordenadas,
    Color color,
    PolylineId id,
  ) async {
    final polyline = Polyline(
      polylineId: id,
      color: color,
      points: polylineCoordenadas,
      width: 5,
    );

    if (mounted) {
      setState(() => polylines[id] = polyline);
    }
  }

  Future<void> _guardarRuta(List<LatLng> ruta) async {
    // Guardar la ruta en SharedPreferences o en la API
  }

  Future<List<List<LatLng>>> _obtenerRutasAnteriores() async {
    // Recuperar las rutas anteriores desde SharedPreferences o la API
    return [];
  }

  Future<LatLng?> _obtenerOrigen() async {
    final origenData = await _bodegaOrigenFuture;
    if (origenData is ProyectoViewModel) {
      return obtenerCoordenadasDeEnlace(origenData.proyLinkUbicacion);
    } else if (origenData is BodegaViewModel) {
      return obtenerCoordenadasDeEnlace(origenData.bodeLinkUbicacion!);
    }
    return null;
  }

  Future<LatLng?> _obtenerDestino() async {
    final destinoData = await _destinoFuture;
    if (destinoData is ProyectoViewModel) {
      return obtenerCoordenadasDeEnlace(destinoData.proyLinkUbicacion);
    } else if (destinoData is BodegaViewModel) {
      return obtenerCoordenadasDeEnlace(destinoData.bodeLinkUbicacion);
    }
    return null;
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
                      height: 640,
                      child: FutureBuilder(
                        future:
                            Future.wait([_bodegaOrigenFuture, _destinoFuture]),
                        builder:
                            (context, AsyncSnapshot<List<dynamic>> snapshot) {
                          if (ubicacionactual == null && !esFletero) {
                            // Si la ubicación actual no está disponible y no es el fletero, muestra solo la ruta destinada
                            return Center(
                              child: GoogleMap(
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(0,
                                      0), // Puedes cambiar esto a la ubicación deseada
                                  zoom: 13,
                                ),
                                polylines: Set<Polyline>.of(polylines.values),
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
                              child: SpinKitCircle(
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
                            } else if (destinoData is BodegaViewModel) {
                              destino = obtenerCoordenadasDeEnlace(
                                  destinoData.bodeLinkUbicacion);
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
                                    icon: carritoIcono ??
                                        BitmapDescriptor.defaultMarker,
                                    position: ubicacionactual!,
                                  ),
                                Marker(
                                  markerId: const MarkerId('sourceLocation'),
                                  icon: BitmapDescriptor.defaultMarker,
                                  position: inicio,
                                ),
                                Marker(
                                  markerId:
                                      const MarkerId('destinationLocation'),
                                  icon: BitmapDescriptor.defaultMarker,
                                  position: destino!,
                                )
                              },
                              polylines: Set<Polyline>.of(polylines.values),
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
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      detalle.insuDescripcion ??
                                                          detalle
                                                              .equsDescripcion!,
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
      return null; // Devuelve null si el enlace es nulo o vacío
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
    return null; // Devuelve null si no puede obtener las coordenadas
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
      List<LatLng> polylineCoordenadas, Color color, String id) async {
    final polylineId = PolylineId(id);

    final polyline = Polyline(
      polylineId: polylineId,
      color: color,
      points: polylineCoordenadas,
      width: 5,
    );

    if (mounted) {
      setState(() => polylines[polylineId] = polyline);
    }
  }

  Future<void> _actualizarPolyline(
      LatLng inicio, LatLng nuevaUbicacion, Color color, String id) async {
    // Genera una línea desde la última ubicación conocida hasta la nueva ubicación
    final List<LatLng> polylineCoordenadas = [inicio, nuevaUbicacion];
    await generarPolylineporPuntos(polylineCoordenadas, color, id);
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '--------';
    }
    return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
  }
}
