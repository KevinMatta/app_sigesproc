import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sigesproc_app/models/acceso/usuarioviewmodel.dart';
import 'package:sigesproc_app/models/bienesraices/procesoventaviewmodel.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/acceso/notificacion.dart';
import 'package:sigesproc_app/screens/acceso/perfil.dart';
import 'package:sigesproc_app/screens/menu.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';
import 'package:sigesproc_app/services/acceso/usuarioservice.dart';
import 'package:sigesproc_app/services/bienesraices/procesoventaservice.dart';
import 'package:sigesproc_app/services/bloc/notifications_bloc.dart';

class UbicacionBienRaiz extends StatefulWidget {
  final int btrpId;
  final int btrpTerrenoOBienRaizId;
  final int btrpBienoterrenoId;

  UbicacionBienRaiz({
    required this.btrpId,
    required this.btrpTerrenoOBienRaizId,
    required this.btrpBienoterrenoId,
  });

  @override
  _UbicacionBienRaizState createState() => _UbicacionBienRaizState();
}

class _UbicacionBienRaizState extends State<UbicacionBienRaiz> {
  late Future<LatLng?> _destinoFuture;
  int _unreadCount = 0;
  int? userId;
  GoogleMapController? _mapController;
  Marker? _marker;
  int _selectedIndex = 4;

  @override
  void initState() {
    super.initState();
    _loadUserId(); 
    _loadUserProfileData();
    _destinoFuture = _fetchDestino(widget.btrpId);
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
    } else {
      // print('No se encontró token en las preferencias.');
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
      // print('Error al cargar notificaciones: $e');
    }
  }

  Future<void> _loadUserProfileData() async {
    var prefs = PreferenciasUsuario();
    int usua_Id = int.tryParse(prefs.userId) ?? 0;

    try {
      UsuarioViewModel usuario = await UsuarioService.Buscar(usua_Id);
    } catch (e) {
      // print("Error al cargar los datos del usuario: $e");
    }
  }

  Future<LatLng?> _fetchDestino(int btrpId) async {
    try {
      List<ProcesoVentaViewModel> procesos = await ProcesoVentaService.Buscar(
          widget.btrpId,
          widget.btrpTerrenoOBienRaizId,
          widget.btrpBienoterrenoId);

      if (procesos.isNotEmpty) {
        ProcesoVentaViewModel proceso = procesos.first;
        if (proceso.linkUbicacion != null) {
          return obtenerCoordenadasDeEnlace(proceso.linkUbicacion);
        }
      }
    } catch (e) {
      // print('Error fetching destino: $e');
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
                textAlign: TextAlign.start, // Alinea el texto a la izquierda
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(80.0),
          child: Column(
            children: [
              Text(
                'Ubicación Bien Raíz',
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
      body: Container(
        color: Colors.black,
        child: FutureBuilder<LatLng?>(
          future: _destinoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFF0C6),
                ),
              );
            } else if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return Center(
                child: Text(
                  'Error al cargar ubicación',
                  style: TextStyle(color: Colors.red),
                ),
              );
            } else {
              final destino = snapshot.data!;
              _marker = Marker(
                markerId: MarkerId("marker_1"),
                position: destino,
                infoWindow: InfoWindow(title: "Ubicación del Terreno"),
              );
              return GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: destino,
                  zoom: 14,
                ),
                markers: Set<Marker>.of([_marker!]),
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
}
