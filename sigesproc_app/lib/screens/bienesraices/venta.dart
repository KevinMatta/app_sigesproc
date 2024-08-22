import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:latlong2/latlong.dart';
import 'package:sigesproc_app/models/bienesraices/procesoventaviewmodel.dart';
import 'package:sigesproc_app/services/bienesraices/procesoventaservice.dart';


class VentaBienRaiz extends StatefulWidget {
  final int btrpId;
  final int btrpTerrenoOBienRaizId;
  final int btrpBienoterrenoId;

  VentaBienRaiz({
    required this.btrpId,
    required this.btrpTerrenoOBienRaizId,
    required this.btrpBienoterrenoId,
  });

  @override
  _VentaBienRaizState createState() => _VentaBienRaizState();
}

class _VentaBienRaizState extends State<VentaBienRaiz> {
  late Future<LatLng?> _destinoFuture;

  @override
  void initState() {
    super.initState();
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
              height: 50, // Ajusta la altura si es necesario
            ),
            SizedBox(width: 2), // Reduce el espacio entre el logo y el texto
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
          preferredSize: Size.fromHeight(40.0),
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
        child: FutureBuilder<LatLng?>(
          future: _destinoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SpinKitCircle(
                  color: Color(0xFFFFF0C6),
                ),
              );
            } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text(
                  'Error al cargar ubicación',
                  style: TextStyle(color: Colors.red),
                ),
              );
            } else {
              final destino = snapshot.data!;
              return FlutterMap(
                options: MapOptions(
                  center: destino,
                  zoom: 14,
                ),
                children: [
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: destino,
                        builder: (context) => Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
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