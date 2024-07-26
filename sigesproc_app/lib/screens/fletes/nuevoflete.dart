import 'package:flutter/material.dart';
import 'package:sigesproc_app/screens/fletes/flete.dart';
import '../menu.dart';
import 'package:sigesproc_app/models/generales/empleadoviewmodel.dart';
import 'package:sigesproc_app/models/insumos/bodegaviewmodel.dart';
import 'package:sigesproc_app/services/generales/empleadoservice.dart';
import 'package:sigesproc_app/services/insumos/bodegaservice.dart';

class NuevoFlete extends StatefulWidget {
  @override
  _NuevoFleteState createState() => _NuevoFleteState();
}

class _NuevoFleteState extends State<NuevoFlete> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime? establishedDate;
  TimeOfDay? establishedTime;
  bool esProyecto = false;
  bool enCamino = false;
  List<EmpleadoViewModel> empleados = [];
  List<BodegaViewModel> bodegas = [];
  String? selectedBodegaSalida;
  String? selectedBodegaLlegada;
  @override
  void initState() {
    super.initState();
    _loadEmpleados();
    _loadBodegas();
  }

  Future<void> _loadEmpleados() async {
    try {
      List<EmpleadoViewModel> empleadosList =
          await EmpleadoService.listarEmpleados();
      setState(() {
        empleados = empleadosList;
      });
    } catch (e) {
      print('Error al cargar los empleados: $e');
    }
  }

  Future<void> _loadBodegas() async {
    try {
      List<BodegaViewModel> bodegasList = await BodegaService.listarBodegas();
      setState(() {
        bodegas = bodegasList;
      });
    } catch (e) {
      print('Error al cargar las bodegas: $e');
    }
  }

  Future<void> _selectDateTime({required bool isSalida}) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          if (isSalida) {
            selectedDate = pickedDate;
            selectedTime = pickedTime;
          } else {
            establishedDate = pickedDate;
            establishedTime = pickedTime;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Image.asset(
              'lib/assets/logo-sigesproc.png',
              height: 60,
            ),
            SizedBox(width: 10),
            Text(
              'SIGESPROC',
              style: TextStyle(color: Color(0xFFFFF0C6)),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40.0),
          child: Column(
            children: [
              Text(
                'Nuevo Flete',
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
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              Card(
                color: Color(0xFF171717),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fecha y Hora',
                        style:
                            TextStyle(color: Color(0xFFFFF0C6), fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      _fechaSalida(),
                      SizedBox(height: 20),
                      _fechaHoraEstablecida(),
                      SizedBox(height: 20),
                      Text(
                        'Empleados',
                        style:
                            TextStyle(color: Color(0xFFFFF0C6), fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      _buildAutocomplete('Encargado'),
                      SizedBox(height: 20),
                      _buildAutocomplete('Supervisor de Salida'),
                      SizedBox(height: 20),
                      _buildAutocomplete('Supervisor de Llegada'),
                      SizedBox(height: 20),
                      _switch('Es Proyecto', esProyecto, (value) {
                        setState(() {
                          esProyecto = value;
                        });
                      }),
                      SizedBox(height: 20),
                      Text(
                        'Ubicaciones',
                        style:
                            TextStyle(color: Color(0xFFFFF0C6), fontSize: 18),
                      ),
                      SizedBox(height: 10),
                      _buildBodegaDropdown('Salida'),
                      SizedBox(height: 20),
                      _buildBodegaDropdown('Llegada'),
                      SizedBox(height: 20),
                      _switch('En Camino', enCamino, (value) {
                        setState(() {
                          enCamino = value;
                        });
                      }),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Card(
                color: Color(0xFF171717),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Insumo',
                            style: TextStyle(
                                color: Color(0xFFFFF0C6), fontSize: 18),
                          ),
                          FloatingActionButton(
                            onPressed: () {
                            },
                            backgroundColor: Color(0xFFFFF0C6),
                            mini: true,
                            child: Icon(Icons.add_circle_outline,
                                color: Colors.black),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Table(
                        border: TableBorder.all(color: Colors.white),
                        columnWidths: {
                          0: FlexColumnWidth(3),
                          1: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Materiales',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Cantidad',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Material',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Ingrese Cantidad',
                                    hintStyle: TextStyle(color: Colors.white54),
                                  ),
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Flete(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF171717),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFFFFF0C6)),
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFF0C6),
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: Text(
                'Guardar',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fechaSalida() {
    return TextField(
      readOnly: true,
      onTap: () async {
        await _selectDateTime(isSalida: true);
      },
      decoration: InputDecoration(
        labelText: 'Salida',
        suffixIcon: Icon(Icons.calendar_today, color: Color(0xFFFFF0C6)),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.black,
        labelStyle: TextStyle(color: Colors.white),
      ),
      style: TextStyle(color: Colors.white),
      controller: TextEditingController(
        text: selectedDate == null || selectedTime == null
            ? ''
            : "${selectedDate!.toLocal().toString().split(' ')[0]} ${selectedTime!.format(context)}",
      ),
    );
  }

  Widget _fechaHoraEstablecida() {
    return TextField(
      readOnly: true,
      onTap: () async {
        await _selectDateTime(isSalida: false);
      },
      decoration: InputDecoration(
        labelText: 'Establecida de Llegada',
        suffixIcon: Icon(Icons.calendar_today, color: Color(0xFFFFF0C6)),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.black,
        labelStyle: TextStyle(color: Colors.white),
      ),
      style: TextStyle(color: Colors.white),
      controller: TextEditingController(
        text: establishedDate == null || establishedTime == null
            ? ''
            : "${establishedDate!.toLocal().toString().split(' ')[0]} ${establishedTime!.format(context)}",
      ),
    );
  }

  Widget _buildBodegaDropdown(String label) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.black,
        labelStyle: TextStyle(color: Colors.white),
      ),
      items: bodegas.map((BodegaViewModel bodega) {
        return DropdownMenuItem<String>(
          value: bodega.bodeDescripcion,
          child: Text(
            bodega.bodeDescripcion,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14),
          ),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          if (label == 'Salida') {
            selectedBodegaSalida = newValue;
          } else {
            selectedBodegaLlegada = newValue;
          }
        });
      },
      dropdownColor: Colors.black,
      style: TextStyle(color: Colors.white),
    );
  }

  Widget _buildAutocomplete(String label) {
    return Autocomplete<EmpleadoViewModel>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<EmpleadoViewModel>.empty();
        }
        return empleados.where((EmpleadoViewModel option) {
          return option.empleado!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()) ||
              option.emplDNI!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
        });
      },
      displayStringForOption: (EmpleadoViewModel option) => option.empleado!,
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.black,
            labelStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
        );
      },
      onSelected: (EmpleadoViewModel selection) {
        print('Selected: ${selection.empleado}');
      },
    );
  }

  Widget _switch(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 18),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Color(0xFFFFF0C6),
        ),
      ],
    );
  }
}
