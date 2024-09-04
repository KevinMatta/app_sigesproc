import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigesproc_app/models/viaticos/viaticoViewModel.dart';
import 'package:sigesproc_app/screens/viaticos/agregarfactura.dart';
import 'package:sigesproc_app/screens/viaticos/editarviatico.dart';
import 'package:sigesproc_app/screens/viaticos/nuevoviatico.dart';
import 'package:sigesproc_app/services/viaticos/viaticoservice.dart';
import '../menu.dart';

class Viatico extends StatefulWidget {
  @override
  _ViaticoState createState() => _ViaticoState();
}

class _ViaticoState extends State<Viatico> {
  int _selectedIndex = 5;
  Future<List<ViaticoEncViewModel>>? _viaticosFuture;
  TextEditingController _searchController = TextEditingController();
  List<ViaticoEncViewModel> _filteredViaticos = [];
  List<ViaticoEncViewModel> _allViaticos = [];
  int _currentPage = 0;
  int _rowsPerPage = 10;
  bool _isLoading = false;
  bool _usuarioEsAdm = false; // Inicializa como no administrador por defecto
  String? _usuaId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _searchController.addListener(_filterViaticos);
  }

  Future<void> _loadUserData() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    _usuaId = prefs.getString('usuaId') ?? '';

    // Manejar la conversión de String a bool si es necesario
    dynamic esAdminValue = prefs.get('EsAdmin');
    if (esAdminValue is bool) {
      _usuarioEsAdm = esAdminValue;
    } else if (esAdminValue is String) {
      // Convertir el String "true" o "false" en bool
      _usuarioEsAdm = esAdminValue.toLowerCase() == 'true';
    } else {
      _usuarioEsAdm = false; // Valor por defecto si no está definido
    }
  });
  _cargarViaticos();
}


  void _cargarViaticos() {
    setState(() {
      _isLoading = true;
    });

    _viaticosFuture = ViaticosEncService.listarViaticos(int.parse(_usuaId!));
    _viaticosFuture!.then((viaticos) {
      setState(() {
        _allViaticos = viaticos;
        _filteredViaticos = viaticos;
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterViaticos);
    _searchController.dispose();
    super.dispose();
  }

  void _filterViaticos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredViaticos = _allViaticos.where((viatico) {
        final proyecto = viatico.proyecto?.toLowerCase() ?? '';
        return proyecto.contains(query);
      }).toList();

      final totalRecords = _filteredViaticos.length;
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

  void _previousPage() {
    setState(() {
      if (_currentPage > 0) {
        _currentPage--;
      }
    });
  }

  void _nextPage() {
    setState(() {
      if (_filteredViaticos.length > (_currentPage + 1) * _rowsPerPage) {
        _currentPage++;
      }
    });
  }

  Future<void> _navigateAndRefresh(BuildContext context, Widget page) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );

    if (result == true) {
      _cargarViaticos(); // Refrescar la lista si se retornó `true`
    }
  }

  Future<void> _showDetailModal(BuildContext context, int viaticoId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder(
          future: ViaticosEncService.buscarViaticoDetalle(viaticoId),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                backgroundColor: Color(0xFF171717),
                content: Container(
                  width: double.minPositive, // Asegura que el modal no se estire mucho
                  height: 100, // Establece una altura fija mientras se carga
                  child: Center(
                    child: SpinKitCircle(color: Color(0xFFFFF0C6)),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                backgroundColor: Color(0xFF171717),
                title: Text('Error', style: TextStyle(color: Colors.red)),
                content: Text('Error al cargar el detalle del viático', style: TextStyle(color: Colors.white)),
                actions: [
                  TextButton(
                    child: Text('Cerrar', style: TextStyle(color: Color(0xFFFFF0C6))),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            } else {
              final viatico = snapshot.data;
              return AlertDialog(
                backgroundColor: Color(0xFF171717),
                title: Text('Detalle del Viático', style: TextStyle(color: Color(0xFFFFF0C6))),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailRow('No.', viatico.vienId?.toString() ?? 'N/A'),
                    _buildDetailRow('Monto Estimado', 'LPS ${viatico.vienMontoEstimado?.toStringAsFixed(2) ?? 'N/A'}'),
                    _buildDetailRow('Total Gastado', 'LPS ${viatico.vienTotalGastado?.toStringAsFixed(2) ?? 'N/A'}'),
                    SizedBox(height: 16),
                    _buildDetailRow('Fecha Emisión', viatico.vienFechaEmicion != null ? DateFormat('yyyy-MM-dd').format(viatico.vienFechaEmicion!) : 'N/A'),
                    _buildDetailRow('Colaborador', viatico.empleado ?? 'N/A'),
                    _buildDetailRow('Proyecto', viatico.proyecto ?? 'N/A'),
                    SizedBox(height: 16),
                    _buildDetailRow('Total Reconocido', 'LPS ${viatico.vienTotalReconocido?.toStringAsFixed(2) ?? 'N/A'}'),
                  ],
                ),
                actions: [
                  TextButton(
                    child: Text('Cerrar', style: TextStyle(color: Color(0xFFFFF0C6))),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(color: Color(0xFFFFF0C6), fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Color(0xFFFFF0C6)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildViaticoRow(ViaticoEncViewModel viatico, int index) {
  return TableRow(
    children: [
      TableCell(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: PopupMenuButton<int>(
            color: Colors.black,
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (int result) {
              if (result == 0) {
                _navigateAndRefresh(context, AgregarFactura(viaticoId: viatico.vienId!));
              } else if (result == 1) {
                _showDetailModal(context, viatico.vienId!);
              } else if (_usuarioEsAdm) {
                if (result == 2) {
                  _navigateAndRefresh(context, EditarViatico(viaticoId: viatico.vienId!));
                } else if (result == 3) {
                  _modalEliminar(context, viatico);
                } else if (result == 4) {
                  _modalFinalizar(context, viatico);
                }
              }
            },
            itemBuilder: (BuildContext context) {
              List<PopupMenuEntry<int>> menuItems = [];

              menuItems.add(const PopupMenuItem<int>(
                value: 0,
                child: Text(
                  'Agregar Facturas',
                  style: TextStyle(color: Color(0xFFFFF0C6)),
                ),
              ));

              menuItems.add(const PopupMenuItem<int>(
                value: 1,
                child: Text(
                  'Detalle',
                  style: TextStyle(color: Color(0xFFFFF0C6)),
                ),
              ));

              if (_usuarioEsAdm && viatico.vienEstadoFacturas == true) {
                menuItems.add(const PopupMenuItem<int>(
                  value: 2,
                  child: Text(
                    'Editar Viáticos',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ));
                menuItems.add(const PopupMenuItem<int>(
                  value: 3,
                  child: Text(
                    'Eliminar',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ));
                menuItems.add(const PopupMenuItem<int>(
                  value: 4,
                  child: Text(
                    'Finalizar',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ));
              }

              return menuItems;
            },
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
            viatico.proyecto ?? 'N/A',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      TableCell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            viatico.vienEstadoFacturas == false ? Icons.adjust : Icons.adjust,
            color: viatico.vienEstadoFacturas == false ? Colors.red : Colors.green,
          ),
        ),
      ),
    ],
  );
}


  void _modalEliminar(BuildContext context, ViaticoEncViewModel viatico) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Viático', style: TextStyle(color: Colors.white)),
          content: Text(
            '¿Está seguro de querer eliminar el viático en el proyecto ${viatico.proyecto}?',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF171717),
          actions: [
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Color(0xFFFFF0C6))),
              onPressed: () async {
                try {
                  await ViaticosEncService.eliminarViatico(viatico.vienId!);
                  setState(() {
                    _filteredViaticos.remove(viatico);
                    _isLoading = true;
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Eliminado con éxito')),
                  );
                  _isLoading = false;
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar el registro')),
                  );
                }
              },
            ),
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Color(0xFFFFF0C6))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _modalFinalizar(BuildContext context, ViaticoEncViewModel viatico) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Finalizar Viático', style: TextStyle(color: Colors.white)),
          content: Text(
            '¿Está seguro de querer finalizar el viático en el proyecto ${viatico.proyecto}?',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF171717),
          actions: [
            TextButton(
              child: Text('Aceptar', style: TextStyle(color: Color(0xFFFFF0C6))),
              onPressed: () async {
                try {
                  // Llamar al servicio para finalizar el viático
                  await ViaticosEncService.finalizarViatico(viatico.vienId!);

                  // Cerrar el modal
                  Navigator.of(context).pop();

                  // Mostrar mensaje de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Viático finalizado con éxito')),
                  );

                  // Recargar la lista de viáticos
                  _cargarViaticos();
                } catch (e) {
                  // Manejo de errores
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al finalizar el registro')),
                  );
                }
              },
            ),
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Color(0xFFFFF0C6))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildListaViaticos() {
    return Scaffold(
      backgroundColor: Colors.black, // Establece el fondo negro para la pantalla
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
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<ViaticoEncViewModel>>(
                future: _viaticosFuture,
                builder: (context, snapshot) {
                  if (_isLoading) {
                    return Center(
                      child: SpinKitCircle(color: Color(0xFFFFF0C6)),
                    );
                  } else if (snapshot.connectionState == ConnectionState.waiting) {
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
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay datos disponibles',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  } else {
                    _filteredViaticos = _searchController.text.isEmpty
                        ? snapshot.data!
                        : _filteredViaticos;
                    final int totalRecords = _filteredViaticos.length;
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
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(1),
                                2: FlexColumnWidth(3),
                                3: FlexColumnWidth(2),
                              },
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF171717),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Acciones',
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
                                        'Proyecto',
                                        style: TextStyle(
                                          color: Color(0xFFFFF0C6),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        'Estado',
                                        style: TextStyle(
                                          color: Color(0xFFFFF0C6),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                ..._filteredViaticos
                                    .sublist(startIndex, endIndex)
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final viatico = entry.value;
                                  return _buildViaticoRow(
                                      viatico, startIndex + index);
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
          ],
        ),
      ),
      floatingActionButton: _usuarioEsAdm
          ? FloatingActionButton(
              onPressed: () {
                _navigateAndRefresh(context, NuevoViatico());
              },
              backgroundColor: Color(0xFFFFF0C6),
              child: Icon(Icons.add, color: Colors.black),
              shape: CircleBorder(),
            )
          : null, // Si no es admin, no mostrar el botón flotante
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
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
                'Viáticos',
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
      body: Stack(
        children: [
          _buildListaViaticos(),
          if (_usuarioEsAdm)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  _navigateAndRefresh(context, NuevoViatico());
                },
                backgroundColor: Color(0xFFFFF0C6),
                child: Icon(Icons.add, color: Colors.black),
                shape: CircleBorder(),
              ),
            ),
        ],
      ),
    );
  }
}
