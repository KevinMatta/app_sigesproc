import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigesproc_app/models/fletes/fletecontrolcalidadviewmodel.dart';
import 'package:sigesproc_app/models/fletes/fletedetalleviewmodel.dart';
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/appBar.dart';
import 'package:sigesproc_app/screens/fletes/editarflete.dart';
import 'package:sigesproc_app/screens/fletes/nuevoflete.dart';
import 'package:sigesproc_app/screens/fletes/verificarflete.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';
import 'package:sigesproc_app/services/fletes/fletecontrolcalidadservice.dart';
import 'package:sigesproc_app/services/fletes/fletedetalleservice.dart';
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
  late Future<List<FleteControlCalidadViewModel>> _incidenciasFuture;
  TextEditingController _searchController = TextEditingController();
  List<FleteEncabezadoViewModel> _filteredFletes = [];
  List<FleteEncabezadoViewModel> _allFletes = [];
  int _currentPage = 0;
  int _rowsPerPage = 10;
  bool _isLoading = false;
  bool _viendoVerificacion = false;
  int? _flenIdSeleccionado;
  int _unreadCount = 0;
  late int userId;
  int? emplId;
  bool? EsAdmin;
  bool esFletero = false;
  bool esSupervisorSalida = false;
  bool esSupervisorLlegada = false;

  @override
  void initState() {
    super.initState();
    _cargarEmpleado();
    var prefs = PreferenciasUsuario();
    userId = int.tryParse(prefs.userId) ?? 0;
    _loadNotifications();
    _searchController.addListener(_filterFletes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFletes);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications =
          await NotificationServices.BuscarNotificacion(userId);
      setState(() {
        _unreadCount = notifications.where((n) => n.leida == "No Leida").length;
      });
    } catch (e) {
      print('Error al cargar notificaciones: $e');
    }
  }

  Future<void> _cargarEmpleado() async {
    final pref = await SharedPreferences.getInstance();
    setState(() {
      emplId = int.tryParse(pref.getString('emplId') ?? '');
      EsAdmin = bool.tryParse(pref.getString('EsAdmin') ?? 'false');
      print('Empleado cargado - emplId: $emplId, EsAdmin: $EsAdmin');
    });

    // Cargar los fletes solo después de que emplId y EsAdmin estén cargados
    _cargarFletes();
  }

  Future<void> _cargarFletes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final fletes = await FleteEncabezadoService.listarFletesEncabezado();

      setState(() {
        // Verificamos que emplId y EsAdmin no sean nulos antes de continuar
        if (emplId != null && EsAdmin != null) {
          // Si el usuario no es admin, filtrar por emplId
          if (EsAdmin == false) {
            _allFletes = fletes.where((flete) {
              print(
                  'Filtrando fletes para emplId $emplId: emtrId ${flete.emtrId}, emssId ${flete.emssId}, emslId ${flete.emslId}');
              return flete.emtrId == emplId ||
                  flete.emssId == emplId ||
                  flete.emslId == emplId;
            }).toList();
            print('all $_allFletes');

            print("Fletes filtrados: ${_allFletes.length}");
          } else {
            print('Usuario es admin, mostrando todos los fletes');
            _allFletes = fletes;
          }

          // Actualizamos los fletes filtrados
          _filteredFletes = _allFletes;
          print("Fletes mostrados en la tabla: ${_filteredFletes.length}");
        } else {
          print('emplId o EsAdmin no cargado correctamente');
        }
      });
    } catch (e) {
      print('Error al cargar fletes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterFletes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFletes = _allFletes.where((flete) {
        final salida = flete.salida?.toLowerCase() ?? '';
        return salida.contains(query);
      }).toList();

      final totalRecords = _filteredFletes.length;
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
      if (_filteredFletes.length > (_currentPage + 1) * _rowsPerPage) {
        _currentPage++;
      }
    });
  }

  TableRow _buildFleteRow(FleteEncabezadoViewModel flete, int index) {
    // Estas variables deben calcularse por cada registro
    bool esFletero = flete.emtrId == emplId;
    bool esSupervisorSalida = flete.emssId == emplId;
    bool esSupervisorLlegada = flete.emslId == emplId;

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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleFlete(flenId: flete.flenId!),
                    ),
                  );
                } else if (result == 1) {
                  setState(() {
                    _viendoVerificacion = true;
                    _flenIdSeleccionado = flete.flenId;
                    _incidenciasFuture =
                        FleteControlCalidadService.buscarIncidencias(
                            _flenIdSeleccionado!);
                  });
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
                      builder: (context) =>
                          VerificarFlete(flenId: flete.flenId!),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) => _buildMenuOptions(
                  flete, esFletero, esSupervisorSalida, esSupervisorLlegada),
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
      ],
    );
  }

  List<PopupMenuEntry<int>> _buildMenuOptions(FleteEncabezadoViewModel flete,
      bool esFletero, bool esSupervisorSalida, bool esSupervisorLlegada) {
    List<PopupMenuEntry<int>> menuOptions = [];

    // Opción "Detalle" (siempre disponible)
    menuOptions.add(
      const PopupMenuItem<int>(
        value: 0,
        child: Text(
          'Detalle',
          style: TextStyle(color: Color(0xFFFFF0C6)),
        ),
      ),
    );

    // Si el flete está activo
    if (flete.flenEstado == true) {
      if (EsAdmin!) {
        // Opciones adicionales para administradores
        menuOptions.addAll([
          const PopupMenuItem<int>(
            value: 1,
            child: Text(
              'Verificación',
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
        ]);
      }

      if (esSupervisorSalida) {
        menuOptions.add(
          const PopupMenuItem<int>(
            value: 1,
            child: Text(
              'Verificación',
              style: TextStyle(color: Color(0xFFFFF0C6)),
            ),
          ),
        );
      }

      if (esSupervisorLlegada) {
        menuOptions.add(
          const PopupMenuItem<int>(
            value: 1,
            child: Text(
              'Verificación',
              style: TextStyle(color: Color(0xFFFFF0C6)),
            ),
          ),
        );
      }
    } else {
      // Si el flete no está activo
      if (EsAdmin!) {
        menuOptions.addAll([
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
        ]);
      }

      if (esSupervisorSalida) {
        menuOptions.add(
          const PopupMenuItem<int>(
            value: 3,
            child: Text(
              'Editar',
              style: TextStyle(color: Color(0xFFFFF0C6)),
            ),
          ),
        );
      }

      if (esSupervisorLlegada) {
        menuOptions.add(
          const PopupMenuItem<int>(
            value: 4,
            child: Text(
              'Verificar',
              style: TextStyle(color: Color(0xFFFFF0C6)),
            ),
          ),
        );
      }
    }

    return menuOptions;
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
              child:
                  Text('Eliminar', style: TextStyle(color: Color(0xFFFFF0C6))),
              onPressed: () async {
                try {
                  await FleteEncabezadoService.Eliminar(flete.flenId!);
                  setState(() {
                    _filteredFletes.remove(flete);
                    _isLoading = true;
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Flete eliminado con éxito')),
                  );
                  _isLoading = false;
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar el registro')),
                  );
                } finally {}
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

  Widget _buildEncabezadoFlete(FleteEncabezadoViewModel flete) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flete - ${DateFormat('dd/MM/yy, hh:mm a').format(flete.flenFechaHoraEstablecidaDeLlegada!)}',
          style: TextStyle(
            color: Color(0xFFFFF0C6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Colaborador ${flete.encargado ?? "N/A"}',
          style: TextStyle(
            color: Color(0xFFFFF0C6),
            fontSize: 16,
          ),
        ),
        Divider(color: Color(0xFFFFF0C6)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enviado por',
                  style: TextStyle(
                      color: Color(0xFFFFF0C6), fontWeight: FontWeight.bold),
                ),
                Text(
                  flete.supervisorSalida ?? 'N/A',
                  style: TextStyle(color: Color(0xFFFFF0C6)),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recibido por',
                  style: TextStyle(
                      color: Color(0xFFFFF0C6), fontWeight: FontWeight.bold),
                ),
                Text(
                  flete.supervisorLlegada ?? 'N/A',
                  style: TextStyle(color: Color(0xFFFFF0C6)),
                ),
              ],
            ),
          ],
        ),
        Divider(color: Color(0xFFFFF0C6)),
        Text(
          'Fecha de Salida: ${DateFormat('dd/MM/yy, hh:mm a').format(flete.flenFechaHoraSalida!)}',
          style: TextStyle(color: Color(0xFFFFF0C6)),
        ),
        Text(
          'Fecha de Llegada: ${DateFormat('dd/MM/yy, hh:mm a').format(flete.flenFechaHoraEstablecidaDeLlegada!)}',
          style: TextStyle(color: Color(0xFFFFF0C6)),
        ),
        Text(
          'Destino: ${flete.flenDestinoProyecto == 0 ? "Bodega" : "Proyecto"}',
          style: TextStyle(color: Color(0xFFFFF0C6)),
        ),
        Text(
          'Destino Nombre: ${flete.destino ?? "N/A"}',
          style: TextStyle(color: Color(0xFFFFF0C6)),
        ),
        Divider(color: Color(0xFFFFF0C6)),
      ],
    );
  }

  Widget _buildDetallesFlete(List<FleteDetalleViewModel> detalles) {
    // Filtrar detalles por tipo de carga y si llegaron o no
    final insumosLlegaron = detalles
        .where((d) => d.fldeTipodeCarga == true && d.fldeLlegada == true)
        .toList();
    final insumosNoLlegaron = detalles
        .where((d) => d.fldeTipodeCarga == true && d.fldeLlegada == false)
        .toList();
    final equiposLlegaron = detalles
        .where((d) => d.fldeTipodeCarga == false && d.fldeLlegada == true)
        .toList();
    final equiposNoLlegaron = detalles
        .where((d) => d.fldeTipodeCarga == false && d.fldeLlegada == false)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (insumosLlegaron.isNotEmpty)
          _buildExpandableSection(
              'Insumos Llegaron', _buildTablaInsumos(insumosLlegaron)),
        if (insumosNoLlegaron.isNotEmpty)
          _buildExpandableSection(
              'Insumos No Llegaron', _buildTablaInsumos(insumosNoLlegaron)),
        if (equiposLlegaron.isNotEmpty)
          _buildExpandableSection(
              'Equipos Llegaron', _buildTablaEquipos(equiposLlegaron)),
        if (equiposNoLlegaron.isNotEmpty)
          _buildExpandableSection(
              'Equipos No Llegaron', _buildTablaEquipos(equiposNoLlegaron)),
      ],
    );
  }

  Widget _buildExpandableSection(String title, Widget content) {
    return ExpansionTile(
      title: Text(
        title,
        style: TextStyle(
          color: Color(0xFFFFF0C6),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      children: [content],
    );
  }

  Widget _buildTablaInsumos(List<FleteDetalleViewModel> detalles) {
    return Table(
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2.5),
        2: FlexColumnWidth(1.5),
      },
      border: TableBorder.all(color: Color(0xFFFFF0C6), width: 1),
      children: [
        _buildTableHeader(['Descripción', 'Unidad de Medida', 'Cantidad']),
        ...detalles
            .map((detalle) => _buildTableRow([
                  detalle.insuDescripcion ?? 'N/A',
                  detalle.unmeNomenclatura ?? 'N/A',
                  detalle.fldeCantidad.toString(),
                ]))
            .toList(),
      ],
    );
  }

  Widget _buildTablaEquipos(List<FleteDetalleViewModel> detalles) {
    return Table(
      columnWidths: {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2.5),
        2: FlexColumnWidth(1.5),
      },
      border: TableBorder.all(color: Color(0xFFFFF0C6), width: 1),
      children: [
        _buildTableHeader(['Equipo', 'Descripción', 'Cantidad']),
        ...detalles
            .map((detalle) => _buildTableRow([
                  detalle.equsNombre ?? 'N/A',
                  detalle.equsDescripcion ?? 'N/A',
                  detalle.fldeCantidad.toString(),
                ]))
            .toList(),
      ],
    );
  }

  Widget _buildIncidenciasFlete(
      List<FleteControlCalidadViewModel> incidencias) {
    return incidencias.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExpandableSection(
                'Incidencias',
                Table(
                  columnWidths: {
                    0: FlexColumnWidth(4),
                    1: FlexColumnWidth(2),
                  },
                  border: TableBorder.all(color: Color(0xFFFFF0C6), width: 1),
                  children: [
                    _buildTableHeader(
                        ['Descripción de la Incidencia', 'Fecha y Hora']),
                    ...incidencias
                        .map((incidencia) => _buildTableRow([
                              incidencia.flccDescripcionIncidencia ?? 'N/A',
                              DateFormat('dd/MM/yy, hh:mm a')
                                  .format(incidencia.flccFechaHoraIncidencia!),
                            ]))
                        .toList(),
                  ],
                ),
              ),
            ],
          )
        : SizedBox.shrink();
  }

  TableRow _buildTableHeader(List<String> headers) {
    return TableRow(
      decoration: BoxDecoration(
        color: Color(0xFF171717),
      ),
      children: headers.map((header) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            header,
            style: TextStyle(
              color: Color(0xFFFFF0C6),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  TableRow _buildTableRow(List<String> cells) {
    return TableRow(
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      children: cells.map((cell) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            cell,
            style: TextStyle(
              color: Color(0xFFFFF0C6),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildListaFletes() {
    return Scaffold(
      backgroundColor: Colors.black,
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
              child: _isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFFFFF0C6)),
                    )
                  : _filteredFletes.isEmpty
                      ? Center(
                          child: Text(
                            'No hay datos disponibles',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Column(
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
                                      ],
                                    ),
                                    ..._filteredFletes
                                        .sublist(
                                            _currentPage * _rowsPerPage,
                                            (_currentPage * _rowsPerPage +
                                                        _rowsPerPage >
                                                    _filteredFletes.length)
                                                ? _filteredFletes.length
                                                : _currentPage * _rowsPerPage +
                                                    _rowsPerPage)
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final index = entry.key;
                                      final flete = entry.value;
                                      return _buildFleteRow(flete,
                                          _currentPage * _rowsPerPage + index);
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Mostrando ${_currentPage * _rowsPerPage + 1} al ${(_currentPage * _rowsPerPage + _rowsPerPage > _filteredFletes.length) ? _filteredFletes.length : _currentPage * _rowsPerPage + _rowsPerPage} de ${_filteredFletes.length} entradas',
                              style: TextStyle(color: Colors.white),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_back),
                                  onPressed: _currentPage > 0
                                      ? () {
                                          setState(() {
                                            _currentPage--;
                                          });
                                        }
                                      : null,
                                ),
                                IconButton(
                                  icon: Icon(Icons.arrow_forward),
                                  onPressed: (_currentPage + 1) * _rowsPerPage <
                                          _filteredFletes.length
                                      ? () {
                                          setState(() {
                                            _currentPage++;
                                          });
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificacionFlete() {
    return Container(
      color: Colors
          .black, // Establece el color de fondo negro para la pantalla de verificación del flete
      child: FutureBuilder<List<FleteDetalleViewModel>>(
        future: FleteDetalleService.Buscar(_flenIdSeleccionado!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: Color(0xFFFFF0C6)),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar los datos',
                style: TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: Text(
                'No se encontraron datos del flete',
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            final detalles = snapshot.data!;

            return FutureBuilder<List<FleteControlCalidadViewModel>>(
              future: _incidenciasFuture,
              builder: (context, snapshotIncidencias) {
                if (snapshotIncidencias.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Color(0xFFFFF0C6)),
                  );
                } else if (snapshotIncidencias.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar las incidencias',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshotIncidencias.hasData) {
                  return Center(
                    child: Text(
                      'No se encontraron incidencias',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                } else {
                  final incidencias = snapshotIncidencias.data!;

                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: ListView(
                          padding: EdgeInsets.only(
                              bottom:
                                  70.0), // Espacio en la parte inferior para el botón
                          children: [
                            _buildEncabezadoFlete(
                              _allFletes.firstWhere((flete) =>
                                  flete.flenId == _flenIdSeleccionado),
                            ),
                            _buildDetallesFlete(detalles),
                            _buildIncidenciasFlete(incidencias),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Colors
                              .black, // Fondo negro para el área del botón
                          padding: const EdgeInsets.all(10.0),
                          child: Row(
                            children: [
                              Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 10.0, right: 10.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF171717),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 35, vertical: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _viendoVerificacion = false;
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: CustomAppBar(
          unreadCount: _unreadCount,
          onNotificationsUpdated: _loadNotifications),
      drawer: MenuLateral(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
      body:
          _viendoVerificacion ? _buildVerificacionFlete() : _buildListaFletes(),
      floatingActionButton: _viendoVerificacion
          ? null // No mostrar el botón si está en la vista de verificación
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NuevoFlete(),
                  ),
                );
              },
              backgroundColor: Color(0xFFFFF0C6),
              child: Icon(Icons.add, color: Colors.black),
              shape: CircleBorder(),
            ),
    );
  }
}
