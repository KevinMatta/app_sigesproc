import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:latlong2/latlong.dart';
import 'package:sigesproc_app/models/bienesraices/procesoventaviewmodel.dart';
import 'package:sigesproc_app/screens/bienesraices/ubicacion.dart';
import 'package:sigesproc_app/screens/bienesraices/venta.dart';
import '../menu.dart';
import 'package:sigesproc_app/services/bienesraices/procesoventaservice.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart'; // Asegúrate de importar intl para el formateo de fechas

class Vender extends StatefulWidget {
  final int btrpId;
  final int btrpTerrenoOBienRaizId;
  final int btrpBienoterrenoId;

  Vender({
    required this.btrpId,
    required this.btrpTerrenoOBienRaizId,
    required this.btrpBienoterrenoId,
  });

  @override
  _VenderState createState() => _VenderState();
}

class _VenderState extends State<Vender> {
  late Future<LatLng?> _destinoFuture;
  bool _isKeyboardVisible = false;
  late StreamSubscription<bool> keyboardSubscription;

  TextEditingController clienteController = TextEditingController();
  TextEditingController fechaSalidaController = TextEditingController();
  TextEditingController fechaHoraEstablecidaController = TextEditingController();
  TextEditingController valorController = TextEditingController();
  TextEditingController fechaController = TextEditingController();

  late ProcesoVentaViewModel venta;

  bool _fechaSalidaError = false;
  String _fechaSalidaErrorMessage = '';
  bool _fechaHoraEstablecidaError = false;
  String _fechaHoraEstablecidaErrorMessage = '';
  bool _valorFueEditado = false;
  bool _fechaFueEditada = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime? establishedDate;
  TimeOfDay? establishedTime;

  final ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: Color(0xFFFFF0C6),
      onPrimary: Colors.black,
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    dialogBackgroundColor: Colors.black,
  );

  @override
  void initState() {
    super.initState();

    venta = ProcesoVentaViewModel(
      codigo: '',
      btrpId: widget.btrpId,
      btrpTerrenoOBienRaizId: widget.btrpTerrenoOBienRaizId.isEven,
      btrpBienoterrenoId: widget.btrpBienoterrenoId,
    );

    var keyboardVisibilityController = KeyboardVisibilityController();
    _isKeyboardVisible = keyboardVisibilityController.isVisible;

    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        _isKeyboardVisible = visible;
      });
    });
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vender'),
      ),
      body: _buildFleteView(),
    );
  }

  Widget _buildFleteView() {
    return SingleChildScrollView(
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
                    'DNI del Cliente:',
                    style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  _buildAutocomplete('Buscar...', clienteController),
                  SizedBox(height: 20),
                  Text(
                    'Nombre Completo:',
                    style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Teléfono:',
                    style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: valorController,
                    decoration: InputDecoration(
                      hintText: 'Valor de venta',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white24,
                      errorText: _valorFueEditado &&
                              _isValorInvalido(valorController.text)
                          ? 'Ingrese un valor válido'
                          : null,
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (text) {
                      setState(() {
                        _valorFueEditado = true;
                      });
                    },
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: fechaController,
                    decoration: InputDecoration(
                      hintText: 'Fecha de venta',
                      hintStyle: TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white24,
                      suffixIcon: Icon(Icons.calendar_today, color: Colors.white54),
                      errorText: _fechaFueEditada &&
                              _isFechaInvalida(fechaController.text)
                          ? 'Ingrese una fecha válida'
                          : null,
                    ),
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.datetime,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: darkTheme,
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        fechaController.text =
                            DateFormat('dd/MM/yyyy').format(pickedDate);
                        setState(() {
                          _fechaFueEditada = true;
                        });
                      }
                    },
                    onChanged: (text) {
                      setState(() {
                        _fechaFueEditada = true;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _valorFueEditado = true;
                _fechaFueEditada = true;
              });

              if (_isValorInvalido(valorController.text) ||
                  _isFechaInvalida(fechaController.text)) {
                return; // Mostrar errores si hay
              }

              try {
                venta.btrpPrecioVentaFinal =
                    double.parse(valorController.text);
                venta.btrpFechaVendida =
                    DateFormat('dd/MM/yyyy').parse(fechaController.text);

                await ProcesoVentaService.venderProcesoVenta(venta);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Propiedad vendida con éxito')),
                );
                setState(() {
                  // Realiza cualquier acción adicional necesaria
                });
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al vender la propiedad')),
                );
              }
            },
            child: Text('Guardar'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _valorFueEditado = false;
                _fechaFueEditada = false;
              });
            },
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildAutocomplete(String label, TextEditingController controller) {
    bool isError = false;
    String errorMessage = '';

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.black,
        labelStyle: TextStyle(color: Colors.white),
        errorText: isError ? errorMessage : null,
      ),
      style: TextStyle(color: Colors.white),
    );
  }

  bool _isValorInvalido(String valor) {
    if (valor.isEmpty) return true;
    final parsedValue = double.tryParse(valor);
    return parsedValue == null || parsedValue <= 0;
  }

  bool _isFechaInvalida(String fecha) {
    if (fecha.isEmpty) return true;
    try {
      DateFormat('dd/MM/yyyy').parse(fecha);
      return false;
    } catch (e) {
      return true;
    }
  }
}
