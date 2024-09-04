import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sigesproc_app/models/proyectos/actividadporetapaviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/appBar.dart';
import 'package:sigesproc_app/screens/proyectos/actividad.dart';
import 'package:sigesproc_app/screens/proyectos/etapaslineatiempo.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';
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
int _unreadCount = 0;
late int userId;
  Map<int, bool> _expandedProjects = {};
  Map<int, Future<List<EtapaPorProyectoViewModel>>?> _etapasPorProyecto = {};
  bool _isLoadingEtapas = false;

  ScrollController _scrollController = ScrollController();
  double _savedScrollPosition = 0.0; // Variable para almacenar la posición del scroll
  int _savedCurrentPage = 0; // Variable para almacenar la página actual

  @override
  void initState() {
    super.initState();
     var prefs = PreferenciasUsuario();
  userId = int.tryParse(prefs.userId) ?? 0;

  _loadNotifications();
    _proyectosFuture = ProyectoService.listarProyectos();
    _searchController.addListener(_proyectoFiltrado);
  }
Future<void> _loadNotifications() async {
  try {
    final notifications = await NotificationServices.BuscarNotificacion(userId);
    setState(() {
      _unreadCount = notifications.where((n) => n.leida == "No Leida").length;
    });
  } catch (e) {
    print('Error al cargar notificaciones: $e');
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

  @override
  void dispose() {
    _searchController.removeListener(_proyectoFiltrado);
    _searchController.dispose();

    _scrollController.dispose();
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

        // Ajustar la página actual solo si es necesario (para evitar desbordamiento)
        final totalRecords = _proyectosFiltrados.length;
        if (totalRecords == 0) {
          _currentPage = 0; // Restablecer la página a 0 si no hay registros
        } else {
          final maxPages = (totalRecords / _rowsPerPage).ceil();
          if (_currentPage >= maxPages) {
            _currentPage = maxPages - 1; // Ajustar a la última página válida
          }
        }
      });
    });
  }
}



  void _toggleExpansion(int projectId) {
    // Guardar la posición del scroll y la página actual antes de cargar las etapas
    _savedScrollPosition = _scrollController.position.pixels;
    _savedCurrentPage = _currentPage;

    setState(() {
      if (_expandedProjects.containsKey(projectId) && _expandedProjects[projectId] == true) {
        _expandedProjects[projectId] = false;
      } else {
        _expandedProjects.updateAll((key, value) => false);
        _expandedProjects[projectId] = true;
        _isLoadingEtapas = true;

        _etapasPorProyecto[projectId] = EtapaPorProyectoService.listarEtapasPorProyecto(projectId).then((value) {
          setState(() {
            _isLoadingEtapas = false;
          });

          // Restaurar la posición del scroll y la página actual después de que las etapas se hayan cargado
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _currentPage = _savedCurrentPage;
            _scrollController.animateTo(
              _savedScrollPosition,
              duration: Duration(milliseconds: 100),
              curve: Curves.easeOut,
            );
          });

          return value;
        });
      }
    });
  }


  String _truncateWithEllipsis(int cutoff, String myString) {
  return (myString.length <= cutoff)
      ? myString
      : '${myString.substring(0, cutoff)}...';
}

void _showProjectDetails(ProyectoViewModel proyecto) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          padding: EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 22.0),
          decoration: BoxDecoration(
            color: Color(0xFF171717),
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Color(0xFFFFF0C6), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.adjust,
                    color: proyecto.proyEstado == true ? Colors.green : Colors.red,
                    size: 25,
                  ),
                  IconButton(
                    icon: Icon(Icons.cancel_outlined, color: Color(0xFFFFF0C6)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Center(
                child: Text(
                  'Proyecto',
                  style: TextStyle(
                    color: Color(0xFFFFF0C6),
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  '( ${proyecto.proyNombre ?? "N/A"} )',
                  style: TextStyle(
                    color: Color(0xFFFFF0C6),
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: proyecto.iccaImagen != null && proyecto.iccaImagen!.startsWith("data:image/")
            ? Image.memory(
                base64Decode(proyecto.iccaImagen!.split(',').last),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        'Imagen no disponible',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                },
              )
            : proyecto.iccaImagen != null
                ? Image.network(
                    'http://apisigesproc.somee.com/uploads/${proyecto.iccaImagen}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Text(
                            'Imagen no disponible',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        'Imagen no disponible',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
              ),
              ),
              SizedBox(height: 10),
              Text(
                'Cliente: ${proyecto.clieNombreCompleto ?? "N/A"}',
                style: TextStyle(color: Color(0xFFF4EAD5)),
              ),
              Text(
                'Estado: ${proyecto.proyEstado == true ? "En Ejecución" : "Finalizado"}',
                style: TextStyle(color: Color(0xFFF4EAD5)),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Progreso:',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              // Conversión del progreso desde String a double y luego reducido a 2 decimales
                              value: (double.tryParse(proyecto.proyProgreso ?? '0')?.clamp(0.0, 100.0) ?? 0.0) / 100,
                              backgroundColor: Colors.grey,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF4EAD5)),
                              minHeight: 20,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '${double.tryParse(proyecto.proyProgreso ?? '0')?.toStringAsFixed(2) ?? "0.00"}%', // Redondeado a 2 decimales
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),              
            ],
          ),
        ),
      );
    },
  );
}


