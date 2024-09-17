import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sigesproc_app/models/acceso/usuarioviewmodel.dart';
import 'package:sigesproc_app/models/bienesraices/terrenoviewmodel.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/acceso/notificacion.dart';
import 'package:sigesproc_app/screens/acceso/perfil.dart';
import 'package:sigesproc_app/screens/menu.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';
import 'package:sigesproc_app/services/acceso/usuarioservice.dart';
import 'package:sigesproc_app/services/apiservice.dart';
import 'package:sigesproc_app/services/bienesraices/procesoventaservice.dart';
import 'package:sigesproc_app/services/bloc/notifications_bloc.dart';

class TerrenosMap extends StatefulWidget {
  @override
  _TerrenosMapState createState() => _TerrenosMapState();
}

class _TerrenosMapState extends State<TerrenosMap> {
  late Future<List<TerrenosViewModel>> _terrenosFuture;
  List<Marker> _markers = [];
  int _unreadCount = 0;
  int? userId;
  late GoogleMapController _mapController;
    int _selectedIndex = 2;


  @override
  void initState() {
    super.initState();
    _loadUserId(); 

    _loadUserProfileData();
    _terrenosFuture = _fetchTerrenos();
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

    context.read<NotificationsBloc>().add(InitializeNotificationsEvent(userId: userId!));

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
      final notifications = await NotificationServices.BuscarNotificacion(userId!);
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

  Future<List<TerrenosViewModel>> _fetchTerrenos() async {
    try {
      List<TerrenosViewModel> terrenos =
          await ProcesoVentaService.listarTerrenos();
      return terrenos;
    } catch (e) {
      print('Error fetching terrenos: $e');
      return [];
    }
  }

  Future<LatLng?> _obtenerCoordenadasDeEnlace(String? enlace) async {
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

  Future<void> _addDynamicMarkers(List<TerrenosViewModel> terrenos) async {
    final colors = [BitmapDescriptor.hueRed, BitmapDescriptor.hueGreen];
    final firstFiveTerrenos = terrenos.take(5).toList();

    for (var i = 0; i < firstFiveTerrenos.length; i++) {
      final terreno = firstFiveTerrenos[i];
      final coordinates =
          await _obtenerCoordenadasDeEnlace(terreno.terrLinkUbicacion);
      if (coordinates != null) {
        final color = terreno.terrEstado == true ? colors[0] : colors[1];
        _addMarker(coordinates, color, terreno);
      }
    }
    setState(() {});
  }

  void _addMarker(LatLng coordinates, double color, TerrenosViewModel details) {
    final marker = Marker(
      markerId: MarkerId(details.terrDescripcion ?? 'Terreno'),
      position: coordinates,
      icon: BitmapDescriptor.defaultMarkerWithHue(color),
      onTap: () {
        _showDetailsPopup(context, coordinates, details);
      },
    );
    _markers.add(marker);
  }

  void _showDetailsPopup(
      BuildContext context, LatLng coordinates, TerrenosViewModel details) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black, // Fondo negro
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Descripción: ${details.terrDescripcion ?? 'Desconocida'}',
                style: TextStyle(
                  color: Color(0xFFFFF0C6),
                  fontWeight: FontWeight.bold, // Títulos en negrita
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Coordenadas: ${coordinates.latitude.toStringAsFixed(4)}, ${coordinates.longitude.toStringAsFixed(4)}',
                style: TextStyle(
                  color: Color(0xFFFFF0C6),
                  fontWeight: FontWeight.bold, // Títulos en negrita
                ),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight, // Alineación a la derecha
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cerrar',
                    style: TextStyle(
                      color: Color(0xFFFFF0C6),
                      fontWeight: FontWeight.bold, // Texto del botón en negrita
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
          preferredSize: Size.fromHeight(80.0),
          child: Column(
            children: [
              Text(
                'Ubicación de Terrenos',
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
                Row(
                  children: [
                    SizedBox(width: 5.0),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10.0), 
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
      body: Container(
        color: Colors.black,
        child: FutureBuilder<List<TerrenosViewModel>>(
          future: _terrenosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFF0C6),
                ),
              );
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'Error al cargar terrenos',
                  style: TextStyle(color: Colors.red),
                ),
              );
            } else {
              final terrenos = snapshot.data!;
              _addDynamicMarkers(terrenos);
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target:
                      LatLng(14.52, -86.64), 
                  zoom: 7, 
                ),
                markers: Set<Marker>.of(_markers),
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
              );
            }
          },
        ),
      ),
    );
  }
}
