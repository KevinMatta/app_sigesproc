import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:sigesproc_app/models/viaticos/viaticoViewModel.dart';
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
  int _usuarioEsAdm = 1; // Variable para almacenar si el usuario es admin

  @override
  void initState() {
    super.initState();
    _viaticosFuture = ViaticosEncService.listarViaticos(3); // Aquí puedes pasar el ID de usuario adecuado
    _viaticosFuture!.then((viaticos) {
      setState(() {
        _allViaticos = viaticos;
        _filteredViaticos = viaticos;
        // Aquí asumimos que el rol de admin es el mismo para todos los viáticos, puedes ajustar según sea necesario
        _usuarioEsAdm = viaticos.isNotEmpty && viaticos.first.usuarioEsAdm == 1 ? 1 : 0;
      });
    });

    _searchController.addListener(_filterViaticos);
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

  TableRow _buildViaticoRow(ViaticoEncViewModel viatico, int index) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: PopupMenuButton<int>(
              color: Colors.black,
              icon: Icon(Icons.more_vert, color: Colors.white),
              onSelected: (int result) {
                if (result == 0) {
                  // Descomentar y ajustar cuando tengas los archivos necesarios
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => DetalleViatico(viaticoId: viatico.vienId!),
                  //   ),
                  // );
                } else if (result == 1) {
                  _modalEliminar(context, viatico);
                } else if (result == 2) {
                  // Descomentar y ajustar cuando tengas los archivos necesarios
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => EditarViatico(viaticoId: viatico.vienId!),
                  //   ),
                  // );
                } else if (result == 3) {
                  // Descomentar y ajustar cuando tengas los archivos necesarios
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => VerificarViatico(viaticoId: viatico.vienId!),
                  //   ),
                  // );
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text(
                    'Detalle',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text(
                    'Eliminar',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text(
                    'Editar',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 3,
                  child: Text(
                    'Verificar',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
              ],
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
              viatico.vienSaberProyeto == 1 ? Icons.adjust : Icons.adjust,
              color: viatico.vienSaberProyeto == 1 ? Colors.red : Colors.green,
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
              child:
                  Text('Eliminar', style: TextStyle(color: Color(0xFFFFF0C6))),
              onPressed: () async {
                try {
                  await ViaticosEncService.eliminarViatico(viatico.vienId!);
                  setState(() {
                    _filteredViaticos.remove(viatico);
                    _isLoading = true;
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Viático eliminado con éxito')),
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
              child:
                  Text('Cancelar', style: TextStyle(color: Color(0xFFFFF0C6))),
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
      body: _buildListaViaticos(),
      floatingActionButton: _usuarioEsAdm == 1
          ? FloatingActionButton(
              onPressed: () {
                // Descomentar y ajustar cuando tengas los archivos necesarios
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NuevoViatico(),
                  ),
                );
              },
              backgroundColor: Color(0xFFFFF0C6),
              child: Icon(Icons.add, color: Colors.black),
              shape: CircleBorder(),
            )
          : null, // Si no es admin, no mostrar el botón flotante
    );
  }
}
