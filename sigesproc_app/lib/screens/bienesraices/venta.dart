import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigesproc_app/models/acceso/usuarioviewmodel.dart';
import 'package:sigesproc_app/models/bienesraices/procesoventaviewmodel.dart';
import 'package:sigesproc_app/models/generales/ciudadviewmodel.dart';
import 'package:sigesproc_app/models/generales/clienteviewmodel.dart';
import 'package:sigesproc_app/models/generales/estadocivilviewmodel.dart';
import 'package:sigesproc_app/models/generales/estadoviewmodel.dart';
import 'package:sigesproc_app/models/generales/paisviewmodel.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/acceso/notificacion.dart';
import 'package:sigesproc_app/screens/acceso/perfil.dart';
import 'package:sigesproc_app/screens/bienesraices/procesoventa.dart';
import 'package:sigesproc_app/screens/menu.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';
import 'package:sigesproc_app/services/acceso/usuarioservice.dart';
import 'package:sigesproc_app/services/bienesraices/procesoventaservice.dart';
import 'package:sigesproc_app/services/bloc/notifications_bloc.dart';
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
  TextEditingController precioInicialController = TextEditingController();
  TextEditingController fechaInicialController = TextEditingController();
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

  Future<List<ProcesoVentaViewModel>>? _procesosventaFuture;
  List<ProcesoVentaViewModel>? _selectedVenta;

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

  String? dniErrorMessage;
  String? correoErrorMessage;
  String? precioErrorMessage;
  String? fechaErrorMessage;

  bool _mostrarFormularioCliente = false;
  String sexo = 'Femenino';
  String tipoCliente = 'Bien Raiz';
  bool _mostrarErrores = false;
  bool _mostrarErroresventa = false;

  bool _cargando = false;
  int _unreadCount = 0;
  int? userId;
  int _selectedIndex = 4;

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
    _loadUserId();
    _cargarDatosBienRaiz();
    _loadUserProfileData();
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadUserId() async {
    var prefs = PreferenciasUsuario();
    userId = int.tryParse(prefs.userId) ?? 0;

    _insertarToken();

    context
        .read<NotificationsBloc>()
        .add(InitializeNotificationsEvent(userId: userId!));

    _loadNotifications();
  }

  Future<void> _insertarToken() async {
    var prefs = PreferenciasUsuario();
    String? token = prefs.token;

    if (token != null && token.isNotEmpty) {
      await NotificationServices.insertarToken(userId!, token);
    } else {
      print('No se encontró token en las preferencias.');
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications =
          await NotificationServices.BuscarNotificacion(userId!);
      setState(() {
        _unreadCount = notifications.where((n) => n.leida == "No Leida").length;
      });
    } catch (e) {
      print('Error al cargar notificaciones: $e');
    }
  }

  Future<void> _loadUserProfileData() async {
    var prefs = PreferenciasUsuario();
    int usua_Id = int.tryParse(prefs.userId) ?? 0;

    try {
      UsuarioViewModel usuario = await UsuarioService.Buscar(usua_Id);

    } catch (e) {
      print("Error al cargar los datos del usuario: $e");
    }
  }

  void _cargarDatosBienRaiz() {
    setState(() {
      _cargando = true;
      _procesosventaFuture = ProcesoVentaService.Buscar(
        widget.btrpId,
        widget.btrpTerrenoOBienRaizId,
        widget.btrpBienoterrenoId,
      );

      _procesosventaFuture!.then((value) {
        setState(() {
          _selectedVenta = value;

          if (_selectedVenta != null && _selectedVenta!.isNotEmpty) {
            precioInicialController.text =
                _selectedVenta![0].btrpPrecioVentaInicio?.toString() ?? '';
            fechaInicialController.text =
                _selectedVenta![0].btrpFechaPuestaVenta != null
                    ? DateFormat('dd/MM/yyyy')
                        .format(_selectedVenta![0].btrpFechaPuestaVenta!)
                    : '';
          }
          _cargando = false;
        });
      }).catchError((error) {
        setState(() {
          _cargando = false;
        });
        print('Error al cargar los detalles del bien raíz: $error');
      });
    });
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
      resizeToAvoidBottomInset: false,
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
        bottom: _mostrarFormularioCliente
            ? PreferredSize(
                preferredSize: Size.fromHeight(70.0),
                child: Column(
                  children: [
                    Text(
                      'Cliente',
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
                    Row(
                      children: [
                        SizedBox(width: 5.0), // Espacio a la izquierda
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              Navigator.pop(context);
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0), // Margen superior
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
              )
            : PreferredSize(
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
            icon: Stack(
              children: [
                Icon(Icons.notifications),
                if (_unreadCount > 0)
                  Positioned(
                    right: 0,
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
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificacionesScreen(),
                ),
              );
              _loadNotifications();
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
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
      ),
      body: _cargando
          ? Center(child: CircularProgressIndicator(color: Color(0xFFFFF0C6)))
          : Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16.0),
              child:
                  _mostrarFormularioCliente ? _clienteVista() : _ventaVista(),
            ),
      bottomNavigationBar: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: _cargando ? SizedBox.shrink() : _buildSaveCancelButtons(),
      ),
      drawer: MenuLateral(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
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
                  _campoDeTextoCliente(
                    'DNI',
                    dniController,
                    'Ingrese el DNI',
                    isNumeric: true,
                    showError: _mostrarErrores && dniErrorMessage != null,
                    errorMessage: dniErrorMessage ?? 'El campo es requerido.',
                    inputFormatterLength: 13, 
                  ),
                  SizedBox(height: 10),
                  _campoDeTextoCliente(
                      'Nombre', nombreclientecontroller, 'Ingrese el nombre',
                      showError: _mostrarErrores &&
                          !RegExp(r'^[a-zA-Z\s]+$').hasMatch(
                              nombreclientecontroller.text
                                  .trim()), 
                      errorMessage: 'El campo es requerido.'),
                  SizedBox(height: 10),
                  _campoDeTextoCliente(
                      'Apellido', apellidoController, 'Ingrese el apellido',
                      showError: _mostrarErrores &&
                          !RegExp(r'^[a-zA-Z\s]+$').hasMatch(
                              apellidoController.text.trim()),
                      errorMessage: 'El campo es requerido.'),
                  SizedBox(height: 10),
                  _campoDeTextoCliente(
                    'Correo Electrónico',
                    correoController,
                    'Ingrese el correo',
                    isEmail: true,
                    showError: _mostrarErrores && correoErrorMessage != null,
                    errorMessage:
                        correoErrorMessage ?? 'Ingrese un correo válido.',
                  ),
                  SizedBox(height: 10),
                  _campoDeTextoCliente('Teléfono', telefonoclienteController,
                      'Ingrese el teléfono',
                      isNumeric: true,
                      showError: _mostrarErrores &&
                          telefonoclienteController.text.length <
                              8, // Mínimo 8 dígitos
                      errorMessage: 'El campo es requerido.',
                      inputFormatterLength:
                          15 // Limitar el teléfono a 15 dígitos
                      ),
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
                  _campoDeTextoCliente(
                    'Dirección Exacta',
                    direccionController,
                    'Ingrese la dirección',
                    showError: _mostrarErrores &&
                        (direccionController.text.isEmpty ||
                            !RegExp(r'^[a-zA-Z0-9\s,.#-]+$')
                                .hasMatch(direccionController.text)),
                    errorMessage: direccionController.text.isEmpty
                        ? 'El campo es requerido.'
                        : 'Ingrese una dirección válida.',
                  ),
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
      String? errorMessage,
      int? inputFormatterLength}) {
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
        errorText:
            showError ? errorMessage : null,
      ),
      style: TextStyle(color: Colors.white),
      keyboardType: isNumeric
          ? TextInputType.number
          : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      inputFormatters: isNumeric
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(inputFormatterLength),
            ]
          : (isEmail
              ? [
                  LengthLimitingTextInputFormatter(inputFormatterLength),
                ]
              : [
                  FilteringTextInputFormatter.allow(RegExp(
                      r'^[a-zA-Z0-9\s,.#-]+$')), // Se permiten letras, números, espacios y caracteres especiales
                  LengthLimitingTextInputFormatter(inputFormatterLength),
                ]),
    );
  }

  Widget _buildRadioGroup(
      String label, List<String> options, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white)),
        Wrap(
          spacing: 10.0, // Espaciado horizontal entre los RadioButtons
          runSpacing:
              10.0, // Espaciado vertical entre las líneas de RadioButtons
          children: options.map((option) {
            return Row(
              mainAxisSize: MainAxisSize
                  .min, // Mantener el tamaño mínimo de los elementos
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
                      showError: _mostrarErroresventa &&
                          clienteController.text.isEmpty,
                      errorMessage: 'El campo es requerido.'),
                  SizedBox(height: 20),
                  _campodeTexto('Nombre Completo', nombreController, '',
                      enabled: false,
                      showError:
                          _mostrarErroresventa && nombreController.text.isEmpty,
                      errorMessage: 'El campo es requerido.'),
                  SizedBox(height: 20),
                  _campodeTexto('Teléfono', telefonoController, '',
                      enabled: false,
                      showError: _mostrarErroresventa &&
                          telefonoController.text.isEmpty,
                      errorMessage: 'El campo es requerido.'),
                  SizedBox(height: 20),
                  _campodeTexto('Precio Inicial', precioInicialController, '',
                      enabled: false),
                  SizedBox(height: 20),
                  _buildDateField(
                      'Fecha de Venta Inicial', fechaInicialController,
                      enabled: false),
                  SizedBox(height: 20),
                  _campodeTexto('Precio Final', precioController, '0.00',
                      isNumeric: true,
                      showError:
                          _mostrarErroresventa && precioErrorMessage != null,
                      errorMessage:
                          precioErrorMessage ?? 'El campo es requerido.'),
                  SizedBox(height: 20),
                  _buildDateField('Fecha de Venta Final', fechaController,
                      showError:
                          _mostrarErroresventa && fechaErrorMessage != null,
                      errorMessage:
                          fechaErrorMessage ?? 'El campo es requerido.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDNIAutocomplete(TextEditingController controller,
      {bool showError = false, String? errorMessage}) {
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
              dniController.text = '';
              nombreclientecontroller.text = '';
              apellidoController.text = '';
              correoController.text = '';
              telefonoclienteController.text = '';
              fechaNacimientoController.text = '';
              sexo = 'Femenino';
              tipoCliente = 'Bien Raiz';
              direccionController.text = '';
              ciudadSeleccionada = null;
              estadoCivilSeleccionado = null;
              _mostrarFormularioCliente = true;
            });
          },
        ),
      ],
    );
  }

  Widget _campodeTexto(
      String label, TextEditingController controller, String hint,
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
        errorMaxLines: 3, // Permitir varias líneas en el mensaje de error
        errorStyle: TextStyle(
          fontSize: 12,
          height: 1.0, 
        ),
        errorText: shouldShowError ? errorMessage : null,
      ),
      style: TextStyle(color: Colors.white),
      keyboardType: isNumeric
          ? TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: isNumeric
          ? [
              FilteringTextInputFormatter.allow(
                  RegExp(r'^\d{0,15}(\.\d{0,2})?$')),
            ]
          : null,
    );
  }

  Widget _buildDateField(String label, TextEditingController controller,
      {bool showError = false, bool enabled = true, String? errorMessage}) {
    bool shouldShowError = showError && enabled;
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.black,
        labelStyle: TextStyle(color: Colors.white),
        errorMaxLines: 3, // Permitir varias líneas en el mensaje de error
        errorStyle: TextStyle(
          fontSize: 12,
          height: 1.0, // Controla el espaciado entre líneas
        ),
        errorText: shouldShowError ? errorMessage : null,
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
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () async {
              if (_cargando) return;
              setState(() {
                _cargando = true;
              });
              try {
                if (_mostrarFormularioCliente) {
                  setState(() {
                    _mostrarErrores = true;
                  });

                  if (_isClienteFormValid()) {
                    try {
                      final pref = await SharedPreferences.getInstance();
                      final nuevoCliente = ClienteViewModel(
                        clieDNI: dniController.text.trim(),
                        clieNombre: nombreclientecontroller.text
                            .trim()
                            .replaceAll(RegExp(r'\s+'),
                                ' '), // Eliminar múltiples espacios
                        clieApellido: apellidoController.text.trim().replaceAll(
                            RegExp(r'\s+'), ' '), // Eliminar múltiples espacios
                        clieCorreoElectronico: correoController.text.trim(),
                        clieTelefono: telefonoclienteController.text,
                        clieFechaNacimiento: DateFormat('dd/MM/yyyy')
                            .parse(fechaNacimientoController.text),
                        clieSexo: sexo == 'Masculino' ? 'M' : 'F',
                        clieTipo: tipoCliente == 'Bien Raiz'
                            ? 'B'
                            : (tipoCliente == 'Proyecto' ? 'P' : 'A'),
                        clieDireccionExacta: direccionController.text
                            .trim()
                            .replaceAll(RegExp(r'\s+'), ' '),
                        ciudId: ciudadSeleccionada?.ciudId,
                        civiId: estadoCivilSeleccionado?.civiId,
                        clieUsuaCreacion: pref.getString('usuaId'),
                        usuaCreacion:
                            int.tryParse(pref.getString('usuaId') ?? ''),
                      );

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
                              "${clienteInsertado.clieNombre} ${clienteInsertado.clieApellido} - ${clienteInsertado.clieDNI}";
                          nombreController.text =
                              "${clienteInsertado.clieNombre} ${clienteInsertado.clieApellido}";
                          telefonoController.text =
                              clienteInsertado.clieTelefono!;
                          _mostrarFormularioCliente =
                              false; // Volver a la vista de venta
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Cliente insertado con éxito')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error al insertar el cliente: $e')),
                      );
                    }
                  } else {}
                } else {
                  setState(() {
                    _mostrarErroresventa = true;
                  });

                  if (_isFormValid()) {
                    try {
                      await ClienteService.listarClientes();

                      String dni = clienteController.text.split(' - ')[
                          1]; // Eliminar el nombre completo y obtener el DNI

                      // Buscar el cliente por su DNI
                      ClienteViewModel? clienteSeleccionado =
                          clientes.firstWhere(
                        (cliente) => cliente.clieDNI == dni,
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
                          SnackBar(
                              content: Text('Propiedad vendida con éxito')),
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
                    print('Formulario NO es válido');
                  }
                }
              } catch (e) {
              } finally {
                setState(() {
                  _cargando = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFF0C6),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: Icon(Icons.save, color: Colors.black),
            label: Text(
              'Guardar',
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
          ),
          SizedBox(width: 18),
          ElevatedButton.icon(
            onPressed: () {
              if (_mostrarFormularioCliente) {
                setState(() {
                  _mostrarFormularioCliente = false;
                });
              } else {
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF222222),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: Icon(Icons.close, color: Colors.white), 
            label: Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  bool _isFormValid() {
    final double? precioInicial = double.tryParse(precioInicialController.text);

    final double? precioFinal = double.tryParse(precioController.text);

    final DateTime? fechaInicial = _parseDate(fechaInicialController.text);

    final DateTime? fechaFinal = _parseDate(fechaController.text);

    setState(() {
      _mostrarErroresventa = true;

      // Validación de precio
      if (precioFinal == null || precioFinal < (precioInicial ?? 0)) {
        precioErrorMessage =
            'El precio final no puede ser menor al precio inicial.';
        print('Error en precio: $precioErrorMessage');
      } else {
        precioErrorMessage = null;
      }

      // Validación de fecha
      if (fechaFinal == null ||
          fechaFinal.isBefore(fechaInicial ?? DateTime.now())) {
        fechaErrorMessage =
            'La fecha de venta no puede ser anterior a la fecha inicial.';
        print('Error en fecha: $fechaErrorMessage');
      } else {
        fechaErrorMessage = null;
      }
    });

    // Validaciones para verificar si el formulario es válido
    bool isValid = clienteController.text.isNotEmpty &&
        nombreController.text.isNotEmpty &&
        telefonoController.text.isNotEmpty &&
        precioController.text.isNotEmpty &&
        fechaController.text.isNotEmpty &&
        RegExp(r'^\d{1,15}(\.\d{1,2})?$').hasMatch(precioController.text) &&
        precioErrorMessage == null && 
        fechaErrorMessage == null; 

    print('Formulario válido: $isValid');

    return isValid;
  }

  DateTime? _parseDate(String date) {
    try {
      return DateFormat('dd/MM/yyyy').parse(date);
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  bool _isClienteFormValid() {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    // Validaciones de campos con trim aplicado
    final dniValid = dniController.text.trim().isNotEmpty &&
        dniController.text.trim().length == 13; // DNI exacto 13 caracteres
    final nombreValid = nombreclientecontroller.text
            .trim()
            .replaceAll(RegExp(r'\s+'), ' ')
            .isNotEmpty &&
        nombreclientecontroller.text
                .trim()
                .replaceAll(RegExp(r'\s+'), ' ')
                .length <=
            50 &&
        RegExp(r'^[a-zA-Z\s]+$').hasMatch(nombreclientecontroller.text
            .trim()
            .replaceAll(RegExp(r'\s+'), ' '));
    final apellidoValid = apellidoController.text
            .trim()
            .replaceAll(RegExp(r'\s+'), ' ')
            .isNotEmpty &&
        apellidoController.text.trim().replaceAll(RegExp(r'\s+'), ' ').length <=
            50 &&
        RegExp(r'^[a-zA-Z\s]+$').hasMatch(
            apellidoController.text.trim().replaceAll(RegExp(r'\s+'), ' '));
    final correoVacio = correoController.text.trim().isEmpty;
    final emailValid = correoController.text.trim().length <= 70 &&
        emailRegExp.hasMatch(correoController.text.trim());
    final telefonoValid = telefonoclienteController.text.trim().isNotEmpty &&
        telefonoclienteController.text.trim().length >=
            8 && // Teléfono mínimo 8 dígitos
        RegExp(r'^\d+$').hasMatch(telefonoclienteController.text.trim());
    final fechaNacimientoValid =
        fechaNacimientoController.text.trim().isNotEmpty &&
            _esFechaValida(fechaNacimientoController.text.trim());
    final direccionValid = direccionController.text
            .trim()
            .replaceAll(RegExp(r'\s+'), ' ')
            .isNotEmpty &&
        direccionController.text
                .trim()
                .replaceAll(RegExp(r'\s+'), ' ')
                .length <=
            90 &&
        RegExp(r'^[a-zA-Z0-9\s,.#-]+$').hasMatch(
            direccionController.text.trim().replaceAll(RegExp(r'\s+'), ' '));
    final ciudadValid = ciudadSeleccionada != null;
    final estadoCivilValid = estadoCivilSeleccionado != null;

    final dniDuplicado =
        clientes.any((cliente) => cliente.clieDNI == dniController.text.trim());

    final correoDuplicado = clientes.any((cliente) =>
        cliente.clieCorreoElectronico == correoController.text.trim());

    setState(() {
      // Validar DNI y correo duplicado o errores de formato
      if (dniController.text.trim().isEmpty) {
        dniErrorMessage = 'El campo es requerido.';
        _mostrarErrores = true;
      } else if (dniDuplicado) {
        dniController.clear();
        dniErrorMessage = 'Ya existe un cliente con esa identidad.';
        _mostrarErrores = true;
      } else if (dniController.text.trim().length != 13) {
        dniErrorMessage = 'El DNI debe ser de 13 dígitos.';
        _mostrarErrores = true;
      } else {
        dniErrorMessage = null;
      }

      if (correoVacio) {
        correoErrorMessage = 'El campo es requerido.';
        _mostrarErrores = true;
      } else if (!emailValid) {
        correoErrorMessage = 'Ingrese un correo válido.';
        _mostrarErrores = true;
      } else if (correoDuplicado) {
        correoController.clear();
        correoErrorMessage = 'Ya existe un cliente con ese correo.';
        _mostrarErrores = true;
      } else {
        correoErrorMessage = null;
      }
    });

    // Validaciones finales
    if (dniDuplicado ||
        correoDuplicado ||
        correoVacio ||
        !emailValid ||
        !dniValid ||
        !nombreValid ||
        !apellidoValid ||
        !telefonoValid ||
        !direccionValid) {
      return false;
    }

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
        await NotificationServices.EnviarNotificacionAAdministradores(
            title, body);

        // Llamar al método de instancia para enviar la notificación y registrar en la base de datos
        await notificationService.enviarNotificacionYRegistrarEnBD(
            title, body, usuarioCreacionId);

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
        SnackBar(
            content:
                Text('Error al enviar la notificación de venta completada.')),
      );
    }
  }
}