// Container(
              //   decoration: BoxDecoration(
              //     color: Color.fromARGB(128, 38, 38, 38),
              //     borderRadius: BorderRadius.circular(5),
              //   ),
              //   padding: EdgeInsets.all(8.0),
              //   child: Row(
              //     children: [
              //       Container(
              //         width: 5,
              //         height: 40,
              //         color: Colors.green,
              //       ),
              //       SizedBox(width: 10),
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               'Notificación',
              //               style: TextStyle(
              //                 color: Colors.white,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //             Text(
              //               'Ha iniciado el Proyecto',
              //               style: TextStyle(color: Colors.white),
              //             ),
              //           ],
              //         ),
              //       ),
              //       Icon(Icons.notifications_none_outlined, color: Color(0xFFFFF0C6), size: 20),
              //     ],
              //   ),
              // ),
              // SizedBox(height: 10),
              // Container(
              //   decoration: BoxDecoration(
              //     color: Color.fromARGB(128, 38, 38, 38),
              //     borderRadius: BorderRadius.circular(5),
              //   ),
              //   padding: EdgeInsets.all(8.0),
              //   child: Row(
              //     children: [
              //       Container(
              //         width: 5,
              //         height: 40,
              //         color: Colors.red,
              //       ),
              //       SizedBox(width: 10),
              //       Expanded(
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           children: [
              //             Text(
              //               'Alerta',
              //               style: TextStyle(
              //                 color: Colors.white,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //             Text(
              //               'No están los materiales en la obra',
              //               style: TextStyle(color: Colors.white),
              //             ),
              //           ],
              //         ),
              //       ),
              //       Icon(Icons.notifications_none_outlined, color: Color(0xFFFFF0C6), size: 20),
              //     ],
              //   ),
              // ),


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
      TableCell(
        child: Padding(
          padding: const EdgeInsets.only(top: 0, bottom: 0), // Ajuste de padding superior e inferior
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centrar los íconos horizontalmente
            children: [
              GestureDetector(
                onTap: () => _showProjectDetails(proyecto),
                child: Icon(Icons.info_outlined, color: Color(0xFFFFF0C6), size: 22),
              ),
              SizedBox(width: 4), // Añadir espacio entre los íconos
              GestureDetector(
                onTap: () => _toggleExpansion(proyecto.proyId),
                child: Icon(
                  _expandedProjects[proyecto.proyId] == true
                      ? Icons.arrow_drop_down
                      : Icons.arrow_right_outlined,
                  color: Color(0xFFFFF0C6),
                  size: 25,
                ),
              ),
            ],
          ),
        ),
      ),
      TableCell(
        child: InkWell(
          onTap: () => _navigateToLineaDeTiempo(context, proyecto),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  (index + 1).toString(), // Índice
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(width: 33), // Espacio entre el número y la descripción
                Expanded(
                  child: Text(
                    proyecto.proyNombre ?? 'N/A', // Descripción
                    style: TextStyle(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}


  Widget _buildEtapasColumn(List<EtapaPorProyectoViewModel> etapas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: etapas.map((etapa) {
        return _buildEtapasRow(etapa);
      }).toList(),
    );
  }

Widget _buildEtapasRow(EtapaPorProyectoViewModel etapa) {
  return InkWell(
    onTap: () => _navigateToActividades(context, etapa.etprId, etapa.etapDescripcion),
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(130, 23, 23, 23),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(
              Icons.arrow_outward_outlined, // Viñeta
              size: 20,
              color: Color(0xFFFFF0C6),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                etapa.etapDescripcion ?? 'N/A',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              etapa.etprEstado == true ? Icons.adjust : Icons.adjust, // Estado
              color: etapa.etprEstado == true ? Colors.red : Colors.green,
              size: 15,
            ),
          ],
        ),
      ),
    ),
  );
}


  void _navigateToActividades(BuildContext context, int etprId, String? etprDescripcion) async {
    try {
      List<ActividadesPorEtapaViewModel> actividades = await ActividadesPorEtapaService.listarActividadPorEtapa(etprId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Actividad(key: Key(etprId.toString()), actividades: actividades, etapaNombre: etprDescripcion),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar las actividades: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: CustomAppBar(
  unreadCount: _unreadCount,
  onNotificationsUpdated: _loadNotifications, // Llamada para actualizar las notificaciones
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
                    return Center(child: CircularProgressIndicator(color: Color(0xFFFFF0C6)));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error al cargar los datos', style: TextStyle(color: Colors.red)),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text('No hay datos disponibles', style: TextStyle(color: Colors.white)),
                    );
                  } else {
                    _proyectosFiltrados = _searchController.text.isEmpty ? snapshot.data! : _proyectosFiltrados;
                    final int totalRecords = _proyectosFiltrados.length;
                    final int startIndex = _currentPage * _rowsPerPage;
                    final int endIndex = (startIndex + _rowsPerPage > totalRecords)
                        ? totalRecords
                        : startIndex + _rowsPerPage;

                    return Column(
                      children: [
                        Expanded(
                          child: _isLoadingEtapas
                              ? Center(child: CircularProgressIndicator(color: Color(0xFFFFF0C6)))
                              : SingleChildScrollView(
                                  controller: _scrollController,
                                  child: Table(
                                    columnWidths: {
                                      0: FlexColumnWidth(1.5),  // Acciones
                                      1: FlexColumnWidth(5),  // Columna combinada No. + Descripción
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
                                              'No.     Descripción',
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
                                                        return SizedBox.shrink();
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
                                                        return _buildEtapasColumn(snapshot.data!);
                                                      }
                                                    },
                                                  ),
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
