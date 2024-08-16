import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sigesproc_app/models/insumos/articuloviewmodel.dart';
import 'package:sigesproc_app/models/insumos/cotizacionviewmodel.dart';
import 'package:sigesproc_app/services/insumos/articuloservice.dart';
import '../menu.dart';
import 'package:sigesproc_app/services/insumos/cotizacionservice.dart';

class Cotizacion extends StatefulWidget {
  @override
  _CotizacionState createState() => _CotizacionState();
}

class _CotizacionState extends State<Cotizacion> {
  int _selectedIndex = 3;
  Future<List<CotizacionViewModel>>? _cotizacionesFuture;
  Future<List<ArticuloViewModel>>? _articulosFuture;
  TextEditingController _searchController = TextEditingController();
  List<CotizacionViewModel> _cotizacionesFiltrados = [];
  bool _mostrarArticulos = false;
  int? _selectedCotiId;
  int _currentPage = 0;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _cotizacionesFuture = CotizacionService.listarCotizaciones();
    _cotizacionesFuture!.then((cotizaciones) {
      setState(() {
        _cotizacionesFiltrados = cotizaciones;
      });
    });
    _searchController.addListener(_filterCotizaciones);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCotizaciones() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _cotizacionesFiltrados = _cotizacionesFiltrados.where((cotizacion) {
        final salida = cotizacion.provDescripcion?.toLowerCase() ?? '';
        return salida.contains(query);
      }).toList();

      final totalRecords = _cotizacionesFiltrados.length;
      final maxPages = (totalRecords / _rowsPerPage).ceil();

      if (_currentPage >= maxPages) {
        _currentPage = maxPages - 1;
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _reiniciarCotizacionesFiltros() {
    setState(() {
      _cotizacionesFiltrados = [];
    });
    _cargarCotizaciones();
  }

  void _cargarCotizaciones() {
    _cotizacionesFuture = CotizacionService.listarCotizaciones();
    _cotizacionesFuture!.then((cotizaciones) {
      setState(() {
        _cotizacionesFiltrados = cotizaciones;
      });
    });
  }

  void _verArticulos(int cotiId) {
    setState(() {
      _mostrarArticulos = true;
      _selectedCotiId = cotiId;
      print('cotiid: $cotiId');
      _articulosFuture = ArticuloService.ListarArticulosPorCotizacion(cotiId);
    });
  }

  TableRow _buildCotizacionRow(CotizacionViewModel cotizacion, int index) {
    return TableRow(
      children: [
        // Acciones primero
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.info_outline, color: Colors.white),
              onPressed: () => _verArticulos(cotizacion.cotiId),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              (index + 1).toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Cotización ${cotizacion.cotiId}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              cotizacion.provDescripcion ?? 'N/A',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }

  void _previousPage() {
    setState(() {
      if (_currentPage > 0) {
        _currentPage--;
      }
    });
  }

  void _nextPage() {
    setState(() {
      if (_cotizacionesFiltrados.length > (_currentPage + 1) * _rowsPerPage) {
        _currentPage++;
      }
    });
  }

  Widget ArticuloRegistro(ArticuloViewModel articulo) {
    bool isExpanded = false;
    print('dentro: $articulo');

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return ExpansionTile(
          leading: CircleAvatar(
            child: Text(
              articulo.codigo.toString(),
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Color(0xFFFFF0C6),
          ),
          title: Text(
            articulo.articulo,
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            'Precio: ${articulo.precio}',
            style: TextStyle(color: Colors.white70),
          ),
          trailing: Icon(
            isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
            color: Colors.white,
          ),
          children: <Widget>[
            ListTile(
              title: Text(
                'Cantidad: ${articulo.cantidad}',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Subtotal: ${articulo.subtotal}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Impuesto: ${articulo.impuesto}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Total: ${articulo.total}',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
          onExpansionChanged: (bool expanded) {
            setState(() => isExpanded = expanded);
          },
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
                _mostrarArticulos ? 'Articulos' : 'Cotizaciones',
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
      drawer: MenuLateral(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            Card(
              color: Color(0xFF171717),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Buscar.....',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                          icon: Icon(Icons.search, color: Colors.white54),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.filter_list, color: Colors.white54),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _mostrarArticulos
                  ? FutureBuilder<List<ArticuloViewModel>>(
                      future: _articulosFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: SpinKitCircle(color: Color(0xFFFFF0C6)),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error al cargar los datos',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No hay datos disponibles',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        } else {
                          return ListView.builder(
                            padding: EdgeInsets.only(bottom: 80.0),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return ArticuloRegistro(snapshot.data![index]);
                            },
                          );
                        }
                      },
                    )
                  : FutureBuilder<List<CotizacionViewModel>>(
                      future: _cotizacionesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: SpinKitCircle(color: Color(0xFFFFF0C6)),
                          );
                        } else if (snapshot.hasError) {
                          print('tiene error $snapshot');
                          return Center(
                            child: Text(
                              'Error al cargar los datos',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No hay datos disponibles',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        } else {
                          _cotizacionesFiltrados =
                              _searchController.text.isEmpty
                                  ? snapshot.data!
                                  : _cotizacionesFiltrados;
                          final int totalRecords =
                              _cotizacionesFiltrados.length;
                          final int startIndex = _currentPage * _rowsPerPage;
                          final int endIndex =
                              (startIndex + _rowsPerPage > totalRecords)
                                  ? totalRecords
                                  : startIndex + _rowsPerPage;

                          return Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Table(
                                    columnWidths: {
                                      0: FlexColumnWidth(
                                          2), // Ajusta el ancho de la columna de acciones
                                      1: FlexColumnWidth(1),
                                      2: FlexColumnWidth(3),
                                      3: FlexColumnWidth(3),
                                    },
                                    children: [
                                      TableRow(
                                        decoration: BoxDecoration(
                                          color: Color(0xFF171717),
                                        ),
                                        children: [
                                          // Encabezado para las acciones
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Artículos',
                                              style: TextStyle(
                                                color: Color(0xFFFFF0C6),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'No.',
                                              style: TextStyle(
                                                color: Color(0xFFFFF0C6),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Descripción',
                                              style: TextStyle(
                                                color: Color(0xFFFFF0C6),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Proveedor',
                                              style: TextStyle(
                                                color: Color(0xFFFFF0C6),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      ..._cotizacionesFiltrados
                                          .sublist(startIndex, endIndex)
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final index = entry.key;
                                        final cotizacion = entry.value;
                                        return _buildCotizacionRow(
                                            cotizacion, startIndex + index);
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Mostrando ${startIndex + 1} al ${endIndex} de $totalRecords entradas',
                                style: TextStyle(color: Colors.white),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: _previousPage,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward),
                                    onPressed: _nextPage,
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
            ),
            Visibility(
              visible: _mostrarArticulos,
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF171717),
                        padding:
                            EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedCotiId = null;
                          _reiniciarCotizacionesFiltros();
                          _mostrarArticulos = false;
                        });
                      },
                      child: Text(
                        'Regresar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
