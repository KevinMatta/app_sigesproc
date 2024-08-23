import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:intl/intl.dart';
import 'package:sigesproc_app/models/bienesraices/procesoventaviewmodel.dart';
import 'package:sigesproc_app/models/generales/clienteviewmodel.dart';
import 'package:sigesproc_app/screens/bienesraices/procesoventa.dart';
import 'package:sigesproc_app/services/bienesraices/procesoventaservice.dart';
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
  TextEditingController dniController = TextEditingController();
  TextEditingController nombreclientecontroller = TextEditingController();
  TextEditingController apellidoController = TextEditingController();
  TextEditingController correoController = TextEditingController();
  TextEditingController telefonoclienteController = TextEditingController();
  TextEditingController fechaNacimientoController = TextEditingController();
  TextEditingController direccionController = TextEditingController();
  TextEditingController paisController = TextEditingController();
  TextEditingController estadoController = TextEditingController();
  TextEditingController ciudadController = TextEditingController();
  TextEditingController estadocivilController = TextEditingController();

  bool _precioFueEditado = false;
  bool _fechaFueEditada = false;

  List<ClienteViewModel> clientes = [];
  late StreamSubscription<bool> keyboardSubscription;
  bool _isKeyboardVisible = false;

  bool _mostrarFormularioCliente = false;
  String sexo = 'Femenino';
  String tipoCliente = 'Bien Raiz';

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
    _cargarClientes();
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

  Future<void> _cargarClientes() async {
    try {
      List<ClienteViewModel> listaClientes =
          await ClienteService.listarClientes();
      setState(() {
        clientes = listaClientes;
      });
    } catch (e) {
      print('Error al cargar los clientes: $e');
    }
  }

  Future<void> _cargarDatosCliente(int clienteId) async {
    try {
      ClienteViewModel? cliente =
          await ClienteService.obtenerCliente(clienteId);
      if (cliente != null) {
        setState(() {
          nombreController.text = cliente.clieNombreCompleto!;
          telefonoController.text = cliente.clieTelefono!;
        });
      }
    } catch (e) {
      print('Error al cargar los datos del cliente: $e');
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
                _mostrarFormularioCliente ? 'Cliente' : 'Vender Propiedad',
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
        child: _mostrarFormularioCliente ? _clienteVista() : _ventaVista(),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _buildSaveCancelButtons(),
      ),
    );
  }

 Widget _clienteVista() {
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
                _campoDeTextoCliente('DNI', dniController, 'Ingrese el DNI', isNumeric: true),
                SizedBox(height: 10),
                _campoDeTextoCliente('Nombre', nombreclientecontroller, 'Ingrese el nombre'),
                SizedBox(height: 10),
                _campoDeTextoCliente('Apellido', apellidoController, 'Ingrese el apellido'),
                SizedBox(height: 10),
                _campoDeTextoCliente('Correo Electrónico', correoController, 'Ingrese el correo', isEmail: true),
                SizedBox(height: 10),
                _campoDeTextoCliente('Teléfono', telefonoController, 'Ingrese el teléfono', isNumeric: true),
                SizedBox(height: 10),
                _buildDateField('Fecha de Nacimiento', fechaNacimientoController),
                SizedBox(height: 10),
                _buildRadioGroup('Sexo', ['Masculino', 'Femenino'], (value) {
                  setState(() {
                    sexo = value;
                  });
                }),
                SizedBox(height: 10),
                _buildRadioGroup('Tipo de Cliente', ['Bien Raiz', 'Proyecto', 'Ambos'], (value) {
                  setState(() {
                    tipoCliente = value;
                  });
                }),
                SizedBox(height: 10),
                _campoDeTextoCliente('Dirección Exacta', direccionController, 'Ingrese la dirección'),
                SizedBox(height: 10),
                _buildAutocompleteField('País', paisController),
                SizedBox(height: 10),
                _buildAutocompleteField('Estado', estadoController),
                SizedBox(height: 10),
                _buildAutocompleteField('Ciudad', ciudadController),
                SizedBox(height: 10),
                _buildAutocompleteField('Estado Civil', TextEditingController()),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildAutocompleteField(String label, TextEditingController controller) {
  FocusNode focusNode = FocusNode();

  return LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      return Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          // Aquí deberías definir las opciones disponibles para el autocomplete
          // En un caso real, podrías obtener estas opciones de una API o una lista local
          List<String> opciones = ['Opción 1', 'Opción 2', 'Opción 3'];

          if (textEditingValue.text.isEmpty) {
            return opciones;
          }

          return opciones.where((String option) {
            return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
          }).toList();
        },
        displayStringForOption: (String option) => option,
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
              labelText: label,
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.black,
              labelStyle: TextStyle(color: Colors.white),
            ),
            style: TextStyle(color: Colors.white),
            maxLines: 1,
          );
        },
        optionsViewBuilder: (BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options) {
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
                    final String option = options.elementAt(index);
                    return GestureDetector(
                      onTap: () {
                        onSelected(option);
                      },
                      child: ListTile(
                        title: Text(option, style: TextStyle(color: Colors.white)),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
        onSelected: (String selection) {
          setState(() {
            controller.text = selection;
          });
        },
      );
    },
  );
}



  Widget _campoDeTextoCliente(
      String label, TextEditingController controller, String hint,
      {bool isNumeric = false, bool isEmail = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(),
      ),
      style: TextStyle(color: Colors.white),
      keyboardType: isNumeric
          ? TextInputType.number
          : isEmail
              ? TextInputType.emailAddress
              : TextInputType.text,
      inputFormatters:
          isNumeric ? [FilteringTextInputFormatter.digitsOnly] : null,
    );
  }

  Widget _buildRadioGroup(
      String label, List<String> options, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white)),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: options.map((option) {
            return Row(
              children: [
                Radio<String>(
                  value: option,
                  groupValue: label == 'Sexo' ? sexo : tipoCliente,
                  onChanged: (value) {
                    onChanged(
                        value!); // Llamar a la función pasada como parámetro
                  },
                ),
                Text(option, style: TextStyle(color: Colors.white)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _ventaVista() {
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
                  _buildDNIAutocomplete(clienteController),
                  SizedBox(height: 20),
                  _campodeTexto('Nombre Completo', nombreController, '',
                      enabled: false),
                  SizedBox(height: 20),
                  _campodeTexto('Teléfono', telefonoController, '',
                      enabled: false),
                  SizedBox(height: 20),
                  _campodeTexto('Precio Final', precioController, '0.00',
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
    FocusNode focusNode = FocusNode();

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Autocomplete<ClienteViewModel>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return clientes;
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
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (textEditingController.text.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.clear, color: Color(0xFFFFF0C6)),
                              onPressed: () {
                                setState(() {
                                  textEditingController.clear();
                                  controller.clear();
                                });
                              },
                            ),
                          IconButton(
                            icon: Icon(Icons.arrow_drop_down,
                                color: Color(0xFFFFF0C6)),
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
                    maxLines: 1,
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
                            final ClienteViewModel option =
                                options.elementAt(index);
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
                    _cargarDatosCliente(selection.clieId!);
                  });
                },
              );
            },
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          color: Colors.black,
          icon: Icon(Icons.person_add, color: Color(0xFFFFF0C6)),
          onPressed: () {
            _mostrarFormularioCliente = true;
          },
        ),
      ],
    );
  }

  Widget _campodeTexto(
      String label, TextEditingController controller, String hint,
      {bool isNumeric = false, bool enabled = true}) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white),
        hintStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(),
      ),
      style: TextStyle(color: Colors.white),
      keyboardType: isNumeric
          ? TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: isNumeric
          ? [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ]
          : null,
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.black,
        suffixIcon: Icon(Icons.calendar_today, color: Color(0xFFFFF0C6)),
        border: OutlineInputBorder(),
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
            onPressed: () async {
              if (_isFormValid()) {
                try {
                  // Busca el cliente en la lista de clientes según el nombre en el controlador
                  ClienteViewModel? clienteSeleccionado = clientes.firstWhere(
                    (cliente) => cliente.cliente == clienteController.text,
                    orElse: () =>
                        ClienteViewModel(), // Devuelve un objeto vacío o usa otra lógica si prefieres
                  );

                  // Verifica que el cliente seleccionado sea válido
                  if (clienteSeleccionado.clieId != null) {
                    // Crea el modelo de venta con los datos necesarios
                    final venta = ProcesoVentaViewModel(
                      btrpId: widget.btrpId,
                      btrpPrecioVentaFinal: double.parse(precioController.text),
                      btrpFechaVendida:
                          DateFormat('dd/MM/yyyy').parse(fechaController.text),
                      clieId: clienteSeleccionado.clieId
                          .toString(), // Asigna el ID del cliente seleccionado
                    );

                    await ProcesoVentaService.venderProcesoVenta(venta);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProcesoVenta(),
                      ),
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Propiedad vendida con éxito')),
                    );
                  } else {
                    // Maneja el caso donde no se encontró un cliente
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Cliente no encontrado.')),
                    );
                  }
                } catch (e) {
                  // Maneja los errores que puedan ocurrir
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al vender la propiedad: $e')),
                  );
                }
              } else {
                // Maneja la validación fallida del formulario
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Por favor, complete todos los campos correctamente.')),
                );
              }
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
    return clienteController.text.isNotEmpty &&
        nombreController.text.isNotEmpty &&
        telefonoController.text.isNotEmpty &&
        precioController.text.isNotEmpty &&
        fechaController.text.isNotEmpty &&
        RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(precioController.text);
  }
}
