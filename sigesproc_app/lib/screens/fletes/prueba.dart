import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

const MAPBOX_ACCESS_TOKEN =
    'pk.eyJ1Ijoic2V1Y2VkYWEiLCJhIjoiY2x6b28zYWRtMTRvYTJ5b3Bjd3ExN3Y5YyJ9.zX-cUTaYADoXEfN0mBKlXg';

class MapaPrueba extends StatefulWidget {
  const MapaPrueba({super.key});

  @override
  State<MapaPrueba> createState() => _MapaPruebaState();
}

class _MapaPruebaState extends State<MapaPrueba> {
  LatLng? myPosition;
  final MapController _mapController = MapController(); // Controlador del mapa

  Future<Position> determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('error');
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  void getCurrentLocation() async {
    Position position = await determinePosition();
    setState(() {
      myPosition = LatLng(position.latitude, position.longitude);
      print(myPosition);
    });
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  void _zoomIn() {
    _mapController.move(_mapController.center, _mapController.zoom + 1);
  }

  void _zoomOut() {
    _mapController.move(_mapController.center, _mapController.zoom - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Mapa'),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder<Position>(
        future: determinePosition(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final position = snapshot.data!;
            final myPosition = LatLng(position.latitude, position.longitude);
            return Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                      center: myPosition, minZoom: 5, maxZoom: 25, zoom: 18),
                  nonRotatedChildren: [
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
                        Marker(
                          point: myPosition,
                          builder: (context) {
                            return const Icon(
                              Icons.person_pin,
                              color: Colors.blueAccent,
                              size: 40,
                            );
                          },
                        )
                      ],
                    )
                  ],
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Column(
                    children: [
                      FloatingActionButton(
                        onPressed: _zoomIn,
                        child: Icon(Icons.zoom_in),
                      ),
                      SizedBox(height: 10),
                      FloatingActionButton(
                        onPressed: _zoomOut,
                        child: Icon(Icons.zoom_out),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return Center(child: Text('No se pudo obtener la ubicación.'));
        },
      ),
    );
  }
}
