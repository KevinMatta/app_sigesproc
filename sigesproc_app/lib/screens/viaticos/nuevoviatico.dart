import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sigesproc_app/models/viaticos/viaticoViewModel.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/acceso/notificacion.dart';
import 'package:sigesproc_app/screens/acceso/perfil.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';
import 'package:sigesproc_app/services/generales/empleadoservice.dart';
import 'package:sigesproc_app/services/proyectos/proyectoservice.dart';
import 'package:sigesproc_app/models/generales/empleadoviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigesproc_app/services/viaticos/viaticoservice.dart';
import '../menu.dart';

class NuevoViatico extends StatefulWidget {
  @override
  _NuevoViaticoState createState() => _NuevoViaticoState();
}

class _NuevoViaticoState extends State<NuevoViatico> {
  int _selectedIndex = 5;
  DateTime _fechaEmision = DateTime.now();
  int? _usuarioCreacion;
  TextEditingController _montoController = TextEditingController();
  EmpleadoViewModel? _selectedEmpleado;
  ProyectoViewModel? _selectedProyecto;

  List<EmpleadoViewModel> _empleados = [];
  List<ProyectoViewModel> _proyectos = [];
  int _unreadCount = 0;
  late int userId;

  String? _empleadoError;
  String? _proyectoError;
  String? _montoError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _cargarEmpleados();
    _cargarProyectos();
    var prefs = PreferenciasUsuario();
    userId = int.tryParse(prefs.userId) ?? 0;

    _loadNotifications();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usuarioCreacion = int.tryParse(prefs.getString('usuaId') ?? '');
    });
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
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
      _empleadoError = _selectedEmpleado == null ? 'El campo es requerido' : null;
      _proyectoError = _selectedProyecto == null ? 'El campo es requerido' : null;
      _montoError = _montoController.text.isEmpty ? 'El campo es requerido' : null;
    });

    if (_empleadoError != null || _proyectoError != null || _montoError != null || _usuarioCreacion == null) {
      setState(() {
        _isSaving = false;
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
      Navigator.pop(context, true);
    } catch (e) {
      print('Error al guardar el viático: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el viático: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset(
              'lib/assets/logo-sigesproc.png', // Asegúrate de tener el logo
              height: 40,
            ),
            SizedBox(width: 10),
            Text(
              'SIGESPROC',
              style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 18),
            ),
          ],
        ),
        actions: [
          // Botón de notificaciones con el ícono amarillo claro
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Color(0xFFFFF0C6)),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificacionesScreen(),
                    ),
                  );
                  if (result != null) {
                    _loadNotifications();
                  }
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          // Botón de perfil con el ícono amarillo claro
          IconButton(
            icon: Icon(Icons.person, color: Color(0xFFFFF0C6)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(),
                ),
              );
            },
          ),
        ],
        iconTheme: IconThemeData(color: Color(0xFFFFF0C6)),
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
            Center(
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
            // Botón de "Regresar" debajo del título "Nuevo Viático"
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back,
                      color: Color(0xFFFFF0C6),
                    ),
                    SizedBox(width: 5.0),
                    Text(
                      'Regresar',
                      style: TextStyle(
                        color: Color(0xFFFFF0C6),
                        fontSize: 15.0,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.0),
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
            Spacer(),
            _buildBottomButtons(),
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
        Flexible(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFF0C6),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Reduce el padding horizontal
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              _guardarViatico();
            },
            icon: Icon(Icons.save, color: Colors.black),
            label: Text(
              'Guardar',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14, // Tamaño de texto más pequeño
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Flexible(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF171717),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Reduce el padding horizontal
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close, color: Colors.white),
            label: Text(
              'Cancelar',
              style: TextStyle(
                color: Color(0xFFFFF0C6),
                fontSize: 14, // Tamaño de texto más pequeño
              ),
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
            text: _selectedEmpleado?.emplDNI ?? ''),
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
          text: _selectedProyecto?.proyNombre ?? ''),
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
      // Convierte el patrón a minúsculas
      final lowerPattern = pattern.toLowerCase();
      // Filtra la lista de proyectos ignorando las mayúsculas y minúsculas
      return _proyectos
          .where((proyecto) => 
              proyecto.proyNombre?.toLowerCase().contains(lowerPattern) ?? false
          ).toList();
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
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp(r'^\d{0,9}')), // Permite solo hasta 9 dígitos
    ],
    decoration: InputDecoration(
      labelText: 'Monto a Desembolsar',
      labelStyle: TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.black,
      border: OutlineInputBorder(),
    ),
    style: TextStyle(color: Colors.white),
    onChanged: (value) {
      // Validar que el valor no sea negativo
      if (value.isNotEmpty && double.tryParse(value)! < 0) {
        // Si es negativo, eliminar el signo
        _montoController.text = value.replaceAll('-', '');
        _montoController.selection = TextSelection.fromPosition(
          TextPosition(offset: _montoController.text.length),
        );
      }
    },
  );
}

}
