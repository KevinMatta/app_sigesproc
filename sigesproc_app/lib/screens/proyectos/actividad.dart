import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sigesproc_app/models/proyectos/actividadporetapaviewmodel.dart';
import '../menu.dart';
import 'package:sigesproc_app/models/proyectos/controlcalidadporactividadviewmodel.dart';
import 'package:sigesproc_app/services/proyectos/controlcalidadporactividadservice.dart';

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
  final _formKey = GlobalKey<FormState>();

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

  //"Modal" para control de calidad
  Future<void> _showActivityDialog(ActividadesPorEtapaViewModel actividad) async {
  TextEditingController descripcionController = TextEditingController();
  TextEditingController metrosController = TextEditingController();
  DateTime? selectedDate;

  final _formKey = GlobalKey<FormState>();
  bool showFechaError = false;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Color(0xFF171717),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: Color(0xFFFFF0C6)),
        ),
        title: Center(
          child: Text(
            'Actividad',
            style: TextStyle(color: Color(0xFFFFF0C6)),
          ),
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Ingresar la descripción:',
                        style: TextStyle(color: Color(0xFFFFF0C6)),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: descripcionController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Color(0xFF222222),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La descripción es requerida';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Ingresar los metros:',
                        style: TextStyle(color: Color(0xFFFFF0C6)),
                      ),
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: metrosController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Color(0xFF222222),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Los metros son requeridos';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      title: Text(
                        selectedDate == null
                            ? 'Seleccionar Fecha'
                            : DateFormat('dd-MM-yyyy').format(selectedDate!),
                        style: TextStyle(color: Color(0xFFFFF0C6)),
                      ),
                      trailing:
                          Icon(Icons.calendar_today, color: Color(0xFFFFF0C6)),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          locale: const Locale("es", "ES"),
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: Color(0xFFFFF0C6),
                                  surface: Colors.black,
                                ),
                                dialogBackgroundColor: Color(0xFF222222),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                            showFechaError = false;
                          });
                        }
                      },
                    ),
                    if (showFechaError) 
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Text(
                            'La fecha es requerida',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF222222),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFF0C6),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (selectedDate == null) {
                          setState(() {
                            showFechaError = true;
                          });
                          return;
                        }

                        final controlDeCalidadesViewModel = ControlDeCalidadesPorActividadesViewModel(
                          cocaDescripcion: descripcionController.text,
                          cocaFecha: selectedDate!,
                          usuaCreacion: 3,
                          // cocaFechaCreacion: DateTime.now(),
                          cocaMetrosTrabajados: double.tryParse(metrosController.text) ?? 0.0,
                          acetId: actividad.acetId,
                        );

                        try {
                          final respuesta = await ControlDeCalidadesPorActividadesService.insertarControlCalidad(controlDeCalidadesViewModel);
                          
                          if (respuesta.success) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Guardado con éxito"),
                              backgroundColor: Colors.green,
                            ));
                            Navigator.of(context).pop();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("No se pudo guardar."),
                              backgroundColor: Colors.red,
                            ));
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Error al guardar"),
                            backgroundColor: Colors.red,
                          ));
                        }
                      }
                    },


                    child: Text(
                      'Guardar',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
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
                          onTap: () => _showActivityDialog(actividad), // Abre la ventana modal al hacer clic en la fila
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
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFF0C6),
                    minimumSize: Size(150, 50), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0), 
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Regresar',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}