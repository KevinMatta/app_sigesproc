import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sigesproc_app/models/viaticos/viaticoViewModel.dart';
import 'package:sigesproc_app/services/generales/empleadoservice.dart';
import 'package:sigesproc_app/services/proyectos/proyectoservice.dart';
import 'package:sigesproc_app/models/generales/empleadoviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sigesproc_app/services/viaticos/viaticoservice.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importa SharedPreferences
import '../menu.dart';

class EditarViatico extends StatefulWidget {
  final int viaticoId; // Recibe el ID del viático a editar

  EditarViatico({required this.viaticoId});

  @override
  _EditarViaticoState createState() => _EditarViaticoState();
}

class _EditarViaticoState extends State<EditarViatico> {
  int _selectedIndex = 5;
  final TextEditingController _montoController = TextEditingController();

  EmpleadoViewModel? _selectedEmpleado;
  ProyectoViewModel? _selectedProyecto;

  List<EmpleadoViewModel> _empleados = [];
  List<ProyectoViewModel> _proyectos = [];

  String? _empleadoError;
  String? _proyectoError;
  String? _montoError;

  ViaticoEncViewModel? _viatico; // Aquí almacenaremos el viático a editar
  bool _isLoading = false; // Variable para controlar el estado de carga
  int? _usuarioModificacion; // Variable para almacenar el ID del usuario que modifica

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Cargar el ID del usuario
    _cargarDatosIniciales();
  }

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usuarioModificacion = int.tryParse(prefs.getString('usuaId') ?? '');
    });
  }

  Future<void> _cargarDatosIniciales() async {
    setState(() {
      _isLoading = true; // Mostrar spinner
    });

    try {
      await _cargarEmpleados();
      await _cargarProyectos();
      await _cargarViatico();
    } catch (e) {
      print('Error al cargar los datos iniciales: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los datos iniciales: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Ocultar spinner
      });
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

  Future<void> _cargarViatico() async {
    try {
      ViaticoEncViewModel viatico = await ViaticosEncService.buscarViatico(widget.viaticoId);
      setState(() {
        _viatico = viatico;
        _montoController.text = viatico.vienMontoEstimado?.toString() ?? '';

        // Buscar el empleado asociado al viático
        EmpleadoViewModel? tempEmpleado = _empleados.firstWhere(
          (e) => e.emplId == viatico.emplId,
          orElse: () => EmpleadoViewModel(emplId: -1, emplDNI: 'No encontrado', empleado: 'Empleado no encontrado')
        );
        _selectedEmpleado = tempEmpleado.emplId != -1 ? tempEmpleado : null;

        // Buscar el proyecto asociado al viático
        ProyectoViewModel? tempProyecto = _proyectos.firstWhere(
          (p) => p.proyId == viatico.proyId,
          orElse: () => ProyectoViewModel(proyId: -1, proyNombre: 'No encontrado')
        );
        _selectedProyecto = tempProyecto.proyId != -1 ? tempProyecto : null;
      });
    } catch (e) {
      print('Error al cargar el viático: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el viático: $e')),
      );
    }
  }

  void _guardarViatico() async {
    setState(() {
      _empleadoError = _selectedEmpleado == null ? 'El campo es requerido' : null;
      _proyectoError = _selectedProyecto == null ? 'El campo es requerido' : null;
      _montoError = _montoController.text.isEmpty ? 'El campo es requerido' : null;
    });

    if (_empleadoError != null || _proyectoError != null || _montoError != null) {
      print('Formulario no válido:');
      if (_empleadoError != null) print(_empleadoError);
      if (_proyectoError != null) print(_proyectoError);
      if (_montoError != null) print(_montoError);
      return;
    }

    ViaticoEncViewModel viaticoActualizado = ViaticoEncViewModel(
      vienId: _viatico?.vienId,
      emplId: _selectedEmpleado!.emplId,
      proyId: _selectedProyecto!.proyId,
      vienMontoEstimado: double.parse(_montoController.text),
      vienFechaEmicion: _viatico?.vienFechaEmicion ?? DateTime.now(),
      usuaCreacion: _viatico?.usuaCreacion ?? 3,
      vienFechaCreacion: _viatico?.vienFechaCreacion ?? DateTime.now(),
      vienFechaModificacion: DateTime.now(),
      usuaModificacion: _usuarioModificacion, // Asignar el ID del usuario que modifica
    );

    try {
      await ViaticosEncService.actualizarViatico(viaticoActualizado);
      print('Viático actualizado con éxito.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Actualizado con éxito')),
      );
      Navigator.pop(context, true); // Retorna `true` al cerrar la pantalla
    } catch (e) {
      print('Error al actualizar el viático: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el viático: $e')),
      );
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
              height: 50,
            ),
            SizedBox(width: 2),
            Expanded(
              child: Text(
                'SIGESPROC',
                style: TextStyle(
                  color: Color(0xFFFFF0C6),
                  fontSize: 20,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: Column(
            children: [
              Text(
                'Editar Viático',
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
              SizedBox(height: 5),
      Row(
        children: [
          SizedBox(width: 5.0),
          GestureDetector(
            onTap: () {
              // Acción para el botón de "Regresar"
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0), // Padding superior de 10 píxeles
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back,
                    color: Color(0xFFFFF0C6),
                  ),
                  SizedBox(width: 3.0),
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
        ],
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
      body: _isLoading
          ? Center(
              child: SpinKitCircle(color: Color(0xFFFFF0C6)), // Spinner de carga
            )
          : Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16.0),
              child: _viatico == null
                  ? Center(
                      child: Text(
                        'Error al cargar el viático',
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  : Column(
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
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                                SizedBox(height: 20),
                                _buildDropdownProyecto(),
                                if (_proyectoError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      _proyectoError!,
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                                SizedBox(height: 20),
                                _buildMontoTextField(),
                                if (_montoError != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: Text(
                                      _montoError!,
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 12),
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
