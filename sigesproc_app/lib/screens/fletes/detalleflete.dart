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
import 'package:signalr_core/signalr_core.dart' as signalR;

class DetalleFlete extends StatefulWidget {
  final int flenId;

  DetalleFlete({required this.flenId});

  @override
  _DetalleFleteState createState() => _DetalleFleteState();
}

class _DetalleFleteState extends State<DetalleFlete> {
  final FleteHubService _fleteHubService = FleteHubService();
  late Future<FleteEncabezadoViewModel?> _fleteFuture;
  late Future<List<FleteDetalleViewModel>> _detallesFuture;
  late Future<dynamic> _bodegaOrigenFuture;
  late Future<dynamic> _destinoFuture;
  final ubicacionController = Location();
  LatLng? ubicacionactual;
  LatLng? ubicacionInicial;
  Map<PolylineId, Polyline> polylines = {};
  StreamSubscription<LocationData>? locationSubscription;
  BitmapDescriptor? carritoIcono;
  bool expandido = false;
  int? emplId;
  bool esFletero = false;
  bool estaCargando = true;

  @override
  void initState() {
    super.initState();
    _loadEmplId();
    _fleteHubService.startConnection().then((_) {
      _fleteHubService.onReceiveUbicacion((emplId, lat, lng) {
        setState(() {
          LatLng nuevaUbicacion = LatLng(lat, lng);
          if (emplId != this.emplId) {
            if (ubicacionactual != null) {
              polylines[PolylineId('realPolyline')]?.points.add(nuevaUbicacion);
              _actualizarPolyline(
                  ubicacionactual!, nuevaUbicacion, Colors.red, 'realPolyline');
            }
            ubicacionactual = nuevaUbicacion;
          }
        });
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
      // emplId = int.tryParse(pref.getString('emplId') ?? '');
      emplId = 91;
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
          print('yeii ${flete.boasId}');
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
    try {
      print('Cargando detalles del flete...');
      final FleteEncabezadoViewModel? flete = await _fleteFuture;
      if (flete == null) {
        print('No se encontró el flete');
        return;
      }

      esFletero = flete.emtrId == emplId;
      print(
          'Empleado es fletero: $esFletero, EmplId: $emplId, EmtrId: ${flete.emtrId}');

      if (esFletero) {
        print('Obteniendo la ubicación actual para el fletero...');
        bool ubicacionObtenida = await ubicacionActualizada();
        if (!ubicacionObtenida) {
          print("No se pudo obtener la ubicación actual.");
          return;
        }
        print("Ubicación obtenida: $ubicacionactual");

        // Guardar la ubicación inicial solo si no ha sido almacenada previamente
        print('hay ubicacion inicial guardada $ubicacionInicial');
        if (ubicacionInicial == null) {
          ubicacionInicial = ubicacionactual;
          print('toamdno la inicial $ubicacionInicial');
          final pref = await SharedPreferences.getInstance();
          await pref.setDouble('latitudInicial', ubicacionInicial!.latitude);
          await pref.setDouble('longitudInicial', ubicacionInicial!.longitude);
        }

        if (_fleteHubService.connection.state == signalR.ConnectionState.connected) {
          print('Actualizando ubicación inicial en SignalR...');
          await _fleteHubService.actualizarUbicacion(emplId!, ubicacionactual!);
        } else {
          print('No se pudo establecer la conexión con SignalR');
        }

        print('Iniciando el seguimiento de la ubicación en tiempo real...');
        locationSubscription = ubicacionController.onLocationChanged.listen((LocationData currentLocation) async {
          if (currentLocation.latitude != null && currentLocation.longitude != null) {
            LatLng nuevaUbicacion = LatLng(currentLocation.latitude!, currentLocation.longitude!);
            await _fleteHubService.actualizarUbicacion(emplId!, nuevaUbicacion);
            await _actualizarPolyline(ubicacionInicial!, nuevaUbicacion, Colors.red, 'realPolyline');
            setState(() {
              ubicacionactual = nuevaUbicacion;
            });
          }
        });
      }

      await _generarRutas(flete);

      setState(() {
        estaCargando = false;
        print('Mapa cargado y listo para mostrar');
      });
    } catch (e) {
      print('Error en iniciarMapa: $e');
      setState(() {
        estaCargando = false;
      });
    }
  }

  Future<void> _generarRutas(FleteEncabezadoViewModel flete) async {
    print('Obteniendo origen y destino...');
    LatLng? inicio = await _obtenerOrigen();
    LatLng? destino = await _obtenerDestino();

    if (inicio != null && destino != null) {
      print('Origen: $inicio, Destino: $destino');
      final coordinates = await polylinePuntos(inicio, destino);
      final id = PolylineId('polyline_azul_${widget.flenId}');
      await generarPolylineporPuntos(coordinates, Colors.blue, id.toString());
      print('Polyline azul generada con ID: $id');
    } else {
      print('Ubicaciones inválidas para la generación de rutas.');
    }
  }

  void onReceiveUbicacion(int emplId, double lat, double lng) {
    LatLng nuevaUbicacion = LatLng(lat, lng);
    print("Ubicación recibida: EmplId: $emplId, Lat: $lat, Lng: $lng");

    setState(() {
      if (emplId != this.emplId) {
        // Es otro usuario viendo al fletero
        print('es otro usuario');
        polylines[PolylineId('realPolyline')]?.points.add(nuevaUbicacion);
      }
      ubicacionactual = nuevaUbicacion;
    });
  }

  Future<void> _actualizarPolyline(
      LatLng inicio, LatLng nuevaUbicacion, Color color, String id) async {
    final List<LatLng> polylineCoordenadas = [inicio, nuevaUbicacion];
    print(
        'en actualizar polyline las coordenadas a fgenerar $polylineCoordenadas');
    await generarPolylineporPuntos(polylineCoordenadas, color, id);
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
      body: estaCargando
          ? Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFFF0C6)),
              ),
            )
          : Container(
              color: Colors.black,
              child: FutureBuilder<FleteEncabezadoViewModel?>(
                future: _fleteFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
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
                              future: Future.wait(
                                  [_bodegaOrigenFuture, _destinoFuture]),
                              builder: (context,
                                  AsyncSnapshot<List<dynamic>> snapshot) {
                                if (ubicacionactual == null && !esFletero) {
                                  // Aseguramos que snapshot tiene datos válidos antes de proceder
                                  if (!snapshot.hasData ||
                                      snapshot.data == null ||
                                      snapshot.data!.isEmpty) {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFFFFF0C6),
                                      ),
                                    );
                                  }

                                  final bodegaOrigen =
                                      snapshot.data![0] as BodegaViewModel?;
                                  final destinoData = snapshot.data![1];

                                  if (bodegaOrigen == null ||
                                      destinoData == null) {
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
                                  return Center(
                                    child: GoogleMap(
                                      initialCameraPosition: CameraPosition(
                                        target: inicio,
                                        zoom: 13,
                                      ),
                                      markers: {
                                        Marker(
                                          markerId:
                                              const MarkerId('sourceLocation'),
                                          icon: BitmapDescriptor.defaultMarker,
                                          position: inicio!,
                                        ),
                                        Marker(
                                          markerId: const MarkerId(
                                              'destinationLocation'),
                                          icon: BitmapDescriptor.defaultMarker,
                                          position: destino!,
                                        )
                                      },
                                      polylines:
                                          Set<Polyline>.of(polylines.values),
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
                                      color: ui.Color.fromARGB(255, 232, 232, 231),
                                    ),
                                  );
                                } else {
                                  final bodegaOrigen =
                                      snapshot.data![0] as BodegaViewModel?;
                                  final destinoData = snapshot.data![1];

                                  if (bodegaOrigen == null ||
                                      destinoData == null) {
                                    return Center(
                                      child: Text(
                                        'No se encontraron ubicaciones válidas',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }

                                  LatLng? inicio = obtenerCoordenadasDeEnlace(
                                      bodegaOrigen.bodeLinkUbicacion!);
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
                                      target: ubicacionactual ?? inicio!,
                                      zoom: 13,
                                    ),
                                    markers: {
                                      if (ubicacionactual != null)
                                        Marker(
                                          markerId:
                                              const MarkerId('currentLocation'),
                                          icon: carritoIcono ??
                                              BitmapDescriptor.defaultMarker,
                                          position: ubicacionactual!,
                                        ),
                                      Marker(
                                        markerId:
                                            const MarkerId('sourceLocation'),
                                        icon: BitmapDescriptor.defaultMarker,
                                        position: inicio!,
                                      ),
                                      Marker(
                                        markerId: const MarkerId(
                                            'destinationLocation'),
                                        icon: BitmapDescriptor.defaultMarker,
                                        position: destino!,
                                      )
                                    },
                                    polylines:
                                        Set<Polyline>.of(polylines.values),
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
                                setState(() => expandido = expanding),
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
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          );
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return Center(
                                            child: Text(
                                              'No se encontraron materiales para el flete.',
                                              style: TextStyle(
                                                  color: Colors.black),
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
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          'Materiales',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          'Cantidad',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  ...detalles.map((detalle) {
                                                    return TableRow(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            detalle.insuDescripcion ??
                                                                detalle
                                                                    .equsDescripcion!,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                            detalle.fldeCantidad
                                                                .toString(),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black),
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
        print('ubi actial $ubicacionactual');
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
    print('resultado polylinePuntos: $result');
    print('estado: ${result.status}');
    print('Error : ${result.errorMessage}');
    print('numero de puntos: ${result.points.length}');

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

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '--------';
    }
    return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
  }
}
