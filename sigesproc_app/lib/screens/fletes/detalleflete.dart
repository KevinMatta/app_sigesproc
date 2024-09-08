import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigesproc_app/consts.dart';
import 'package:sigesproc_app/models/acceso/usuarioviewmodel.dart';
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/models/fletes/fletedetalleviewmodel.dart';
import 'package:sigesproc_app/models/insumos/bodegaviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/acceso/notificacion.dart';
import 'package:sigesproc_app/screens/acceso/perfil.dart';
import 'package:sigesproc_app/screens/appBar.dart';
import 'package:sigesproc_app/screens/menu.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';
import 'package:sigesproc_app/services/acceso/usuarioservice.dart';
import 'package:sigesproc_app/services/bloc/notifications_bloc.dart';
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
  int _unreadCount = 0;
  int? userId;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadUserId();

    _loadUserProfileData();
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadUserId() async {
    var prefs = PreferenciasUsuario();
    userId = int.tryParse(prefs.userId) ?? 0;

    _insertarToken();

    context
        .read<NotificationsBloc>()
        .add(InitializeNotificationsEvent(userId: userId!));

    _loadNotifications();
  }

  Future<void> _insertarToken() async {
    var prefs = PreferenciasUsuario();
    String? token = prefs.token;

    if (token != null && token.isNotEmpty) {
      await NotificationServices.insertarToken(userId!, token);
      print('Token insertado después del inicio de sesión: $token');
    } else {
      print('No se encontró token en las preferencias.');
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications =
          await NotificationServices.BuscarNotificacion(userId!);
      setState(() {
        _unreadCount = notifications.where((n) => n.leida == "No Leida").length;
      });
    } catch (e) {
      print('Error al cargar notificaciones: $e');
    }
  }

  // Nueva función para cargar datos del usuario
  Future<void> _loadUserProfileData() async {
    var prefs = PreferenciasUsuario();
    int usua_Id = int.tryParse(prefs.userId) ?? 0;

    try {
      UsuarioViewModel usuario = await UsuarioService.Buscar(usua_Id);

      print('Datos del usuario cargados: ${usuario.usuaUsuario}');
    } catch (e) {
      print("Error al cargar los datos del usuario: $e");
    }
  }

  Future<void> _loadEmplId() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      emplId = int.tryParse(pref.getString('emplId') ?? '');
      // emplId = 91;
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
      setState(() {
        estaCargando = false;
      });
      return;
    }

    esFletero = flete.emtrId == emplId;

    // Obtener la Polyline roja almacenada desde el servidor
    List<LatLng>? polylineAlmacenada =
        await _fleteHubService.obtenerPolyline(flete.emtrId!); // Cambia a flete.emtrId para cargar la polyline del fletero

    if (polylineAlmacenada != null && polylineAlmacenada.isNotEmpty) {
      print('Polyline almacenada obtenida.');
      setState(() {
        polylines[PolylineId('realPolyline')] = Polyline(
          polylineId: PolylineId('realPolyline'),
          color: Colors.red,
          points: polylineAlmacenada,
          width: 5,
        );
      });
    } else {
      print('No se recibieron coordenadas para la Polyline.');
    }

    // Si es fletero, seguir obteniendo la ubicación en tiempo real y actualizando la polyline
    if (esFletero && flete.flenEstado == false) {
      print('Obteniendo la ubicación actual para el fletero...');
      bool ubicacionObtenida = await ubicacionActualizada();
      if (!ubicacionObtenida) {
        print("No se pudo obtener la ubicación actual.");
        setState(() {
          estaCargando = false;
        });
        return;
      }
      print("Ubicación obtenida: $ubicacionactual");
      final pref = await SharedPreferences.getInstance();
        final latitudInicial = pref.getDouble('latitudInicial');
        final longitudInicial = pref.getDouble('longitudInicial');

        if (latitudInicial != null && longitudInicial != null) {
          ubicacionInicial = LatLng(latitudInicial, longitudInicial);
          print(
              'Ubicación inicial cargada desde SharedPreferences: $ubicacionInicial');
        }

        // Guardar la ubicación inicial solo si no ha sido almacenada previamente
        if (ubicacionInicial == null) {
          ubicacionInicial = ubicacionactual;
          print('Guardando la ubicación inicial: $ubicacionInicial');
          await pref.setDouble('latitudInicial', ubicacionInicial!.latitude);
          await pref.setDouble('longitudInicial', ubicacionInicial!.longitude);
        }

      // Actualizar la polyline en tiempo real
      locationSubscription = ubicacionController.onLocationChanged.listen((LocationData currentLocation) async {
        if (currentLocation.latitude != null && currentLocation.longitude != null) {
          LatLng nuevaUbicacion = LatLng(currentLocation.latitude!, currentLocation.longitude!);
          print('Nueva ubicación recibida: $nuevaUbicacion');
          await _actualizarPolyline(ubicacionInicial!, nuevaUbicacion, Colors.red, 'realPolyline');
          setState(() {
            ubicacionactual = nuevaUbicacion;
          });
        }
      });
    }

    // Cuando todo haya cargado correctamente, detener el spinner
    setState(() {
      estaCargando = false;
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

  void onReceiveUbicacion(int emplId, double lat, double lng) async {
    final flete =
        await FleteEncabezadoService.obtenerFleteDetalle(widget.flenId);

    if (flete == null || flete.flenEstado == true) {
      print(
          'El flete ya ha sido recibido, deteniendo la actualización de la polyline.');
      // Detenemos el rastreo en tiempo real si el flete ya fue recibido
      locationSubscription?.cancel();
      return;
    }

    LatLng nuevaUbicacion = LatLng(lat, lng);
    print("Ubicación recibida: EmplId: $emplId, Lat: $lat, Lng: $lng");

    setState(() {
      if (emplId != this.emplId) {
        polylines[PolylineId('realPolyline')]?.points.add(nuevaUbicacion);
      }
      ubicacionactual = nuevaUbicacion;
    });
  }

  Future<void> _actualizarPolyline(
      LatLng inicio, LatLng nuevaUbicacion, Color color, String id) async {
    final polylineId = PolylineId(id);

    // Usar la API de Polyline para obtener los puntos intermedios entre inicio y nuevaUbicacion
    final polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      gmak, // Tu API key de Google
      PointLatLng(inicio.latitude, inicio.longitude),
      PointLatLng(nuevaUbicacion.latitude, nuevaUbicacion.longitude),
      travelMode: TravelMode.driving,
    );

    print(
        'Intentando actualizar Polyline con inicio: $inicio, nuevaUbicacion: $nuevaUbicacion');

    // Si se obtuvieron puntos intermedios, los usamos para actualizar la Polyline
    if (result.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      print(
          'Polyline actualizada con puntos: $polylineCoordinates'); // Añade este print

      setState(() {
        polylines[polylineId] = Polyline(
          polylineId: polylineId,
          color: color,
          points: polylineCoordinates, // Usar la lista de puntos obtenidos
          width: 5,
        );
      });

      // Convertir las coordenadas a dos listas de latitudes y longitudes
      List<double> latitudes =
          polylineCoordinates.map((point) => point.latitude).toList();
      List<double> longitudes =
          polylineCoordinates.map((point) => point.longitude).toList();

      // Enviar las listas de coordenadas al servidor
      await _fleteHubService.actualizarPolyline(emplId!, latitudes, longitudes);
    } else {
      print("Error obteniendo ruta entre puntos: ${result.errorMessage}");
      setState(() {
        estaCargando =
            false; // Detén el spinner si hay error en la obtención de puntos
      });
    }
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
              height: 50,
            ),
            SizedBox(width: 2),
            Expanded(
              child: Text(
                'SIGESPROC',
                style: TextStyle(
                  color: Color(0xFFFFF0C6),
                  fontSize: 20,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(70.0),
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
              SizedBox(height: 5),
              if (!estaCargando)
                Row(
                  children: [
                    SizedBox(width: 5.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0), // Padding superior de 10 píxeles
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_back,
                              color: Color(0xFFFFF0C6),
                            ),
                            SizedBox(width: 3.0),
                            Text(
                              'Regresar',
                              style: TextStyle(
                                color: Color(0xFFFFF0C6),
                                fontSize: 15.0,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 20.0),
            ],
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFFFF0C6)),
        actions: <Widget>[
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.notifications),
                if (_unreadCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$_unreadCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificacionesScreen(),
                ),
              );
              _loadNotifications();
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: MenuLateral(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
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
                                      color:
                                          ui.Color.fromARGB(255, 232, 232, 231),
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
                                padding: const EdgeInsets.all(15.0),
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
                                      'Supervisor Salida: ${flete.supervisorSalida}',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Supervisor Llegada: ${flete.supervisorLlegada}',
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
