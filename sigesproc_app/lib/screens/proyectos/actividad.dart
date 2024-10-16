import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:sigesproc_app/models/proyectos/actividadporetapaviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/controlcalidadporactividadviewmodel.dart';
import 'package:sigesproc_app/screens/proyectos/controlcalidad.dart';
import 'package:sigesproc_app/services/proyectos/controlcalidadporactividadservice.dart';
import '../menu.dart';

class Actividad extends StatefulWidget {
  final List<ActividadesPorEtapaViewModel> actividades;
  final String? etapaNombre;

  const Actividad({Key? key, required this.actividades, required this.etapaNombre}) : super(key: key);

  @override
  _ActividadState createState() => _ActividadState();
}

class _ActividadState extends State<Actividad> {
  TextEditingController _searchController = TextEditingController();
  List<ActividadesPorEtapaViewModel> _actividadesFiltradas = [];
  int _currentPage = 0;
  int _rowsPerPage = 10;
  String? etapaName;
  Map<int, bool> _expandedActividades = {}; // Controla qué actividades están expandidas
  ScrollController _scrollController = ScrollController();
  double _savedScrollPosition = 0.0; // Guardar la posición del scroll
  int _savedCurrentPage = 0; // Variable para almacenar la página actual


  @override
  void initState() {
    super.initState();
    etapaName = widget.etapaNombre ?? "";
    _actividadesFiltradas = widget.actividades;
    _searchController.addListener(_actividadFiltrada);
  }

  @override
  void dispose() {
    _searchController.removeListener(_actividadFiltrada);
    _searchController.dispose();
    super.dispose();
  }

