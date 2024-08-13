import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sigesproc_app/models/proyectos/actividadporetapaviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import 'package:sigesproc_app/screens/proyectos/actividad.dart';
import 'package:sigesproc_app/screens/proyectos/etapaslineatiempo.dart';
import 'package:sigesproc_app/services/proyectos/proyectoservice.dart';
import 'package:sigesproc_app/services/proyectos/etapaporproyectoservice.dart';
import 'package:sigesproc_app/services/proyectos/actividadporetapaservice.dart';
import 'package:sigesproc_app/models/proyectos/etapaporproyectoviewmodel.dart';
import '../menu.dart';

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

  Map<int, bool> _expandedProjects = {};
  Map<int, Future<List<EtapaPorProyectoViewModel>>?> _etapasPorProyecto = {};

  @override
  void initState() {
    super.initState();
    _proyectosFuture = ProyectoService.listarProyectos();
    _searchController.addListener(_proyectoFiltrado);
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

  void _toggleExpansion(int projectId) {
    setState(() {
      if (_expandedProjects.containsKey(projectId) && _expandedProjects[projectId] == true) {
        _expandedProjects[projectId] = false;
      } else {
        _expandedProjects.updateAll((key, value) => false);
        _expandedProjects[projectId] = true;
        _etapasPorProyecto[projectId] = EtapaPorProyectoService.listarEtapasPorProyecto(projectId);
      }
    });
  }

  String _truncateWithEllipsis(int cutoff, String myString) {
  return (myString.length <= cutoff)
      ? myString
      : '${myString.substring(0, cutoff)}...';
}

void _showProjectDetails(ProyectoViewModel proyecto) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Color(0xFF171717),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Aplicamos el truncado manual
                  Expanded(
                    child: Text(
                      'Proyecto: ${_truncateWithEllipsis(15, proyecto.proyNombre ?? "N/A")}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel_outlined, color: Color(0xFFFFF0C6)),  // Cambia el color del icono de cerrar
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Descripción: ${proyecto.proyDescripcion ?? "N/A"}',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Fecha Inicio: ${_formatDate(proyecto.proyFechaInicio)}',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Fecha Fin: ${_formatDate(proyecto.proyFechaFin)}',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Dirección: ${proyecto.proyDireccionExacta ?? "N/A"}',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              // Placeholder para la imagen
              Container(
                height: 200,
                color: Colors.grey,
                child: Center(
                  child: Text(
                    'Espacio para Imagen',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Estado: ${proyecto.proyEstado == true ? "Activo" : "Inactivo"}',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Estado Nombre: ${proyecto.estaNombre ?? "N/A"}',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'País: ${proyecto.paisNombre ?? "N/A"}',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Ciudad: ${proyecto.ciudDescripcion ?? "N/A"}',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Cliente: ${proyecto.clieNombreCompleto ?? "N/A"}',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Especificación: ${proyecto.esprDescripcion ?? "N/A"}',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    },
  );
}



  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}-${date.month}-${date.year}';
  }


  void _navigateToLineaDeTiempo(BuildContext context, ProyectoViewModel proyecto) async {
  try {
    List<EtapaPorProyectoViewModel> etapas = await EtapaPorProyectoService.listarEtapasPorProyecto(proyecto.proyId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LineaDeTiempo(etapas: etapas, proyectoNombre: proyecto.proyNombre ?? '')),
    );
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al cargar las etapas: $error'),
      ),
    );
  }
}



 TableRow _buildProyectoRow(ProyectoViewModel proyecto, int index) {
  return TableRow(
    children: [
      // Enumeración
      TableCell(
        child: InkWell(
          onTap: () => _navigateToLineaDeTiempo(context, proyecto), // Navega a la línea de tiempo al hacer clic
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              (index + 1).toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      // Celda para el nombre del proyecto con truncamiento si es demasiado largo
      TableCell(
        child: InkWell(
          onTap: () => _navigateToLineaDeTiempo(context, proyecto), // Navega a la línea de tiempo al hacer clic
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              proyecto.proyNombre ?? 'N/A',
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis, // Truncamiento del texto
            ),
          ),
        ),
      ),
      // Celda para el menú de acciones y etapas expandidas
      TableCell(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.info_outlined, color: Color(0xFFFFF0C6)),
                onPressed: () => _showProjectDetails(proyecto),
              ),
              IconButton(
                icon: Icon(
                  _expandedProjects[proyecto.proyId] == true
                      ? Icons.arrow_drop_down
                      : Icons.arrow_left_outlined,
                  color: Color(0xFFF4EAD5),
                  size: 33,
                ),
                onPressed: () => _toggleExpansion(proyecto.proyId),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}


void _navigateToActividades(BuildContext context, int etprId) async {
  try {
    List<ActividadesPorEtapaViewModel> actividades =
        await ActividadesPorEtapaService.listarActividadPorEtapa(etprId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Actividad(key: Key(etprId.toString()), // Proporcionando la key
        actividades: actividades, // Proporcionando el ID de la etapa),
      )),
    );
  } catch (error) {
    // Manejo del error en caso de que la llamada falle
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al cargar las actividades: $error'),
      ),
    );
  }
}


Widget _buildEtapasRow(EtapaPorProyectoViewModel etapa) {
  return InkWell(
    onTap: () => _navigateToActividades(context, etapa.etprId),
    child: Container(
      width: double.infinity,  // Ocupa todo el ancho disponible
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Color(0xFF171717),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(
              Icons.keyboard_arrow_right_outlined,
              size: 30,
              color: Color(0xFFFFF0C6),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    etapa.etapDescripcion ?? 'N/A',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    etapa.proyNombre ?? 'N/A',
                    style: TextStyle(
                      color: Colors.white54,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              1 == 1 ? Icons.adjust : Icons.adjust,
              color: etapa.etprEstado == true ? Colors.green : Colors.red,
              size: 15,
            ),
          ],
        ),
      ),
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
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
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
            .expand((entry) {
          final index = entry.key;
          final proyecto = entry.value;
          final List<TableRow> rows = [
            _buildProyectoRow(proyecto, startIndex + index),
          ];

          if (_expandedProjects[proyecto.proyId] == true) {
            rows.add(
              TableRow(
                children: [
                  TableCell(
                    child: SizedBox.shrink(),
                  ),
                  TableCell(
                  child: FutureBuilder<List<EtapaPorProyectoViewModel>>(
                    future: _etapasPorProyecto[proyecto.proyId],
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SpinKitCircle(color: Color(0xFFFFF0C6)),
                        );
                      } else if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Error al cargar las etapas',
                            style: TextStyle(color: Colors.red),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'No hay etapas disponibles',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: snapshot.data!
                              .map((etapa) => _buildEtapasRow(etapa))
                              .toList(),
                        );
                      }
                    },
                  ),
                ),
                  TableCell(
                    child: SizedBox.shrink(),
                  ),
                ],
              ),
            );
          }

          return rows;
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
}
