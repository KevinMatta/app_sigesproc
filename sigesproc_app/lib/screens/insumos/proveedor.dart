import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sigesproc_app/models/insumos/proveedorviewmodel.dart';
import 'package:sigesproc_app/models/insumos/cotizacionviewmodel.dart';
import 'package:sigesproc_app/screens/fletes/nuevoflete.dart';
import 'package:sigesproc_app/services/insumos/proveedorservice.dart';
import 'package:sigesproc_app/services/insumos/cotizacionservice.dart';
import '../menu.dart';

class Proveedor extends StatefulWidget {
  @override
  _ProveedorState createState() => _ProveedorState();
}

class _ProveedorState extends State<Proveedor> {
  int _selectedIndex = 3;
  Future<List<ProveedorViewModel>>? _proveedoresFuture;
  Future<List<CotizacionViewModel>>? _cotizacionesFuture;
  TextEditingController _searchController = TextEditingController();
  List<ProveedorViewModel> _filteredProveedores = [];
  List<ProveedorViewModel> _proveedores = [];
  bool _showCotizaciones = false;
  String _selectedProveedorDescripcion = '';

  @override
  void initState() {
    super.initState();
    _proveedoresFuture = ProveedorService.listarProveedores();
    _searchController.addListener(_filterProveedores);
    _cargarProveedores();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProveedores);
    _searchController.dispose();
    super.dispose();
  }

  void _cargarProveedores() {
    _proveedoresFuture!.then((proveedores) {
      setState(() {
        _proveedores = proveedores;
        _filteredProveedores = proveedores;
      });
    });
  }

  void _filterProveedores() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProveedores = _proveedores.where((proveedor) {
        final descripcion = proveedor.provDescripcion?.toLowerCase() ?? '';
        return descripcion.contains(query);
      }).toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _verCotizaciones(int provId, String provDescripcion) {
    setState(() {
      _showCotizaciones = true;
      _selectedProveedorDescripcion = provDescripcion;
      print(provId);
      _cotizacionesFuture = CotizacionService.listarCotizacionesPorProveedor(provId);
    });
  }

  Widget ProveedorRegistro(ProveedorViewModel proveedor) {
    bool isExpanded = false;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return ExpansionTile(
          leading: CircleAvatar(
            child: Text(
              proveedor.codigo.toString(),
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Color(0xFFFFF0C6),
          ),
          title: Text(
            proveedor.provDescripcion ?? 'N/A',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            'Teléfono: ${proveedor.provTelefono ?? 'N/A'}',
            style: TextStyle(color: Colors.white70),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.info_outline, color: Colors.white),
                onPressed: () => _verCotizaciones(proveedor.provId, proveedor.provDescripcion!),
              ),
              Icon(
                isExpanded ? Icons.arrow_drop_down : Icons.arrow_left,
                color: Colors.white,
              ),
            ],
          ),
          children: <Widget>[
            ListTile(
              title: Text(
                'Correo: ${proveedor.provCorreo}',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tel Alternativo: ${proveedor.provSegundoTelefono}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Ciudad: ${proveedor.ciudDescripcion}',
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

  Widget CotizacionRegistro(CotizacionViewModel cotizacion) {
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
        'Fecha: ${cotizacion.cotiFecha != null ? cotizacion.cotiFecha! : 'N/A'}\nTotal: ${cotizacion.total}',
        style: TextStyle(color: Colors.white70),
      ),
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
            SizedBox(width: 10),
            Text(
              'SIGESPROC',
              style: TextStyle(color: Color(0xFFFFF0C6)),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: Column(
            children: [
              Text(
                _showCotizaciones ? 'Cotizaciones a $_selectedProveedorDescripcion' : 'Proveedores',
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
            if (!_showCotizaciones) ...[
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
                            hintText: 'Buscar...',
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
            ],
            SizedBox(height: 10),
            Expanded(
              child: _showCotizaciones
                  ? FutureBuilder<List<CotizacionViewModel>>(
                      future: _cotizacionesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: SpinKitCircle(color: Color(0xFFFFF0C6)),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error al cargar los datos: ${snapshot.error}',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                              return CotizacionRegistro(snapshot.data![index]);
                            },
                          );
                        }
                      },
                    )
                  : FutureBuilder<List<ProveedorViewModel>>(
                      future: _proveedoresFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: SpinKitCircle(color: Color(0xFFFFF0C6)),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error al cargar los datos: ${snapshot.error}',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No hay datos disponibles',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        } else {
                          return ListView.builder(
                            padding: EdgeInsets.only(bottom: 80.0),
                            itemCount: _filteredProveedores.length,
                            itemBuilder: (context, index) {
                              return ProveedorRegistro(_filteredProveedores[index]);
                            },
                          );
                        }
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _showCotizaciones
    ? FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _showCotizaciones = false;
          });
        },
        label: Text('Regresar'),
        backgroundColor: Colors.black,
        foregroundColor: Color(0xFFFFF0C6),
      )
    : null,

    );
  }
}
