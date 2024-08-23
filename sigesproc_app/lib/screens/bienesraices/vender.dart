import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:intl/intl.dart';
import 'package:sigesproc_app/models/generales/clienteviewmodel.dart';
import 'package:sigesproc_app/services/generales/clienteservice.dart';

class Venta extends StatefulWidget {
  final int btrpId;
  final int btrpTerrenoOBienRaizId;
  final int btrpBienoterrenoId;

  Venta({
    required this.btrpId,
    required this.btrpTerrenoOBienRaizId,
    required this.btrpBienoterrenoId,
  });

  @override
  _VentaState createState() => _VentaState();
}

class _VentaState extends State<Venta> {
  TextEditingController clienteController = TextEditingController();
  TextEditingController nombreController = TextEditingController();
  TextEditingController telefonoController = TextEditingController();
  TextEditingController precioController = TextEditingController();
  TextEditingController fechaController = TextEditingController();

  bool _precioFueEditado = false;
  bool _fechaFueEditada = false;

  List<ClienteViewModel> clientes = [];
  late StreamSubscription<bool> keyboardSubscription;
  bool _isKeyboardVisible = false;

  final ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: Color(0xFFFFF0C6),
      onPrimary: Colors.black,
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    dialogBackgroundColor: Colors.black,
  );

  void initState() {
    super.initState();
    _cargarClientes();
    var keyboardVisibilityController = KeyboardVisibilityController();
    // Query
    _isKeyboardVisible = keyboardVisibilityController.isVisible;

    // Subscribe
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

  Future<void> _cargarClientes() async {
    try {
      List<ClienteViewModel> listaClientes = await ClienteService.listarClientes();
      setState(() {
        clientes = listaClientes;
      });
    } catch (e) {
      print('Error al cargar los clientes: $e');
    }
  }
  Future<void> _cargarDatosCliente() async {
    try {
      List<ClienteViewModel> listaClientes = await ClienteService.listarClientes();
      setState(() {
        clientes = listaClientes;
      });
      ClienteViewModel? cliente =
              await ClienteService.obtenerCliente(venta.clieId!);
          if (cliente != null) {
            clienteController.text = cliente.cliente;
          }
    } catch (e) {
      print('Error al cargar los clientes: $e');
    }
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
                'Vender Propiedad',
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
        child: _buildVentaView(),
      ),
      bottomNavigationBar: Container(
        color: Colors.black, // Establece el fondo como negro
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _buildSaveCancelButtons(),
      ),
    );
  }

  Widget _buildVentaView() {
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
                  _buildTextField(
                      'DNI del Cliente', dniController, 'Buscar...'),
                  SizedBox(height: 20),
                  _buildTextField('Nombre Completo', nombreController, ''),
                  SizedBox(height: 20),
                  _buildTextField('Teléfono', telefonoController, ''),
                  SizedBox(height: 20),
                  _buildTextField('Precio Final', precioController, '0.00',
                      isNumeric: true),
                  SizedBox(height: 20),
                  _buildDateField('Fecha de Venta Final', fechaController),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

   Widget _buildDNIAutocomplete(TextEditingController controller) {
    bool isError = false;
    String errorMessage = '';

    FocusNode focusNode = FocusNode();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Autocomplete<ClienteViewModel>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return clientes.isNotEmpty
                  ? clientes
                  : []; // Mostrar todas las opciones cuando el campo está vacío
            }
            return clientes.where((ClienteViewModel option) {
              return option.cliente!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          displayStringForOption: (ClienteViewModel option) =>
              option.cliente!,
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode fieldFocusNode,
              VoidCallback onFieldSubmitted) {
            focusNode = fieldFocusNode;
            textEditingController.text = controller.text;
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'Identidad',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black,
                labelStyle: TextStyle(color: Colors.white),
                errorText: isError ? errorMessage : null,
                errorMaxLines: 3,
                errorStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFF0C6)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFFFF0C6)),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear, color: Color(0xFFFFF0C6)),
                        onPressed: () {
                          setState(() {
                            controller.clear();
                              venta.clieId = null;
                          });
                        },
                      ),
                    IconButton(
                      icon:
                          Icon(Icons.arrow_drop_down, color: Color(0xFFFFF0C6)),
                      onPressed: () {
                        if (focusNode.hasFocus) {
                          focusNode.unfocus();
                        } else {
                          focusNode.requestFocus();
                        }
                      },
                    ),
                  ],
                ),
              ),
              style: TextStyle(color: Colors.white),
              maxLines: null,
            );
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<ClienteViewModel> onSelected,
              Iterable<ClienteViewModel> options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: Container(
                  width: constraints.maxWidth,
                  color: Colors.black,
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: options.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      final ClienteViewModel option = options.elementAt(index);
                      return GestureDetector(
                        onTap: () {
                          onSelected(option);
                        },
                        child: ListTile(
                          title: Text(option.cliente!,
                              style: TextStyle(color: Colors.white)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          onSelected: (ClienteViewModel selection) {
            setState(() {
              controller.text = selection.cliente!;
                venta.clieId = selection.clieId;
                _cargarDatosCliente(venta.clieId!);
            });
          },
        );
      },
    );
  }


  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.black,
            suffixIcon: Icon(Icons.calendar_today, color: Color(0xFFFFF0C6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
          ),
          style: TextStyle(color: Colors.white),
          readOnly: true,
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
              controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
              setState(() {
                _fechaFueEditada = true;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildSaveCancelButtons() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () {
              // Acción para guardar
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFF0C6),
              padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              'Guardar',
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF171717),
              padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text(
              'Regresar',
              style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 15),
            ),
          ),
          
        ],
      ),
    );
  }

  bool _isFormValid() {
    return dniController.text.isNotEmpty &&
        nombreController.text.isNotEmpty &&
        telefonoController.text.isNotEmpty &&
        precioController.text.isNotEmpty &&
        fechaController.text.isNotEmpty;
  }
}
