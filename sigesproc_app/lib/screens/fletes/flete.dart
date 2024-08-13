import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/screens/fletes/editarflete.dart';
import 'package:sigesproc_app/screens/fletes/nuevoflete.dart';
import 'package:sigesproc_app/screens/fletes/verificacionflete.dart';
import '../menu.dart';
import 'package:sigesproc_app/services/fletes/fleteencabezadoservice.dart';
import 'detalleflete.dart';

class Flete extends StatefulWidget {
  @override
  _FleteState createState() => _FleteState();
}

class _FleteState extends State<Flete> {
  int _selectedIndex = 2;
  Future<List<FleteEncabezadoViewModel>>? _fletesFuture;
  TextEditingController _searchController = TextEditingController();
  List<FleteEncabezadoViewModel> _filteredFletes = [];
  List<FleteEncabezadoViewModel> _allFletes = [];
  int _currentPage = 0;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _fletesFuture = FleteEncabezadoService.listarFletesEncabezado();
    _fletesFuture!.then((fletes) {
      setState(() {
        _allFletes = fletes;
        _filteredFletes = fletes;
      });
    });
    _searchController.addListener(_filterFletes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFletes);
    _searchController.dispose();
    super.dispose();
  }

  void _filterFletes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFletes = _allFletes.where((flete) {
        final salida = flete.salida?.toLowerCase() ?? '';
        return salida.contains(query);
      }).toList();
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
      if (_filteredFletes.length > (_currentPage + 1) * _rowsPerPage) {
        _currentPage++;
      }
    });
  }

  TableRow _buildFleteRow(FleteEncabezadoViewModel flete, int index) {
    return TableRow(
      children: [
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
              flete.salida ?? 'N/A',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              flete.flenEstado == true ? Icons.adjust : Icons.adjust,
              color: flete.flenEstado == true ? Colors.red : Colors.green,
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: PopupMenuButton<int>(
            color: Colors.black,
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (int result) {
              if (result == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetalleFlete(flenId: flete.flenId!),
                  ),
                );
              } else if (result == 1) {
                //  "Ver Verificación"
              } else if (result == 2) {
                _modalEliminar(context, flete);
              } else if (result == 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditarFlete(flenId: flete.flenId!),
                  ),
                );
              } else if (result == 4) {
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerificarFlete(flenId: flete.flenId!),
                  ),
                );
              } 
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
              if (flete.flenEstado == true) ...[
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text(
                    'Ver Detalle',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text(
                    'Ver Verificación',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text(
                    'Eliminar',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
              ] else ...[
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text(
                    'Ver Detalle',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 3,
                  child: Text(
                    'Editar',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 4,
                  child: Text(
                    'Verificar',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
                const PopupMenuItem<int>(
                  value: 2,
                  child: Text(
                    'Eliminar',
                    style: TextStyle(color: Color(0xFFFFF0C6)),
                  ),
                ),
              ],
            ],
          ),
          ),
        ),
      ],
    );
  }

  void _modalEliminar(BuildContext context, FleteEncabezadoViewModel flete) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Eliminar Flete', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Está seguro de querer eliminar el flete hacia ${flete.destino}?',
          style: TextStyle(color: Colors.white),
        ),
         backgroundColor: Color(0xFF171717),
        actions: [
          TextButton(
            child: Text('Eliminar', style: TextStyle(color: Color(0xFFFFF0C6))),
            onPressed: () async {
              try {
                await FleteEncabezadoService.Eliminar(flete.flenId!);
                setState(() {
                  _filteredFletes.remove(flete);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Flete eliminado con éxito')),
                );
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
                'Fletes',
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
              child: FutureBuilder<List<FleteEncabezadoViewModel>>(
                future: _fletesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
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
                    _filteredFletes = _searchController.text.isEmpty
                        ? snapshot.data!
                        : _filteredFletes;
                    final int totalRecords = _filteredFletes.length;
                    final int startIndex = _currentPage * _rowsPerPage;
                    final int endIndex = (startIndex + _rowsPerPage > totalRecords)
                        ? totalRecords
                        : startIndex + _rowsPerPage;

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Table(
                              columnWidths: {
                                0: FlexColumnWidth(1),
                                1: FlexColumnWidth(3),
                                2: FlexColumnWidth(2),
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
                                        'Salida',
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
                                  ],
                                ),
                                ..._filteredFletes
                                    .sublist(startIndex, endIndex)
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final flete = entry.value;
                                  return _buildFleteRow(flete, startIndex + index);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NuevoFlete(),
            ),
          );
        },
        backgroundColor: Color(0xFFFFF0C6),
        child: Icon(Icons.add_circle_outline, color: Colors.black),
      ),
    );
  }
}
