import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import 'package:sigesproc_app/screens/fletes/nuevoflete.dart';
import '../menu.dart';
import 'package:sigesproc_app/services/proyectos/proyectoservice.dart';

class Proyecto extends StatefulWidget {
  @override
  _ProyectoState createState() => _ProyectoState();
}

class _ProyectoState extends State<Proyecto> {
  int _selectedIndex = 1;
  Future<List<ProyectoViewModel>>? _proyectosFuture;
  TextEditingController _searchController = TextEditingController();
  List<ProyectoViewModel> _proyectosFiltrados = [];
  int _currentPage = 0;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _proyectosFuture = ProyectoService.listarProyectos();
    _searchController.addListener(_proyectoFiltrado);
  }

  @override
  void dispose() {
    _searchController.removeListener(_proyectoFiltrado);
    _searchController.dispose();
    super.dispose();
  }

  void _proyectoFiltrado() {
    final query = _searchController.text.toLowerCase();
    if (_proyectosFuture != null) {
      _proyectosFuture!.then((proyectos) {
        setState(() {
          _proyectosFiltrados = proyectos.where((proyecto) {
            final salida = proyecto.proyNombre?.toLowerCase() ?? '';
            return salida.contains(query);
          }).toList();
        });
      });
    }
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
      if (_proyectosFiltrados.length > (_currentPage + 1) * _rowsPerPage) {
        _currentPage++;
      }
    });
  }

  TableRow _buildProyectoRow(ProyectoViewModel proyecto, int index) {
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
              proyecto.proyNombre ?? 'N/A',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              proyecto.proyEstado == true ? Icons.adjust : Icons.adjust,
              color: proyecto.proyEstado == true ? Colors.red : Colors.green,
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: PopupMenuButton<int>(
              icon: Icon(Icons.more_vert, color: Colors.white),
              onSelected: (int result) {
                if (result == 0) {
                  // Acción 1
                } else if (result == 1) {
                  // Acción 2
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                const PopupMenuItem<int>(
                  value: 0,
                  child: Text('Acción 1'),
                ),
                const PopupMenuItem<int>(
                  value: 1,
                  child: Text('Acción 2'),
                ),
              ],
            ),
          ),
        ),
      ],
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
                'Proyectos',
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
              child: FutureBuilder<List<ProyectoViewModel>>(
                future: _proyectosFuture,
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
                    _proyectosFiltrados = _searchController.text.isEmpty
                        ? snapshot.data!
                        : _proyectosFiltrados;
                    final int totalRecords = _proyectosFiltrados.length;
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
                                1: FlexColumnWidth(4),
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
                                ..._proyectosFiltrados
                                    .sublist(startIndex, endIndex)
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  final index = entry.key;
                                  final proyecto = entry.value;
                                  return _buildProyectoRow(proyecto, startIndex + index);
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
}
