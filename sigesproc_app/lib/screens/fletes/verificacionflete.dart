import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sigesproc_app/services/fletes/fletedetalleservice.dart';
import 'package:sigesproc_app/models/fletes/fletedetalleviewmodel.dart';

class VerificarFlete extends StatefulWidget {
  final int flenId;

  VerificarFlete({required this.flenId});

  @override
  _VerificarFleteState createState() => _VerificarFleteState();
}

class _VerificarFleteState extends State<VerificarFlete> {
  DateTime? fechaHoraLlegada;

  List<FleteDetalleViewModel> insumosNoRecibidos = [];
  List<FleteDetalleViewModel> insumosVerificados = [];

  @override
  void initState() {
    super.initState();
    _cargarInsumos();
  }

  Future<void> _cargarInsumos() async {
    try {
      List<FleteDetalleViewModel> insumos =
          await FleteDetalleService.Buscar(widget.flenId);
      setState(() {
        insumosNoRecibidos = insumos;
      });
    } catch (e) {
      print('Error al cargar los insumos: $e');
    }
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
          fechaHoraLlegada = DateTime(
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

  void _moverInsumoARecibido(FleteDetalleViewModel insumo) {
    setState(() {
      insumosNoRecibidos.remove(insumo);
      insumosVerificados.add(insumo);
    });
  }

  void _moverInsumoANoRecibido(FleteDetalleViewModel insumo) {
    setState(() {
      insumosVerificados.remove(insumo);
      insumosNoRecibidos.add(insumo);
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
                'Verificar Flete',
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                  SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInsumosSection(
                            'Insumos No Recibidos', _buildInsumosNoRecibidos()),
                        SizedBox(height: 20),
                        _buildInsumosSection(
                            'Insumos Verificados', _buildInsumosVerificados()),
                      ],
                    ),
                  ),
                  SizedBox(
                      height:
                          100), // Espacio para evitar que los botones tapen la tabla
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black,
              padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF171717),
                      padding:
                          EdgeInsets.symmetric(horizontal: 35, vertical: 15),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 35, vertical: 15),
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
            ),
          ),
        ],
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

  Widget _buildInsumosSection(String title, Widget table) {
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

  Widget _buildInsumosNoRecibidos() {
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
            SizedBox(), // Celda para el checkbox
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
        ..._buildInsumosRows(insumosNoRecibidos, true),
      ],
    );
  }

  Widget _buildInsumosVerificados() {
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
            SizedBox(), // Celda para el checkbox
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
        ..._buildInsumosRows(insumosVerificados, false),
      ],
    );
  }

  List<TableRow> _buildInsumosRows(
      List<FleteDetalleViewModel> insumos, bool esNoRecibido) {
    return insumos.map((insumo) {
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
                  _moverInsumoARecibido(insumo);
                } else {
                  _moverInsumoANoRecibido(insumo);
                }
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              insumo.insuDescripcion ?? '',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              insumo.unmeNombre ?? '',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: esNoRecibido
                ? Text(
                    insumo.fldeCantidad.toString(),
                    style: TextStyle(color: Colors.white),
                  )
                : TextField(
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: insumo.fldeCantidad.toString(),
                      hintStyle: TextStyle(color: Colors.white),
                    ),
                    onChanged: (value) {
                      setState(() {
                        int cantidad =
                            int.tryParse(value) ?? insumo.fldeCantidad!;
                        if (cantidad > insumo.fldeCantidad!) {
                          // Limitar la cantidad a la disponible
                          cantidad = insumo.fldeCantidad!;
                        } else if (cantidad < 1) {
                          // Evitar que la cantidad sea menor a 1
                          cantidad = 1;
                        }
                        insumo.fldeCantidad = cantidad;
                      });
                    },
                    controller: TextEditingController(
                      text: insumo.fldeCantidad.toString(),
                    ),
                  ),
          ),
        ],
      );
    }).toList();
  }
}