  void _actividadFiltrada() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _actividadesFiltradas = widget.actividades.where((actividad) {
        final salida = actividad.actiDescripcion?.toLowerCase() ?? '';
        return salida.contains(query);
      }).toList();
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
      if (_actividadesFiltradas.length > (_currentPage + 1) * _rowsPerPage) {
        _currentPage++;
      }
    });
  }

      void _toggleExpand(int acetId) {
    // Guardar la posición actual del scroll
    _savedScrollPosition = _scrollController.position.pixels;
    _savedCurrentPage = _currentPage;

    setState(() {
      // Verifica si acetId ya tiene una entrada en el mapa
      if (_expandedActividades[acetId] == null) {
        // Si no existe, inicializa con false (no expandido)
        _expandedActividades[acetId] = false;
      }

      // Si la fila está expandida, ciérrala
      if (_expandedActividades[acetId] == true) {
        _expandedActividades[acetId] = false;
      } else {
        // Cerrar todas las demás actividades expandidas
        _expandedActividades.updateAll((key, value) => false);
        // Expande la fila actual
        _expandedActividades[acetId] = true;
      }
    });

    // Restaurar la posición del scroll después del cambio de estado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _savedScrollPosition,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    });

    _currentPage = _savedCurrentPage;
  }



  void _navigateToControlCalidadScreen(BuildContext context, int acetId, String? medida, String? actividad) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ControlCalidadScreen(acetId: acetId, unidadMedida: medida, actividadNombre: actividad),
      ),
    );
  }

 void _mostrarDialogoAprobar(BuildContext context, int cocaId, double? cocaAprobado, int? acet_Id) {
  // Si ya está aprobado, no mostrar el diálogo
  if (cocaAprobado == 1) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Ya ha sido aprobado.",
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),)),
                        backgroundColor: Colors.yellow,
      ),
    );
    return;
  }

  // Captura el contexto actual antes de cerrar el diálogo
  final scaffoldContext = context;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        backgroundColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido a la izquierda
            children: <Widget>[
              Text(
                'Confirmación',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                '¿Está seguro de aprobar este control de calidad?',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end, // Alinea los botones a la derecha
                children: <Widget>[
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop(); // Cerrar el diálogo
                      try {
                        await ControlDeCalidadesPorActividadesService.aprobarControlDeCalidad(cocaId);
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          SnackBar(
                            content: Text("Aprobado con Éxito."),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Recargar la lista de controles de calidad aquí
                        // setState(() {
                        //   // _isLoading = true; // Iniciar la carga de nuevo
                        //   int id = acet_Id!;
                        //   _toggleExpand(id); // Recargar los datos
                        // });
                      } catch (e) {
                        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                          SnackBar(
                            content: Text("No se pudo aprobar."),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Confirmar',
                      style: TextStyle(
                        color: Color(0xFFFFF0C6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0), // Espacio entre los botones
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar el diálogo
                    },
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Color(0xFFFFF0C6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    final int totalRecords = _actividadesFiltradas.length;
    final int startIndex = _currentPage * _rowsPerPage;
    final int endIndex = (startIndex + _rowsPerPage > totalRecords) ? totalRecords : startIndex + _rowsPerPage;

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
          preferredSize: Size.fromHeight(60.0),
          child: Column(
            children: [
              Text(
                'Etapa: $etapaName',
                style: TextStyle(
                  color: Color(0xFFFFF0C6),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.0),
              Container(
                height: 2.0,
                color: Color(0xFFFFF0C6),
              ),
              SizedBox(height: 5),
              Text(
                'Actividades:',
                style: TextStyle(
                  color: Color(0xFFFFF0C6),
                  fontSize: 16,
                ),
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
        selectedIndex: 1,
        onItemSelected: (index) {
          // Handle menu item selection
        },
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
              child: _actividadesFiltradas.isEmpty
                  ? Center(
                      child: Text(
                        'No hay actividades disponibles',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: endIndex - startIndex,
                      itemBuilder: (context, index) {
                        final actividad = _actividadesFiltradas[startIndex + index];
                        final bool isExpanded = _expandedActividades[actividad.acetId] == true;

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () => _navigateToControlCalidadScreen(
                                context,
                                actividad.acetId,
                                actividad.unmeNombre,
                                actividad.actiDescripcion,
                              ),
                              child: Card(
                                color: Color(0xFF171717),
                                margin: EdgeInsets.symmetric(vertical: 5.0),
                                child: ListTile(
                                  title: Text(
                                    actividad.actiDescripcion ?? 'N/A',
                                    style: TextStyle(color: Colors.white),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    'Precio mano de obra: L.${actividad.acetPrecioManoObraFinal?.toStringAsFixed(2)}',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                  leading: IconButton(
                                    icon: Icon(
                                      isExpanded ? Icons.arrow_drop_down : Icons.arrow_right_outlined,
                                      color: Color(0xFFFFF0C6),
                                    ),
                                    onPressed: () => _toggleExpand(actividad.acetId),
                                  ),
                                  trailing: Icon(
                                    Icons.adjust,
                                    color: actividad.acetEstado == true
                                        ? Colors.green
                                        : actividad.acetEstado == false
                                            ? Colors.red
                                            : Colors.yellow,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                            if (isExpanded)
                              FutureBuilder<List<ListarControlDeCalidadesPorActividadesViewModel>>(
                                future: ControlDeCalidadesPorActividadesService.listarControlCalidadPorActividad(actividad.acetId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return SizedBox(
                                      height: 300,  // Set a fixed height for the spinner section
                                      child: Center(
                                        child: SpinKitCircle(
                                          color: Color(0xFFFFF0C6),
                                          size: 50.0,
                                        ),
                                      ),
                                    );
                                  } else if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)),
                                    );
                                  } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
                                    return Center(
                                      child: Text('No hay controles de calidad disponibles.', style: TextStyle(color: Colors.white)),
                                    );
                                  } else {
                                    return Column(
                                      children: snapshot.data!.map((controlCalidad) {
                                        return ListTile(
                                            title: Text(
                                              controlCalidad.cocaDescripcion ?? 'Sin descripción',
                                              style: TextStyle(color: Colors.white),
                                            ),
                                            subtitle: Text(
                                              'Fecha: ${controlCalidad.cocaFecha != null ? DateFormat('dd-MM-yyyy').format(controlCalidad.cocaFecha!) : 'Fecha no disponible'}',
                                              style: TextStyle(color: Colors.white54),
                                            ),
                                            trailing: Icon(
                                              Icons.adjust,
                                              color: controlCalidad.cocaAprobado == 1 ? Colors.green : Colors.red,
                                              size: 20,
                                            ),
                                            onTap: () {
                                              _mostrarDialogoAprobar(context, controlCalidad.cocaId!, controlCalidad.cocaAprobado, controlCalidad.acetId);
                                            },
                                          );
                                      }).toList(),
                                    );
                                  }
                                },
                              ),
                          ],
                        );
                      },
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
            SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: SpeedDial(
        icon: Icons.arrow_downward,
        activeIcon: Icons.close,
        backgroundColor: Color(0xFF171717),
        foregroundColor: Color(0xFFFFF0C6),
        buttonSize: Size(56.0, 56.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        childrenButtonSize: Size(56.0, 56.0),
        spaceBetweenChildren: 10.0,
        overlayColor: Colors.transparent,
        children: [
          SpeedDialChild(
            child: Icon(Icons.arrow_back),
            backgroundColor: Color(0xFFFFF0C6),
            foregroundColor: Color(0xFF171717),
            shape: CircleBorder(),
            labelBackgroundColor: Color(0xFFFFF0C6),
            labelStyle: TextStyle(color: Color(0xFF171717)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
