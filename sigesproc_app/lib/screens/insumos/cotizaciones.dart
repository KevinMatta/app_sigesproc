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

  @override
  void initState() {
    super.initState();
    _cotizacionesFuture = CotizacionService.listarCotizaciones();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Widget CotizacionRegistro(CotizacionViewModel cotizacion, int index) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          cotizacion.codigo.toString(),
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFFFF0C6),
      ),
      title: Text(
        'Cotización ${cotizacion.cotiId}',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        'Proveedor: ${cotizacion.provDescripcion ?? 'N/A'}',
        style: TextStyle(color: Colors.white70),
      ),
      trailing: IconButton(
        icon: Icon(Icons.info_outline, color: Colors.white),
        onPressed: () => _verArticulos(cotizacion.cotiId),
      ),
    );
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
                          return ListView.builder(
                            padding: EdgeInsets.only(bottom: 80.0),
                            itemCount: _cotizacionesFiltrados.isEmpty
                                ? snapshot.data!.length
                                : _cotizacionesFiltrados.length,
                            itemBuilder: (context, index) {
                              return CotizacionRegistro(
                                  _cotizacionesFiltrados.isEmpty
                                      ? snapshot.data![index]
                                      : _cotizacionesFiltrados[index],
                                  index);
                            },
                          );
                        }
                      },
                    ),
            ),
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Spacer(),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF171717),
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedCotiId = null;
                        _reiniciarCotizacionesFiltros(); // Reiniciar la lista y recargar los datos
                        _mostrarArticulos = false;
                      });
                    },
                    child: Text(
                      'Regresar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
