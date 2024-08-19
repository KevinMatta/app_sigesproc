import 'package:flutter/material.dart';
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/models/insumos/equipoporproveedorviewmodel.dart';
import 'package:sigesproc_app/screens/menu.dart';
import 'package:sigesproc_app/services/fletes/fletedetalleservice.dart';
import 'package:sigesproc_app/models/fletes/fletedetalleviewmodel.dart';
import 'package:sigesproc_app/services/fletes/fleteencabezadoservice.dart';
import 'package:intl/intl.dart';

class VerificarFlete extends StatefulWidget {
  final int flenId;

  VerificarFlete({required this.flenId});

  @override
  _VerificarFleteState createState() => _VerificarFleteState();
}

class _VerificarFleteState extends State<VerificarFlete>
    with SingleTickerProviderStateMixin {
  DateTime? fechaHoraLlegada;

  List<TextEditingController> quantityControllers = [];
  List<FleteDetalleViewModel> insumosNoRecibidos = [];
  List<FleteDetalleViewModel> insumosVerificados = [];
  List<FleteDetalleViewModel> equiposNoRecibidos = [];
  List<FleteDetalleViewModel> equiposVerificados = [];

  TabController? _tabController;
  int _selectedIndex = 2;

  FleteEncabezadoViewModel flete = FleteEncabezadoViewModel(
    codigo: '',
    flenFechaHoraSalida: null,
    flenFechaHoraEstablecidaDeLlegada: null,
    emtrId: null,
    emssId: null,
    emslId: null,
    boasId: null,
    boatId: null,
    flenEstado: null,
    flenDestinoProyecto: null,
    flenSalidaProyecto: null,
    usuaCreacion: null,
    flenFechaCreacion: null,
    usuaModificacion: null,
    flenFechaModificacion: null,
    flenEstadoFlete: null,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
  }

  Map<int, String> mapaEquipos = {};

  Future<void> _cargarDatos() async {
    try {
      // Cargar los datos del flete
      FleteEncabezadoViewModel? fleteCargado =
          await FleteEncabezadoService.obtenerFleteDetalle(widget.flenId);

      if (fleteCargado != null) {
        setState(() {
          flete = fleteCargado;
        });

        // Cargar los detalles de los insumos y equipos del flete
        List<FleteDetalleViewModel> detalles =
            await FleteDetalleService.Buscar(widget.flenId);

        // Cargar equipos desde EquipoPorProveedorViewModel usando el boasId del flete
        if (flete.boasId != null) {
          List<EquipoPorProveedorViewModel> equiposList =
              await FleteDetalleService.listarEquiposdeSeguridadPorBodega(flete.boasId!);

          // Crear un mapa para asociar inppId con el nombre del equipo
          for (var equipo in equiposList) {
            mapaEquipos[equipo.eqppId!] = equipo.equsNombre!;
          }
        }

        setState(() {
          insumosNoRecibidos = detalles.where((detalle) => detalle.fldeTipodeCarga == true).toList();
          equiposNoRecibidos = detalles.where((detalle) => detalle.fldeTipodeCarga == false).toList();
        });
      }
    } catch (e) {
      print('Error al cargar los insumos, equipos y el flete: $e');
    }
  }

  void _moverARecibido(FleteDetalleViewModel detalle, bool esInsumo) {
    setState(() {
      if (esInsumo) {
        insumosNoRecibidos.remove(detalle);
        insumosVerificados.add(detalle);
      } else {
        equiposNoRecibidos.remove(detalle);
        equiposVerificados.add(detalle);
      }
    });
  }

  void _moverANoRecibido(FleteDetalleViewModel detalle, bool esInsumo) {
    setState(() {
      if (esInsumo) {
        insumosVerificados.remove(detalle);
        insumosNoRecibidos.add(detalle);
      } else {
        equiposVerificados.remove(detalle);
        equiposNoRecibidos.add(detalle);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
      body: Column(
        children: [
          // Sección de Fecha y Hora de Llegada
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Color(0xFF171717),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha y Hora de Llegada:',
                    style: TextStyle(
                      color: Color(0xFFFFF0C6),
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  _buildFechaHoraLlegadaInput(),
                ],
              ),
            ),
          ),
          
          // Tabs de Insumos y Equipos de Seguridad
          Expanded(
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
                  indicatorColor: Color(0xFFFFF0C6),
                  tabs: [
                    Tab(text: 'Insumos'),
                    Tab(text: 'Equipos de Seguridad'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildItemsTab(insumosNoRecibidos, insumosVerificados, true),
                      _buildItemsTab(equiposNoRecibidos, equiposVerificados, false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButtons(),
      drawer: MenuLateral(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildFechaHoraLlegadaInput() {
    return TextField(
      readOnly: true,
      onTap: _seleccionarFechaHora,
      decoration: InputDecoration(
        suffixIcon: Icon(Icons.calendar_today, color: Color(0xFFFFF0C6)),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.black,
        labelStyle: TextStyle(color: Colors.white),
      ),
      style: TextStyle(color: Colors.white),
      controller: TextEditingController(
        text: fechaHoraLlegada != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(fechaHoraLlegada!)
            : '',
      ),
    );
  }

  Future<void> _seleccionarFechaHora() async {
    DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Color(0xFFFFF0C6),
              onPrimary: Colors.black,
              surface: Colors.black,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black,
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null) {
      TimeOfDay? horaSeleccionada = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Color(0xFFFFF0C6),
                onPrimary: Colors.black,
                surface: Colors.black,
                onSurface: Colors.white,
              ),
              dialogBackgroundColor: Colors.black,
            ),
            child: child!,
          );
        },
      );

      if (horaSeleccionada != null) {
        setState(() {
          flete.flenFechaHoraLlegada = DateTime(
            fechaSeleccionada.year,
            fechaSeleccionada.month,
            fechaSeleccionada.day,
            horaSeleccionada.hour,
            horaSeleccionada.minute,
          );
        });
      }
    }
  }

  Widget _buildItemsTab(List<FleteDetalleViewModel> noRecibidos,
      List<FleteDetalleViewModel> verificados, bool esInsumo) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
              'No Recibidos', _buildTable(noRecibidos, true, esInsumo)),
          SizedBox(height: 20),
          _buildSection(
              'Verificados', _buildTable(verificados, false, esInsumo)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget table) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Color(0xFFFFF0C6),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        table,
      ],
    );
  }

  Widget _buildTable(
      List<FleteDetalleViewModel> detalles, bool esNoRecibido, bool esInsumo) {
    return Table(
      columnWidths: {
        0: FlexColumnWidth(1),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Color(0xFF171717),
          ),
          children: [
            SizedBox(),
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
                'Unidad de Medida',
                style: TextStyle(
                  color: Color(0xFFFFF0C6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Cantidad',
                style: TextStyle(
                  color: Color(0xFFFFF0C6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        ..._buildRows(detalles, esNoRecibido, esInsumo),
      ],
    );
  }

  List<TableRow> _buildRows(
      List<FleteDetalleViewModel> detalles, bool esNoRecibido, bool esInsumo) {
    return detalles.map((detalle) {
      return TableRow(
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        children: [
          Checkbox(
            value: !esNoRecibido,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _moverARecibido(detalle, esInsumo);
                } else {
                  _moverANoRecibido(detalle, esInsumo);
                }
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              esInsumo
                  ? detalle.insuDescripcion ?? ''
                  : mapaEquipos[detalle.inppId] ??
                      '', // Usar el mapa para obtener el nombre del equipo
              style: TextStyle(color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              detalle.unmeNombre ?? '',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: esNoRecibido
                ? Text(
                    detalle.fldeCantidad.toString(),
                    style: TextStyle(color: Colors.white),
                  )
                : TextField(
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: detalle.fldeCantidad.toString(),
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    onChanged: (value) {
                      setState(() {
                        int cantidad =
                            int.tryParse(value) ?? detalle.fldeCantidad!;
                        if (cantidad > detalle.fldeCantidad!) {
                          cantidad = detalle.fldeCantidad!;
                        } else if (cantidad < 1) {
                          cantidad = 1;
                        }
                        detalle.fldeCantidad = cantidad;
                      });
                    },
                    controller: TextEditingController(
                      text: detalle.fldeCantidad.toString(),
                    ),
                  ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildBottomButtons() {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 35.0, vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF171717),
              padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFF0C6),
              padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              // Acción para guardar
            },
            child: Text(
              'Guardar',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
