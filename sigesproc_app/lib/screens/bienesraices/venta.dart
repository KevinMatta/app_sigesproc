import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:intl/intl.dart';
import 'package:sigesproc_app/models/bienesraices/procesoventaviewmodel.dart';
import 'package:sigesproc_app/models/generales/ciudadviewmodel.dart';
import 'package:sigesproc_app/models/generales/clienteviewmodel.dart';
import 'package:sigesproc_app/models/generales/estadocivilviewmodel.dart';
import 'package:sigesproc_app/models/generales/estadoviewmodel.dart';
import 'package:sigesproc_app/models/generales/paisviewmodel.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/bienesraices/procesoventa.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';
import 'package:sigesproc_app/services/bienesraices/procesoventaservice.dart';
import 'package:sigesproc_app/services/generales/ciudadservice.dart';
import 'package:sigesproc_app/services/generales/clienteservice.dart';
import 'package:sigesproc_app/services/generales/estadocivilservice.dart';
import 'package:sigesproc_app/services/generales/estadoservice.dart';
import 'package:sigesproc_app/services/generales/paisservice.dart';

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
  List<PaisViewModel> paises = [];
  List<EstadoViewModel> estados = [];
  List<CiudadViewModel> ciudades = [];
  List<EstadoCivilViewModel> estadosciviles = [];

  int? paisSeleccionadoId;
  int? estadoSeleccionadoId;
  CiudadViewModel? ciudadSeleccionada;
  EstadoCivilViewModel? estadoCivilSeleccionado;

  late StreamSubscription<bool> keyboardSubscription;
  bool _isKeyboardVisible = false;

  bool _mostrarFormularioCliente = false;
  String sexo = 'Femenino';
  String tipoCliente = 'Bien Raiz';
  bool _mostrarErrores = false;
  bool _mostrarErroresventa = false;

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
    _cargarPaises();
    _cargarEstadosCiviles();
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

  Future<void> _cargarPaises() async {
    try {
      List<PaisViewModel> listaPaises = await PaisService.listarPaises();
      setState(() {
        paises = listaPaises;
      });
    } catch (e) {
      print('Error al cargar los paises: $e');
    }
  }

  Future<void> _cargarEstadosPorPais(int paisId) async {
    try {
      List<EstadoViewModel> listaEstados =
          await EstadoService.listarEstadosPorPais(paisId);
      setState(() {
        estados = listaEstados;
        estadoController
            .clear(); // Limpiar el estado y la ciudad al cambiar de país
        ciudadController.clear();
        ciudades.clear();
        estadoSeleccionadoId = null;
      });
    } catch (e) {
      print('Error al cargar los estados: $e');
    }
  }

  Future<void> _cargarCiudadesPorEstado(int estadoId) async {
    try {
      List<CiudadViewModel> listaCiudades =
          await CiudadService.listarCiudadesPorEstado(estadoId);
      setState(() {
        ciudades = listaCiudades;
        ciudadController.clear();
      });
    } catch (e) {
      print('Error al cargar las ciudades: $e');
    }
  }

  Future<void> _cargarEstadosCiviles() async {
    try {
      List<EstadoCivilViewModel> listaEstadosCiviles =
          await EstadoCivilService.listarEstadosCiviles();
      setState(() {
        estadosciviles = listaEstadosCiviles;
      });
    } catch (e) {
      print('Error al cargar los estados civiles: $e');
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
                  _campoDeTextoCliente('DNI', dniController, 'Ingrese el DNI',
                      isNumeric: true,
                      showError: _mostrarErrores && dniController.text.isEmpty,
                      errorMessage: 'El campo es requerido.'),
                  SizedBox(height: 10),
                  _campoDeTextoCliente(
                      'Nombre', nombreclientecontroller, 'Ingrese el nombre',
                      showError: _mostrarErrores &&
                          !RegExp(r'^[a-zA-Z\s]+$')
                              .hasMatch(nombreclientecontroller.text),
                      errorMessage: 'El campo es requerido.'),
                  SizedBox(height: 10),
                  _campoDeTextoCliente(
                      'Apellido', apellidoController, 'Ingrese el apellido',
                      showError: _mostrarErrores &&
                          !RegExp(r'^[a-zA-Z\s]+$')
                              .hasMatch(apellidoController.text),
                      errorMessage: 'El campo es requerido.'),
                  SizedBox(height: 10),
                  _campoDeTextoCliente('Correo Electrónico', correoController,
                      'Ingrese el correo',
                      isEmail: true,
                      showError: _mostrarErrores &&
                          !RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                              .hasMatch(correoController.text),
                      errorMessage: 'El campo es requerido.'),
                  SizedBox(height: 10),
                  _campoDeTextoCliente(
                      'Teléfono', telefonoclienteController, 'Ingrese el teléfono',
                      isNumeric: true,
                      showError:
                          _mostrarErrores && telefonoclienteController.text.length < 7,
                      errorMessage: 'El campo es requerido.'),
                  SizedBox(height: 10),
                  _buildDateField(
                      'Fecha de Nacimiento', fechaNacimientoController,
                      showError: _mostrarErrores &&
                          !_esFechaValida(fechaNacimientoController.text),
                      errorMessage: 'El campo es requerido.'),
                  SizedBox(height: 10),
                  _buildRadioGroup('Sexo', ['Femenino', 'Masculino'], (value) {
                    setState(() {
                      sexo = value;
                    });
                  }),
                  SizedBox(height: 10),
                  _buildRadioGroup(
                      'Tipo de Cliente', ['Bien Raiz', 'Proyecto', 'Ambos'],
                      (value) {
                    setState(() {
                      tipoCliente = value;
                    });
                  }),
                  SizedBox(height: 10),
                  _campoDeTextoCliente('Dirección Exacta', direccionController,
                      'Ingrese la dirección',
                      showError:
                          _mostrarErrores && direccionController.text.isEmpty,
                      errorMessage: 'El campo es requerido.'),
                  SizedBox(height: 10),
                  _paisAutocomplete(paisController),
                  SizedBox(height: 10),
                  _estadoAutocomplete(estadoController),
                  SizedBox(height: 10),
                  _ciudadAutocomplete(ciudadController),
                  SizedBox(height: 10),
                  _estadoCivilAutocomplete(estadocivilController),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoDeTextoCliente(
      String label, TextEditingController controller, String hint,
      {bool isNumeric = false,
      bool isEmail = false,
      bool enabled = true,
      bool showError = false,
      String? errorMessage}) {
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
        errorText: showError ? errorMessage : null,
      ),
      style: TextStyle(color: Colors.white),
      keyboardType: isNumeric
          ? TextInputType.number
          : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      inputFormatters: isNumeric
          ? [FilteringTextInputFormatter.digitsOnly]
          : (isEmail
              ? []
              : [FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z\s]+$'))]),
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

  Widget _paisAutocomplete(TextEditingController controller) {
    FocusNode focusNode = FocusNode();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Autocomplete<PaisViewModel>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return paises;
            }
            return paises.where((PaisViewModel option) {
              return option.paisNombre!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            }).toList();
          },
          displayStringForOption: (PaisViewModel option) => option.paisNombre!,
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode fieldFocusNode,
              VoidCallback onFieldSubmitted) {
            focusNode = fieldFocusNode;
            textEditingController.text = controller.text;
            return TextField(
              controller: textEditingController,
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                labelText: 'País',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black,
                labelStyle: TextStyle(color: Colors.white),
                errorText: _mostrarErrores && paisSeleccionadoId == null
                    ? 'El campo es requerido.'
                    : null,
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
                            paisSeleccionadoId = null;
                            estadoController.clear();
                            ciudadController.clear();
                            estados.clear();
                            ciudades.clear();
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
              maxLines: 1,
            );
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<PaisViewModel> onSelected,
              Iterable<PaisViewModel> options) {
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
                      final PaisViewModel option = options.elementAt(index);
                      return GestureDetector(
                        onTap: () {
                          onSelected(option);
                        },
                        child: ListTile(
                          title: Text(option.paisNombre!,
                              style: TextStyle(color: Colors.white)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          onSelected: (PaisViewModel selection) {
            setState(() {
              controller.text = selection.paisNombre!;
              paisSeleccionadoId = selection.paisId;
              _cargarEstadosPorPais(paisSeleccionadoId!);
            });
          },
        );
      },
    );
  }

  Widget _estadoAutocomplete(TextEditingController controller) {
    FocusNode focusNode = FocusNode();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Autocomplete<EstadoViewModel>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (paisSeleccionadoId == null) {
              return [];
            }
            if (textEditingValue.text.isEmpty) {
              return estados;
            }
            return estados.where((EstadoViewModel option) {
              return option.estaNombre!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            }).toList();
          },
          displayStringForOption: (EstadoViewModel option) =>
              option.estaNombre!,
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode fieldFocusNode,
              VoidCallback onFieldSubmitted) {
            focusNode = fieldFocusNode;
            textEditingController.text = controller.text;
            return TextField(
              controller: textEditingController,
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                labelText: 'Estado',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black,
                labelStyle: TextStyle(color: Colors.white),
                errorText: _mostrarErrores &&
                        (paisSeleccionadoId == null ||
                            estadoSeleccionadoId == null)
                    ? 'El campo es requerido.'
                    : null,
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
                            estadoSeleccionadoId = null;
                            ciudades.clear();
                            ciudadController.clear();
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
              maxLines: 1,
            );
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<EstadoViewModel> onSelected,
              Iterable<EstadoViewModel> options) {
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
                      final EstadoViewModel option = options.elementAt(index);
                      return GestureDetector(
                        onTap: () {
                          onSelected(option);
                        },
                        child: ListTile(
                          title: Text(option.estaNombre!,
                              style: TextStyle(color: Colors.white)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          onSelected: (EstadoViewModel selection) {
            setState(() {
              controller.text = selection.estaNombre!;
              estadoSeleccionadoId = selection.estaId;
              _cargarCiudadesPorEstado(estadoSeleccionadoId!);
            });
          },
        );
      },
    );
  }

  Widget _ciudadAutocomplete(TextEditingController controller) {
    FocusNode focusNode = FocusNode();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Autocomplete<CiudadViewModel>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (estadoSeleccionadoId == null) {
              return [];
            }
            if (textEditingValue.text.isEmpty) {
              return ciudades;
            }
            return ciudades.where((CiudadViewModel option) {
              return option.ciudDescripcion!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            }).toList();
          },
          displayStringForOption: (CiudadViewModel option) =>
              option.ciudDescripcion!,
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode fieldFocusNode,
              VoidCallback onFieldSubmitted) {
            focusNode = fieldFocusNode;
            textEditingController.text = controller.text;
            return TextField(
              controller: textEditingController,
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                labelText: 'Ciudad',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black,
                labelStyle: TextStyle(color: Colors.white),
                errorText: _mostrarErrores &&
                        (estadoSeleccionadoId == null ||
                            ciudadSeleccionada == null)
                    ? 'El campo es requerido.'
                    : null,
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
                            ciudadSeleccionada = null;
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
              maxLines: 1,
            );
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<CiudadViewModel> onSelected,
              Iterable<CiudadViewModel> options) {
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
                      final CiudadViewModel option = options.elementAt(index);
                      return GestureDetector(
                        onTap: () {
                          onSelected(option);
                        },
                        child: ListTile(
                          title: Text(option.ciudDescripcion!,
                              style: TextStyle(color: Colors.white)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          onSelected: (CiudadViewModel selection) {
            setState(() {
              controller.text = selection.ciudDescripcion!;
              ciudadSeleccionada = selection;
            });
          },
        );
      },
    );
  }

  Widget _estadoCivilAutocomplete(TextEditingController controller) {
    FocusNode focusNode = FocusNode();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Autocomplete<EstadoCivilViewModel>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return estadosciviles;
            }
            return estadosciviles.where((EstadoCivilViewModel option) {
              return option.civiDescripcion!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            }).toList();
          },
          displayStringForOption: (EstadoCivilViewModel option) =>
              option.civiDescripcion!,
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode fieldFocusNode,
              VoidCallback onFieldSubmitted) {
            focusNode = fieldFocusNode;
            textEditingController.text = controller.text;
            return TextField(
              controller: textEditingController,
              focusNode: fieldFocusNode,
              decoration: InputDecoration(
                labelText: 'Estado Civil',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black,
                labelStyle: TextStyle(color: Colors.white),
                errorText: _mostrarErrores && estadoCivilSeleccionado == null
                    ? 'El campo es requerido.'
                    : null,
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
                            estadoCivilSeleccionado = null;
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
              maxLines: 1,
            );
          },
          optionsViewBuilder: (BuildContext context,
              AutocompleteOnSelected<EstadoCivilViewModel> onSelected,
              Iterable<EstadoCivilViewModel> options) {
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
                      final EstadoCivilViewModel option =
                          options.elementAt(index);
                      return GestureDetector(
                        onTap: () {
                          onSelected(option);
                        },
                        child: ListTile(
                          title: Text(option.civiDescripcion!,
                              style: TextStyle(color: Colors.white)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          onSelected: (EstadoCivilViewModel selection) {
            setState(() {
              controller.text = selection.civiDescripcion!;
              estadoCivilSeleccionado = selection;
            });
          },
        );
      },
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
                  _buildDNIAutocomplete(clienteController,
                  showError: _mostrarErroresventa && clienteController.text.isEmpty,
                      errorMessage: 'El campo es requerido.'),
                  SizedBox(height: 20),
                  _campodeTexto('Nombre Completo', nombreController, '',
                      enabled: false,
                      showError: _mostrarErroresventa && nombreController.text.isEmpty,
                      errorMessage: 'El campo es requerido.'),
                  SizedBox(height: 20),
                  _campodeTexto('Teléfono', telefonoController, '',
                      enabled: false,showError: _mostrarErroresventa && telefonoController.text.isEmpty,
                      errorMessage: 'El campo es requerido.'),
                  SizedBox(height: 20),
                  _campodeTexto('Precio Final', precioController, '0.00',
                      isNumeric: true,showError: _mostrarErroresventa && precioController.text.isEmpty,
                      errorMessage: 'El campo es requerido.'),
                  SizedBox(height: 20),
                  _buildDateField('Fecha de Venta Final', fechaController,showError: _mostrarErroresventa && fechaController.text.isEmpty,
                      errorMessage: 'El campo es requerido.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDNIAutocomplete(TextEditingController controller,{bool showError = false,String? errorMessage}) {
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
                      errorText: showError ? errorMessage : null,
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
          iconSize: 30,
          icon: Icon(Icons.person_add_rounded, color: Color(0xFFFFF0C6)),
          onPressed: () {
            setState(() {
              _mostrarFormularioCliente = true;
            });
            print(_mostrarFormularioCliente);
          },
        ),
      ],
    );
  }

 Widget _campodeTexto(
    String label, 
    TextEditingController controller, 
    String hint,
    {bool isNumeric = false, 
    bool enabled = true,
    bool showError = false,
    String? errorMessage}) {

  bool shouldShowError = showError && enabled;

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
      errorText: shouldShowError ? errorMessage : null,
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

  Widget _buildDateField(String label, TextEditingController controller,
      {bool showError = false, String? errorMessage}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.black,
        labelStyle: TextStyle(color: Colors.white),
        errorText: showError ? errorMessage : null,
      ),
      style: TextStyle(color: Colors.white),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.dark(
                  primary: Color(0xFFFFF0C6),
                  onPrimary: Colors.black,
                  surface: Colors.black,
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          setState(() {
            controller.text = DateFormat('dd/MM/yyyy').format(pickedDate);
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
              if (_mostrarFormularioCliente) {
                setState(() {
                  _mostrarErrores = true;
                });

                if (_isClienteFormValid()) {
                  try {
                    // Crear el modelo del cliente con los datos del formulario
                    final nuevoCliente = ClienteViewModel(
                      clieDNI: dniController.text,
                      clieNombre: nombreclientecontroller.text,
                      clieApellido: apellidoController.text,
                      clieCorreoElectronico: correoController.text,
                      clieTelefono: telefonoclienteController.text,
                      clieFechaNacimiento: DateFormat('dd/MM/yyyy')
                          .parse(fechaNacimientoController.text),
                      clieSexo: sexo == 'Masculino' ? 'M' : 'F',
                      clieTipo: tipoCliente == 'Bien Raiz'
                          ? 'B'
                          : (tipoCliente == 'Proyecto' ? 'P' : 'A'),
                      clieDireccionExacta: direccionController.text,
                      ciudId: ciudadSeleccionada?.ciudId,
                      civiId: estadoCivilSeleccionado?.civiId,
                      clieUsuaCreacion: '3',
                    );
                    print(nuevoCliente);

                    // Insertar el cliente en la base de datos o servicio
                    await ClienteService.insertarCliente(nuevoCliente);

                    // Actualizar la lista de clientes después de insertar el nuevo cliente
                    clientes = await ClienteService.listarClientes();

                    // Buscar el cliente recién insertado en la lista de clientes
                    ClienteViewModel? clienteInsertado = clientes.firstWhere(
                      (cliente) => cliente.clieDNI == dniController.text,
                      orElse: () => ClienteViewModel(),
                    );

                    if (clienteInsertado.clieId != null) {
                      // Actualizar los controladores en la vista de venta de bien raíz
                      setState(() {
                        clienteController.text =
                            "${clienteInsertado.clieDNI} - ${clienteInsertado.clieNombre} ${clienteInsertado.clieApellido}";
                        nombreController.text =
                            "${clienteInsertado.clieNombre} ${clienteInsertado.clieApellido}";
                        telefonoController.text =
                            clienteInsertado.clieTelefono!;
                        _mostrarFormularioCliente =
                            false; // Volver a la vista de venta
                      });

                      // Mostrar mensaje de éxito
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cliente insertado con éxito')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error al insertar el cliente: $e')),
                    );
                  }
                } else {
                }
              } else {
                setState(() {
                  _mostrarErroresventa = true;
                });

                if (_isFormValid()) {
                  try {
                    ClienteViewModel? clienteSeleccionado = clientes.firstWhere(
                      (cliente) => cliente.cliente == clienteController.text,
                      orElse: () => ClienteViewModel(),
                    );

                    if (clienteSeleccionado.clieId != null) {
                      final venta = ProcesoVentaViewModel(
                        btrpId: widget.btrpId,
                        btrpPrecioVentaFinal:
                            double.parse(precioController.text),
                        btrpFechaVendida: DateFormat('dd/MM/yyyy')
                            .parse(fechaController.text),
                        clieId: clienteSeleccionado.clieId.toString(),
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
                        await _notificarVentaCompletada();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cliente no encontrado.')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error al vender la propiedad: $e')),
                    );
                  }
                } else {
                 
                }
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
              if (_mostrarFormularioCliente) {
                setState(() {
                  _mostrarFormularioCliente =
                            false;
                });
              } else{
              Navigator.of(context).pop();
              }

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

  bool _isClienteFormValid() {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    final dniValid =
        dniController.text.isNotEmpty && dniController.text.length >= 8;
    final nombreValid = nombreclientecontroller.text.isNotEmpty &&
        RegExp(r'^[a-zA-Z\s]+$').hasMatch(nombreclientecontroller.text);
    final apellidoValid = apellidoController.text.isNotEmpty &&
        RegExp(r'^[a-zA-Z\s]+$').hasMatch(apellidoController.text);
    final emailValid = emailRegExp.hasMatch(correoController.text);
    final telefonoValid = telefonoclienteController.text.isNotEmpty &&
        telefonoclienteController.text.length >= 8;
    final fechaNacimientoValid = fechaNacimientoController.text.isNotEmpty &&
        _esFechaValida(fechaNacimientoController.text);
    final direccionValid = direccionController.text.isNotEmpty;
    final ciudadValid = ciudadSeleccionada != null;
    final estadoCivilValid = estadoCivilSeleccionado != null;

    return dniValid &&
        nombreValid &&
        apellidoValid &&
        emailValid &&
        telefonoValid &&
        fechaNacimientoValid &&
        direccionValid &&
        ciudadValid &&
        estadoCivilValid;
  }

  bool _esFechaValida(String fecha) {
    try {
      DateFormat('dd/MM/yyyy').parseStrict(fecha);
      return true;
    } catch (e) {
      return false;
    }
  }


// Future<void> _notificarVentaCompletada() async {
//   try {
//     String title = "Bien Raíz Vendido";
//     String body = "El bien raíz ${nombreController.text} ha sido vendido.";
//     await NotificationServices.EnviarNotificacion(title, body, widget.btrpId as String);
//     // ScaffoldMessenger.of(context).showSnackBar(
//     //   SnackBar(content: Text('Notificación de venta completada enviada.')),
//     // );
//   } catch (e) {
//     print('Error al enviar la notificación de venta completada: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error al enviar la notificación de venta completada.')),
//     );
//   }
// }





// Future<void> _notificarVentaCompletada() async {
//   try {
//     var prefs = PreferenciasUsuario();
//     String title = "Bien Raíz Vendido";
//     String body = "El bien raíz ${nombreController.text} ha sido vendido.";
    
//     // Intentar convertir el valor de prefs.userId a un int
//     int? usuarioCreacionId = int.tryParse(prefs.userId);

//     // Verificar si la conversión fue exitosa
//     if (usuarioCreacionId != null) {
//       // Crear instancia de NotificationServices
//       final notificationService = NotificationServices();
//         await NotificationServices.EnviarNotificacionAAdministradores(title, body);

//       // Llamar al método de instancia para enviar la notificación y registrar en la base de datos
//       await notificationService.enviarNotificacionYRegistrarEnBD(title, body, usuarioCreacionId);

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Notificación de venta completada enviada.')),
//       );
//     } else {
//       // Si la conversión falló, manejar el error
//       print('Error: userId no es un número válido.');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ID de usuario no válido.')),
//       );
//     }
//   } catch (e) {
//     print('Error al enviar la notificación de venta completada: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error al enviar la notificación de venta completada.')),
//     );
//   }
// }







Future<void> _notificarVentaCompletada() async {
  try {
    var prefs = PreferenciasUsuario();
    String title = "Bien Raíz Vendido";
    String body = "El bien raíz ${nombreController.text} ha sido vendido.";
    
    // Intentar convertir el valor de prefs.userId a un int
    int? usuarioCreacionId = int.tryParse(prefs.userId);

    // Verificar si la conversión fue exitosa
    if (usuarioCreacionId != null) {
      // Crear instancia de NotificationServices
      final notificationService = NotificationServices();
        await NotificationServices.EnviarNotificacionAAdministradores(title, body);

      // Llamar al método de instancia para enviar la notificación y registrar en la base de datos
      await notificationService.enviarNotificacionYRegistrarEnBD(title, body, usuarioCreacionId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notificación de venta completada enviada.')),
      );
    } else {
      // Si la conversión falló, manejar el error
      print('Error: userId no es un número válido.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ID de usuario no válido.')),
      );
    }
  } catch (e) {
    print('Error al enviar la notificación de venta completada: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al enviar la notificación de venta completada.')),
    );
  }
}
}