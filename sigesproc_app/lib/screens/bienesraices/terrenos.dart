import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sigesproc_app/models/bienesraices/terrenoviewmodel.dart';
import 'package:sigesproc_app/services/apiservice.dart';
import 'package:sigesproc_app/services/bienesraices/procesoventaservice.dart';

const MAPBOX_TOKEN = ApiService.mapboxTokenFM;

class TerrenosMap extends StatefulWidget {
  @override
  _TerrenosMapState createState() => _TerrenosMapState();
}

class _TerrenosMapState extends State<TerrenosMap> {
  late Future<List<TerrenosViewModel>> _terrenosFuture;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _terrenosFuture = _fetchTerrenos();
  }

  Future<List<TerrenosViewModel>> _fetchTerrenos() async {
    try {
      List<TerrenosViewModel> terrenos = await ProcesoVentaService.listarTerrenos();
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
    final colors = ['#FF0000', '#00FF00'];
    final firstFiveTerrenos = terrenos.take(5).toList();

    for (var i = 0; i < firstFiveTerrenos.length; i++) {
      final terreno = firstFiveTerrenos[i];
      final coordinates = await _obtenerCoordenadasDeEnlace(terreno.terrLinkUbicacion);
      if (coordinates != null) {
        final color = terreno.terrEstado == true ? colors[0] : colors[1];
        _addMarker(coordinates, color, terreno);
        await Future.delayed(Duration(seconds: 1));
      }
    }
    setState(() {});
  }

  void _addMarker(LatLng coordinates, String color, TerrenosViewModel details) {
    final marker = Marker(
      point: coordinates,
      builder: (context) => GestureDetector(
        onTap: () {
          _showDetailsPopup(context, coordinates, details);
        },
        child: Icon(
          Icons.location_on,
          color: Color(int.parse(color.replaceAll('#', '0xFF'))),
          size: 40,
        ),
      ),
    );
    _markers.add(marker);
  }

 void _showDetailsPopup(BuildContext context, LatLng coordinates, TerrenosViewModel details) {
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
          preferredSize: Size.fromHeight(40.0),
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
        child: FutureBuilder<List<TerrenosViewModel>>(
          future: _terrenosFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SpinKitCircle(
                  color: Color(0xFFFFF0C6),
                ),
              );
            } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'Error al cargar terrenos',
                  style: TextStyle(color: Colors.red),
                ),
              );
            } else {
              final terrenos = snapshot.data!;
              _addDynamicMarkers(terrenos);
              return FlutterMap(
                options: MapOptions(
                  center: LatLng(15.5, -90.0), // Centra el mapa en América Central
                  zoom: 4, // Ajusta el zoom para mostrar América Central
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}',
                    additionalOptions: const {
                      'accessToken': MAPBOX_TOKEN,
                      'id': 'mapbox/streets-v12'
                    },
                  ),
                  MarkerLayer(
                    markers: _markers,
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
