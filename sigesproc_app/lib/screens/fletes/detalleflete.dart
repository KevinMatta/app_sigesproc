import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/models/fletes/fletedetalleviewmodel.dart';
import 'package:sigesproc_app/models/insumos/bodegaviewmodel.dart';
import 'package:sigesproc_app/services/fletes/fletedetalleservice.dart';
import 'package:sigesproc_app/services/fletes/fleteencabezadoservice.dart';
import 'package:sigesproc_app/services/insumos/bodegaservice.dart';

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
  late Future<BodegaViewModel?> _bodegaDestinoFuture;

  @override
  void initState() {
    super.initState();
    print('DetalleFlete flenId: ${widget.flenId}');
    _fleteFuture = FleteEncabezadoService.obtenerFleteDetalle(widget.flenId);
    _detallesFuture = FleteDetalleService.listarDetallesdeFlete(widget.flenId);
    _bodegaOrigenFuture = _fetchBodegaOrigen(widget.flenId);
    _bodegaDestinoFuture = _fetchBodegaDestino(widget.flenId);
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return '--------';
    }
    return DateFormat('yyyy-MM-dd hh:mm a').format(dateTime);
  }

  Future<BodegaViewModel?> _fetchBodegaOrigen(int flenId) async {
    try {
      FleteEncabezadoViewModel? flete = await FleteEncabezadoService.obtenerFleteDetalle(flenId);
      print('Bodega origen bollId: ${flete?.bollId}');
      if (flete != null) {
        return await BodegaService.buscar(flete.bollId!);
      }
    } catch (e) {
      print('Error fetching bodega origen: $e');
    }
    return null;
  }

  Future<BodegaViewModel?> _fetchBodegaDestino(int flenId) async {
    try {
      FleteEncabezadoViewModel? flete = await FleteEncabezadoService.obtenerFleteDetalle(flenId);
      print('Bodega destino bodeId: ${flete?.boprId}');
      if (flete != null) {
        return await BodegaService.buscar(flete.boprId!);
      }
    } catch (e) {
      print('Error fetching bodega destino: $e');
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
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<FleteEncabezadoViewModel?>(
          future: _fleteFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
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
                children: [
                  FutureBuilder(
                    future: Future.wait([_bodegaOrigenFuture, _bodegaDestinoFuture]),
                    builder: (context, AsyncSnapshot<List<BodegaViewModel?>> bodegaSnapshot) {
                      if (bodegaSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFFF0C6),
                          ),
                        );
                      } else if (bodegaSnapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error al cargar los detalles de las bodegas',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (!bodegaSnapshot.hasData || bodegaSnapshot.data!.isEmpty) {
                        return Center(
                          child: Text(
                            'No se encontraron bodegas',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      } else {
                        final bodegaOrigen = bodegaSnapshot.data![0];
                        final bodegaDestino = bodegaSnapshot.data![1];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bodega Origen: ${bodegaOrigen?.bodeDescripcion ?? 'N/A'}',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            Text(
                              'Bodega Destino: ${bodegaDestino?.bodeDescripcion ?? 'N/A'}',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  Expanded(
                    child: Card(
                      color: Color(0xFF171717),
                      child: Container(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Mapa',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
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
}