import 'package:flutter/material.dart';
import 'package:sigesproc_app/models/viaticos/viaticoViewModel.dart';
// import 'package:sigesproc_app/services/viaticos/viaticosencservice.dart';
import 'package:sigesproc_app/services/generales/empleadoservice.dart';
import 'package:sigesproc_app/services/proyectos/proyectoservice.dart';
import 'package:sigesproc_app/models/generales/empleadoviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:sigesproc_app/services/viaticos/viaticoservice.dart';
import '../menu.dart';

class NuevoViatico extends StatefulWidget {
  @override
  _NuevoViaticoState createState() => _NuevoViaticoState();
}

class _NuevoViaticoState extends State<NuevoViatico> {
  int _selectedIndex = 5;
  DateTime _fechaEmision = DateTime.now();
  int _usuarioCreacion = 3; // ID del usuario que crea el viático
  TextEditingController _montoController = TextEditingController();

  EmpleadoViewModel? _selectedEmpleado;
  ProyectoViewModel? _selectedProyecto;

  List<EmpleadoViewModel> _empleados = [];
  List<ProyectoViewModel> _proyectos = [];

  @override
  void initState() {
    super.initState();
    _cargarEmpleados();
    _cargarProyectos();
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
    if (_selectedEmpleado == null || _selectedProyecto == null || _montoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete todos los campos.')),
      );
      return;
    }

    ViaticoEncViewModel nuevoViatico = ViaticoEncViewModel(
      emplId: _selectedEmpleado!.emplId, // Captura el ID del empleado
      proyId: _selectedProyecto!.proyId, // Captura el ID del proyecto
      vienMontoEstimado: double.parse(_montoController.text),
      vienFechaEmicion: _fechaEmision,
      usuaCreacion: _usuarioCreacion,
      vienFechaCreacion: _fechaEmision,
    );

    try {
      await ViaticosEncService.insertarViatico(nuevoViatico);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Viático guardado con éxito')),
      );
      Navigator.pop(context);  // Regresa a la pantalla anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el viático')),
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
                    SizedBox(height: 20),
                    _buildDropdownProyecto(),
                    SizedBox(height: 20),
                    _buildMontoTextField(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.arrow_downward, // Icono inicial
        activeIcon: Icons.close, // Icono cuando se despliega
        backgroundColor: Color(0xFF171717), // Color de fondo
        foregroundColor: Color(0xFFFFF0C6), // Color del icono
        buttonSize: Size(56.0, 56.0), // Tamaño del botón principal
        shape: CircleBorder(),
        childrenButtonSize: Size(56.0, 56.0),
        spaceBetweenChildren: 10.0, // Espacio entre los botones secundarios
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
          SpeedDialChild(
            child: Icon(Icons.save),
            backgroundColor: Color(0xFFFFF0C6),
            foregroundColor: Color(0xFF171717),
            shape: CircleBorder(),
            labelBackgroundColor: Color(0xFF171717),
            labelStyle: TextStyle(color: Colors.white),
            onTap: _guardarViatico,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownEmpleado() {
    return DropdownButtonFormField<EmpleadoViewModel>(
      decoration: InputDecoration(
        labelText: 'Identidad Empleado',
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(),
      ),
      dropdownColor: Colors.black,
      style: TextStyle(color: Colors.white),
      items: _empleados.map((EmpleadoViewModel empleado) {
        return DropdownMenuItem<EmpleadoViewModel>(
          value: empleado,
          child: Text(empleado.emplDNI ?? ''),
        );
      }).toList(),
      onChanged: (EmpleadoViewModel? empleado) {
        setState(() {
          _selectedEmpleado = empleado;
        });
      },
      value: _selectedEmpleado,
    );
  }

  Widget _buildDropdownProyecto() {
    return DropdownButtonFormField<ProyectoViewModel>(
      decoration: InputDecoration(
        labelText: 'Proyecto',
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(),
      ),
      dropdownColor: Colors.black,
      style: TextStyle(color: Colors.white),
      items: _proyectos.map((ProyectoViewModel proyecto) {
        return DropdownMenuItem<ProyectoViewModel>(
          value: proyecto,
          child: Text(proyecto.proyNombre ?? ''),
        );
      }).toList(),
      onChanged: (ProyectoViewModel? proyecto) {
        setState(() {
          _selectedProyecto = proyecto;
        });
      },
      value: _selectedProyecto,
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
