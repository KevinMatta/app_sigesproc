import 'package:flutter/material.dart';
import 'package:sigesproc_app/models/viaticos/viaticoViewModel.dart';
import 'package:sigesproc_app/services/generales/empleadoservice.dart';
import 'package:sigesproc_app/services/proyectos/proyectoservice.dart';
import 'package:sigesproc_app/models/generales/empleadoviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sigesproc_app/services/viaticos/viaticoservice.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Importa SharedPreferences
import '../menu.dart';

class NuevoViatico extends StatefulWidget {
  @override
  _NuevoViaticoState createState() => _NuevoViaticoState();
}

class _NuevoViaticoState extends State<NuevoViatico> {
  int _selectedIndex = 5;
  DateTime _fechaEmision = DateTime.now();
  int? _usuarioCreacion; // ID del usuario que crea el viático, ahora puede ser nulo hasta que se cargue
  TextEditingController _montoController = TextEditingController();

  EmpleadoViewModel? _selectedEmpleado;
  ProyectoViewModel? _selectedProyecto;

  List<EmpleadoViewModel> _empleados = [];
  List<ProyectoViewModel> _proyectos = [];

  // Variables para mostrar mensajes de error
  String? _empleadoError;
  String? _proyectoError;
  String? _montoError;
  bool _isSaving = false; // Bandera para prevenir duplicación

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Cargar datos del usuario
    _cargarEmpleados();
    _cargarProyectos();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usuarioCreacion = int.tryParse(prefs.getString('usuaId') ?? ''); // Obtener el ID del usuario desde SharedPreferences
    });
  }

  Future<void> _cargarEmpleados() async {
    try {
      List<EmpleadoViewModel> empleadosList = await EmpleadoService.listarEmpleados();
      setState(() {
        _empleados = empleadosList;
      });
    } catch (e) {
      print('Error al cargar los empleados: $e');
    }
  }

  Future<void> _cargarProyectos() async {
    try {
      List<ProyectoViewModel> proyectosList = await ProyectoService.listarProyectos();
      setState(() {
        _proyectos = proyectosList;
      });
    } catch (e) {
      print('Error al cargar los proyectos: $e');
    }
  }

  void _guardarViatico() async {
    if (_isSaving) return; // Prevenir múltiples llamadas

    setState(() {
      _isSaving = true; // Activar el estado de guardado
      _empleadoError = _selectedEmpleado == null ? 'El campo es requerido' : null;
      _proyectoError = _selectedProyecto == null ? 'El campo es requerido' : null;
      _montoError = _montoController.text.isEmpty ? 'El campo es requerido' : null;
    });

    if (_empleadoError != null || _proyectoError != null || _montoError != null || _usuarioCreacion == null) {
      setState(() {
        _isSaving = false; // Desactivar el estado de guardado si hay errores
      });
      return;
    }

    ViaticoEncViewModel nuevoViatico = ViaticoEncViewModel(
      emplId: _selectedEmpleado!.emplId,
      proyId: _selectedProyecto!.proyId,
      vienMontoEstimado: double.parse(_montoController.text),
      vienFechaEmicion: DateTime.now(),
      usuaCreacion: _usuarioCreacion!,
      vienFechaCreacion: DateTime.now(),
    );

    try {
      await ViaticosEncService.insertarViatico(nuevoViatico);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Insertado con Éxito.')),
      );
      Navigator.pop(context, true); // Devolver true para indicar que se ha guardado correctamente
    } catch (e) {
      print('Error al guardar el viático: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el viático: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false; // Desactivar el estado de guardado
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset(
              'lib/assets/logo-sigesproc.png',
              height: 50, // Ajusta la altura si es necesario
            ),
            SizedBox(width: 2), // Reduce el espacio entre el logo y el texto
            Expanded(
              child: Text(
                'SIGESPROC',
                style: TextStyle(
                  color: Color(0xFFFFF0C6),
                  fontSize: 20,
                ),
                textAlign: TextAlign.start, // Alinea el texto a la izquierda
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: Column(
            children: [
              Text(
                'Nuevo Viático',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Color(0xFF171717),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdownEmpleado(),
                    if (_empleadoError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          _empleadoError!,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    SizedBox(height: 20),
                    _buildDropdownProyecto(),
                    if (_proyectoError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          _proyectoError!,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    SizedBox(height: 20),
                    _buildMontoTextField(),
                    if (_montoError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          _montoError!,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Spacer(), // Añade un espacio flexible para empujar los botones hacia abajo
            _buildBottomButtons(), // Los botones personalizados al final
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 35.0, vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end, // Alinea los botones a la derecha
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFF0C6),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Reduce el tamaño del padding para hacer los botones más delgados
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Ajusta el borde a un radio más pequeño si lo prefieres
              ),
            ),
            onPressed: () {
              _guardarViatico(); // Llamada a la función de guardar viático sin await
            },

            child: Text(
              'Guardar',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14, // Reduce el tamaño del texto
              ),
            ),
          ),
          SizedBox(width: 10), // Espacio entre los botones
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF171717),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Reduce el tamaño del padding para hacer los botones más delgados
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Ajusta el borde a un radio más pequeño si lo prefieres
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14, // Reduce el tamaño del texto
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownEmpleado() {
    return TypeAheadFormField<EmpleadoViewModel>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: TextEditingController(
            text: _selectedEmpleado?.emplDNI ?? ''), // Inicializa con DNI
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Identidad Empleado',
          labelStyle: TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.black,
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.arrow_drop_down, color: Color(0xFFFFF0C6)),
        ),
      ),
      suggestionsCallback: (pattern) async {
        final lowerPattern = pattern.toLowerCase();
        return _empleados.where((empleado) {
          final dniMatch = empleado.emplDNI?.toLowerCase().contains(lowerPattern) ?? false;
          final nameMatch = empleado.empleado?.toLowerCase().contains(lowerPattern) ?? false;
          return dniMatch || nameMatch;
        }).toList();
      },
      itemBuilder: (context, EmpleadoViewModel suggestion) {
        return ListTile(
          title: Text(
            suggestion.emplDNI ?? '',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            suggestion.empleado ?? '',
            style: TextStyle(color: Colors.white70),
          ),
        );
      },
      onSuggestionSelected: (EmpleadoViewModel suggestion) {
        setState(() {
          _selectedEmpleado = suggestion;
        });
      },
      noItemsFoundBuilder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'No se encontraron empleados',
          style: TextStyle(color: Colors.white),
        ),
      ),
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        color: Colors.black,
      ),
    );
  }

  Widget _buildDropdownProyecto() {
    return TypeAheadFormField<ProyectoViewModel>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: TextEditingController(
            text: _selectedProyecto?.proyNombre ?? ''), // Inicializa con el nombre del proyecto
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Proyecto',
          labelStyle: TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.black,
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.arrow_drop_down, color: Color(0xFFFFF0C6)),
        ),
      ),
      suggestionsCallback: (pattern) async {
        return _proyectos
            .where((proyecto) => proyecto.proyNombre!.contains(pattern))
            .toList();
      },
      itemBuilder: (context, ProyectoViewModel suggestion) {
        return ListTile(
          title: Text(
            suggestion.proyNombre ?? '',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
      onSuggestionSelected: (ProyectoViewModel suggestion) {
        setState(() {
          _selectedProyecto = suggestion;
        });
      },
      noItemsFoundBuilder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'No se encontraron proyectos',
          style: TextStyle(color: Colors.white),
        ),
      ),
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        color: Colors.black,
      ),
    );
  }

  Widget _buildMontoTextField() {
    return TextField(
      controller: _montoController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Monto a Desembolsar',
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(),
      ),
      style: TextStyle(color: Colors.white),
    );
  }
}