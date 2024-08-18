import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:sigesproc_app/models/proyectos/actividadporetapaviewmodel.dart';
import 'package:sigesproc_app/screens/proyectos/controlcalidad.dart';
import '../menu.dart';


class Actividad extends StatefulWidget {
  final List<ActividadesPorEtapaViewModel> actividades;

  const Actividad({Key? key, required this.actividades}) : super(key: key);

  @override
  _ActividadState createState() => _ActividadState();
}

class _ActividadState extends State<Actividad> {
  TextEditingController _searchController = TextEditingController();
  List<ActividadesPorEtapaViewModel> _actividadesFiltradas = [];
  int _currentPage = 0;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
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

  void _navigateToControlCalidadScreen(BuildContext context, int acetId, String? medida) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ControlCalidadScreen(acetId: acetId, unidadMedida: medida ),
    ),
  );
}


  @override
Widget build(BuildContext context) {
  final int totalRecords = _actividadesFiltradas.length;
  final int startIndex = _currentPage * _rowsPerPage;
  final int endIndex = (startIndex + _rowsPerPage > totalRecords)
      ? totalRecords
      : startIndex + _rowsPerPage;

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
              'Actividades',
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
                    itemCount: endIndex - startIndex,
                    itemBuilder: (context, index) {
                      final actividad = _actividadesFiltradas[startIndex + index];
                      return GestureDetector(
                        onTap: () => _navigateToControlCalidadScreen(context, actividad.acetId, actividad.unmeNombre), // Abre la pantalla de controlCalidad
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
                              'Precio: L.${actividad.acetPrecioManoObraFinal?.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.white54),
                            ),
                            leading: Icon(
                              Icons.remove,
                              color: Color(0xFFFFF0C6),
                            ),
                            trailing: Icon(
                                  Icons.adjust,
                              color: actividad.acetEstado == true ? Colors.green : Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
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
      icon: Icons.arrow_downward,  // Icono inicial cuando está cerrado
      activeIcon: Icons.close,  // Icono cuando está abierto
      backgroundColor: Color(0xFF171717),  // Color de fondo del botón principal
      foregroundColor: Color(0xFFFFF0C6),  // Color del icono principal
      buttonSize: Size(56.0, 56.0),  // Tamaño del botón principal
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),  // Bordes redondeados para el botón principal
      ),
      childrenButtonSize: Size(56.0, 56.0),  // Tamaño de los botones secundarios
      spaceBetweenChildren: 10.0,  // Espacio entre los botones secundarios
      overlayColor: Colors.transparent,  // Color de la superposición cuando se abre el menú
      children: [
        SpeedDialChild(
          child: Icon(Icons.close),
          backgroundColor: Color(0xFFFFF0C6),
          foregroundColor: Color(0xFF171717),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          labelBackgroundColor: Color(0xFFFFF0C6),
          labelStyle: TextStyle(color: Color(0xFF171717)),
          onTap: () {
            Navigator.pop(context);  // Acción de regresar
          },
        ),
        SpeedDialChild(
          child: Icon(Icons.arrow_back),
          backgroundColor: Color(0xFFFFF0C6),
          foregroundColor: Color(0xFF171717),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          labelBackgroundColor: Color(0xFFFFF0C6),
          labelStyle: TextStyle(color: Color(0xFF171717)),
          onTap: () {
            // Acción sin definir
          },
        ),
      ],
    ),
  );
}
}