import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigesproc_app/models/acceso/usuarioviewmodel.dart';
import 'package:sigesproc_app/models/fletes/fletedetalleviewmodel.dart';
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/models/insumos/equipoporproveedorviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/actividadesporetapaviewmodel.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/acceso/notificacion.dart';
import 'package:sigesproc_app/screens/acceso/perfil.dart';
import 'package:sigesproc_app/screens/fletes/flete.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';
import 'package:sigesproc_app/services/acceso/usuarioservice.dart';
import 'package:sigesproc_app/services/bloc/notifications_bloc.dart';
import 'package:sigesproc_app/services/fletes/fletedetalleservice.dart';
import 'package:sigesproc_app/services/fletes/fleteencabezadoservice.dart';
import 'package:sigesproc_app/services/proyectos/actividadesporetapaservice.dart';
import '../menu.dart';
import 'package:sigesproc_app/models/generales/empleadoviewmodel.dart';
import 'package:sigesproc_app/models/insumos/bodegaviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import 'package:sigesproc_app/models/insumos/insumoporproveedorviewmodel.dart';
import 'package:sigesproc_app/services/generales/empleadoservice.dart';
import 'package:sigesproc_app/services/insumos/bodegaservice.dart';
import 'package:sigesproc_app/services/proyectos/proyectoservice.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class NuevoFlete extends StatefulWidget {
  @override
  _NuevoFleteState createState() => _NuevoFleteState();
}

class _NuevoFleteState extends State<NuevoFlete> with TickerProviderStateMixin {
  int _selectedIndex = 2;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime? establishedDate;
  TimeOfDay? establishedTime;
  bool esProyecto = false;
  bool esProyectosalida = false;
  bool _mostrarInsumos = false;
  bool _showEquiposDeSeguridad = false;
  bool _desabilitartextbox = false;
  List<EmpleadoViewModel> empleados = [];
  List<BodegaViewModel> bodegas = [];
  List<ProyectoViewModel> proyectos = [];
  List<ActividadPorEtapaViewModel> actividades = [];
  List<InsumoPorProveedorViewModel> insumos = [];
  List<InsumoPorProveedorViewModel> selectedInsumos = [];
  List<int> selectedCantidades = [];
  List<int> selectedCantidadesequipos = [];
  List<EquipoPorProveedorViewModel> equiposdeSeguridad = [];
  List<EquipoPorProveedorViewModel> selectedEquipos = [];
  List<TextEditingController> equipoQuantityControllers = [];
  String? selectedBodegaLlegada;
  // Variables para el estado de error en los campos
  bool _fechaSalidaError = false;
  String _fechaSalidaErrorMessage = '';
  bool _fechaHoraEstablecidaError = false;
  String _fechaHoraEstablecidaErrorMessage = '';
  final FocusNode _fechaHoraEstablecidaFocusNode = FocusNode();
  bool _isEmpleadoError = false;
  String _empleadoErrorMessage = '';
  bool _isSupervisorSalidaError = false;
  String _supervisorSalidaErrorMessage = '';
  bool _isSupervisorLlegadaError = false;
  String _supervisorLlegadaErrorMessage = '';
  bool _ubicacionSalidaError = false;
  String _ubicacionSalidaErrorMessage = '';
  bool _ubicacionLlegadaError = false;
  String _ubicacionLlegadaErrorMessage = '';
  bool _proyectoError = false;
  String _proyectoErrorMessage = '';
  bool _actividadError = false;
  String _actividadErrorMessage = '';
  bool _noActividadesError = false;
  String _actividadErrorMessagesalida = '';
  bool _noActividadesErrorsalida = false;
  TextEditingController llegadaController = TextEditingController();
  TextEditingController actividadController = TextEditingController();
  List<TextEditingController> quantityControllers = [];
  TextEditingController encargadoController = TextEditingController();
  TextEditingController supervisorSalidaController = TextEditingController();
  TextEditingController supervisorLlegadaController = TextEditingController();
  TextEditingController salidaController = TextEditingController();
  List<ActividadPorEtapaViewModel> actividadesSalida = [];
  List<ActividadPorEtapaViewModel> actividadesLlegada = [];
  TextEditingController actividadControllerSalida = TextEditingController();
  TextEditingController actividadControllerLlegada = TextEditingController();
  TabController? _tabController;
  late StreamSubscription<bool> keyboardSubscription;
  bool _isKeyboardVisible = false;
  bool _cargando = false;
  int _unreadCount = 0;
  int? userId;
  final ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: Color(0xFFFFF0C6),
      onPrimary: Colors.black,
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    dialogBackgroundColor: Colors.black,
  );

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
    _loadUserId(); // Cargamos el userId desde las preferencias.
    _loadUserProfileData();
    _tabController = TabController(length: 2, vsync: this); // 2 tabs
    _cargarEmpleados();
    _cargarBodegas();
    _cargarProyectos();
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
    if (flete.emtrId != null) {
      EmpleadoViewModel? encargado =
          empleados.firstWhere((emp) => emp.emplId == flete.emtrId);
      if (encargado != null) {
        encargadoController.text = encargado.empleado!;
      }
    }
    if (flete.emssId != null) {
      EmpleadoViewModel? supervisorSalida =
          empleados.firstWhere((emp) => emp.emplId == flete.emssId);
      if (supervisorSalida != null) {
        supervisorSalidaController.text = supervisorSalida.empleado!;
      }
    }
    if (flete.emslId != null) {
      EmpleadoViewModel? supervisorLlegada =
          empleados.firstWhere((emp) => emp.emplId == flete.emslId);
      if (supervisorLlegada != null) {
        supervisorLlegadaController.text = supervisorLlegada.empleado!;
      }
    }
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    _tabController?.dispose();
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

  Future<void> _enviarNotificacionFletenuevo() async {
    var prefs = PreferenciasUsuario();

    int? usuarioCreacionId = int.tryParse(prefs.userId);

    String title = 'Nuevo Flete';
    String supervisor = supervisorSalidaController.text.split(' - ')[0];
    String salida = salidaController.text;

    String body = 'Nuevo flete enviado por $supervisor desde $salida';

    // Enviar la notificación a los administradores
    if (usuarioCreacionId != null) {
      // Crear instancia de NotificationServices
      final notificationService = NotificationServices();
      await NotificationServices.EnviarNotificacionAAdministradores(
          title, body);

      // Llamar al método de instancia para enviar la notificación y registrar en la base de datos
      await notificationService.enviarNotificacionYRegistrarEnBD(
          title, body, usuarioCreacionId);
    }
  }

  Future<void> _insertarToken() async {
    var prefs = PreferenciasUsuario();
    String? token = prefs.token;

    if (token != null && token.isNotEmpty) {
      await NotificationServices.insertarToken(userId!, token);
    } else {
      // print('No se encontró token en las preferencias.');
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
      // print('Error al cargar notificaciones: $e');
    }
  }

  // Nueva función para cargar datos del usuario
  Future<void> _loadUserProfileData() async {
    var prefs = PreferenciasUsuario();
    int usua_Id = int.tryParse(prefs.userId) ?? 0;

    try {
      UsuarioViewModel usuario = await UsuarioService.Buscar(usua_Id);

    } catch (e) {
      // print("Error al cargar los datos del usuario: $e");
    }
  }

  Future<void> _cargarEmpleados() async {
    try {
      List<EmpleadoViewModel> empleadosList =
          await EmpleadoService.listarEmpleados();
      setState(() {
        empleados = empleadosList;
      });
    } catch (e) {
      // print('Error al cargar los empleados: $e');
    }
  }

  Future<void> _cargarBodegas() async {
    try {
      List<BodegaViewModel> bodegasList = await BodegaService.listarBodegas();
      setState(() {
        bodegas = bodegasList;
      });
    } catch (e) {
      // print('Error al cargar las bodegas: $e');
    }
  }

  Future<void> _cargarProyectos() async {
    try {
      List<ProyectoViewModel> proyectosList =
          await ProyectoService.listarProyectos();
      setState(() {
        proyectos = proyectosList;
      });
    } catch (e) {
      // print('Error al cargar los proyectos: $e');
    }
  }

  Future<void> _cargarActividadesPorProyecto(int proyId, String tipo) async {
    try {
      List<ActividadPorEtapaViewModel> actividadesCargadas =
          await ActividadPorEtapaService.obtenerActividadesPorProyecto(proyId);

      setState(() {
        if (tipo == 'Salida') {
          actividadesSalida = actividadesCargadas;
          _noActividadesErrorsalida = actividadesCargadas.isEmpty;
        } else {
          actividadesLlegada = actividadesCargadas;
          _noActividadesError = actividadesCargadas.isEmpty;
        }
      });
    } catch (e) {
      // print('Error al cargar las actividades: $e');
    }
  }

  Future<void> _FechaSeleccionada({required bool isSalida}) async {
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
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: darkTheme,
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        setState(() {
          if (isSalida) {
            selectedDate = pickedDate;
            selectedTime = pickedTime;
            flete.flenFechaHoraSalida = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute);
          } else {
            establishedDate = pickedDate;
            establishedTime = pickedTime;
            flete.flenFechaHoraEstablecidaDeLlegada = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute);
          }
        });
      }
    }
  }

  Future<void> _cargarInsumosPorBodega(int bodeId) async {
    try {
      List<InsumoPorProveedorViewModel> insumosList =
          await FleteDetalleService.listarInsumosPorProveedorPorBodega(bodeId);
      List<InsumoPorProveedorViewModel> insumosfiltrados = [];
      setState(() {
        insumosfiltrados =
            insumosList.where((insuu) => (insuu.bopiStock ?? 0) > 0).toList();
        insumos = insumosfiltrados;
        // Inicializar controladores para cada insumo cargado
        quantityControllers = List.generate(
            insumos.length, (index) => TextEditingController(text: '1'));
        selectedCantidades = List.generate(insumos.length, (index) => 1);
      });
    } catch (e) {
      // print('Error al cargar los insumos: $e');
    }
  }

  Future<void> _cargarEquiposDeSeguridadPorBodega(int bodeId) async {
    try {
      List<EquipoPorProveedorViewModel> equiposList =
          await FleteDetalleService.listarEquiposdeSeguridadPorBodega(bodeId);
      List<EquipoPorProveedorViewModel> equiposfiltrados = [];
      setState(() {
        equiposfiltrados =
            equiposList.where((equii) => (equii.bopiStock ?? 0) > 0).toList();
        equiposdeSeguridad = equiposfiltrados;
        equipoQuantityControllers = List.generate(equiposdeSeguridad.length,
            (index) => TextEditingController(text: '1'));
        selectedCantidadesequipos =
            List.generate(equiposdeSeguridad.length, (index) => 1);
      });
    } catch (e) {
      // print('Error al cargar los equipos de seguridad: $e');
    }
  }

  Future<void> _cargarInsumosPorActividadEtapa(int acetId) async {
    try {
      List<InsumoPorProveedorViewModel> insumosList =
          await FleteDetalleService.listarInsumosPorProveedorPorActividadEtapa(
              acetId);
      List<InsumoPorProveedorViewModel> insumosfiltrados = [];
      setState(() {
        insumosfiltrados =
            insumosList.where((insuu) => (insuu.bopiStock ?? 0) > 0).toList();
        insumos = insumosfiltrados;
        // Inicializar controladores para cada insumo cargado
        quantityControllers = List.generate(
            insumos.length, (index) => TextEditingController(text: '1'));
        selectedCantidades = List.generate(insumos.length, (index) => 1);
      });
    } catch (e) {
      // print('Error al cargar los insumos: $e');
    }
  }

  Future<void> _cargarEquiposDeSeguridadPorActividadEtapa(int acetId) async {
    try {
      List<EquipoPorProveedorViewModel> equiposList =
          await FleteDetalleService.listarEquiposdeSeguridadPorActividadEtapa(
              acetId);
      List<EquipoPorProveedorViewModel> equiposfiltrados = [];

      setState(() {
        equiposfiltrados =
            equiposList.where((equii) => (equii.bopiStock ?? 0) > 0).toList();
        equiposdeSeguridad = equiposfiltrados;
        equipoQuantityControllers = List.generate(equiposdeSeguridad.length,
            (index) => TextEditingController(text: '1'));
        selectedCantidadesequipos =
            List.generate(equiposdeSeguridad.length, (index) => 1);
      });
    } catch (e) {
      // print('Error al cargar los equipos de seguridad: $e');
    }
  }

  Widget _buildBodegaAutocomplete(
      String label, TextEditingController controller) {
    bool isError = false;
    String errorMessage = '';

    if (label == 'Salida') {
      isError = _ubicacionSalidaError;
      errorMessage = _ubicacionSalidaErrorMessage;
    } else if (label == 'Llegada') {
      isError = _ubicacionLlegadaError;
      errorMessage = _ubicacionLlegadaErrorMessage;
    }

    FocusNode focusNode = FocusNode();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Autocomplete<BodegaViewModel>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            List<BodegaViewModel> filteredBodegas;

            if (textEditingValue.text.isEmpty) {
              filteredBodegas = List.from(bodegas);
            } else {
              filteredBodegas = bodegas.where((BodegaViewModel option) {
                return option.bodeDescripcion!
                    .toLowerCase()
                    .contains(textEditingValue.text.toLowerCase());
              }).toList();
            }

            // Ordenar la lista alfabéticamente por bodeDescripcion
            filteredBodegas.sort((a, b) => a.bodeDescripcion!
                .toLowerCase()
                .compareTo(b.bodeDescripcion!.toLowerCase()));

            return filteredBodegas;
          },
          displayStringForOption: (BodegaViewModel option) =>
              option.bodeDescripcion!,
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
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1.0),
                ),
                filled: true,
                fillColor: Colors.black,
                labelStyle: TextStyle(color: Colors.white),
                errorText: isError ? errorMessage : null,
                errorMaxLines: 3,
                errorStyle:
                    TextStyle(color: Colors.red, fontSize: 12, height: 1.0),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 1.0),
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
                            if (label == 'Salida') {
                              flete.boasId = null;
                            } else if (label == 'Llegada') {
                              flete.boatId = null;
                            }
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
              AutocompleteOnSelected<BodegaViewModel> onSelected,
              Iterable<BodegaViewModel> options) {
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
                      final BodegaViewModel option = options.elementAt(index);
                      return GestureDetector(
                        onTap: () {
                          onSelected(option);
                        },
                        child: ListTile(
                          title: Text(option.bodeDescripcion!,
                              style: TextStyle(color: Colors.white)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          onSelected: (BodegaViewModel selection) {
            setState(() {
              controller.text = selection.bodeDescripcion!;
              if (label == 'Salida') {
                flete.boasId = selection.bodeId;
                _cargarInsumosPorBodega(flete.boasId!);
                _cargarEquiposDeSeguridadPorBodega(flete.boasId!);
              } else if (label == 'Llegada') {
                flete.boatId = selection.bodeId;
              }
            });
          },
        );
      },
    );
  }

  Widget _buildProyectoAutocompleteSalida() {
    return _buildProyectoAutocomplete('Salida', salidaController, 'Salida');
  }

  Widget _buildProyectoAutocompleteLlegada() {
    return _buildProyectoAutocomplete('Llegada', llegadaController, 'Llegada');
  }

  Widget _buildProyectoAutocomplete(
      String label, TextEditingController controller, String tipo) {
    bool isError =
        tipo == 'Salida' ? _ubicacionSalidaError : _ubicacionLlegadaError;
    String errorMessage = tipo == 'Salida'
        ? _ubicacionSalidaErrorMessage
        : _ubicacionLlegadaErrorMessage;

    FocusNode focusNode = FocusNode();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Autocomplete<ProyectoViewModel>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          List<ProyectoViewModel> filteredProyectos;

          if (textEditingValue.text.isEmpty) {
            filteredProyectos = List.from(proyectos);
          } else {
            filteredProyectos = proyectos.where((ProyectoViewModel option) {
              return option.proyNombre!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            }).toList();
          }

          // Ordenar la lista alfabéticamente por la propiedad proyNombre
          filteredProyectos.sort((a, b) => a.proyNombre!
              .toLowerCase()
              .compareTo(b.proyNombre!.toLowerCase()));

          return filteredProyectos;
        },
        displayStringForOption: (ProyectoViewModel option) =>
            option.proyNombre!,
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
              errorText: isError ? errorMessage : null,
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.red,
                    width: 1.0), // Borde rojo en caso de error
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.red,
                    width: 1.0), // Borde rojo cuando está enfocado y hay error
              ),
              errorMaxLines: 3,
              errorStyle: TextStyle(
                color: Colors.red,
                fontSize: 12,
                height: 1.0, // Controla el espaciado entre líneas
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
                          if (tipo == 'Salida') {
                            flete.boasId = null;
                            actividadesSalida.clear();
                          } else {
                            flete.boatId = null;
                            actividadesLlegada.clear();
                          }
                        });
                      },
                    ),
                  IconButton(
                    icon: Icon(Icons.arrow_drop_down, color: Color(0xFFFFF0C6)),
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
          );
        },
        optionsViewBuilder: (BuildContext context,
            AutocompleteOnSelected<ProyectoViewModel> onSelected,
            Iterable<ProyectoViewModel> options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: Container(
                width: MediaQuery.of(context).size.width - 73,
                color: Colors.black,
                child: options.isEmpty
                    ? ListTile(
                        title: Text('No hay coincidencias',
                            style: TextStyle(color: Colors.white)),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(8.0),
                        itemCount: options.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          final ProyectoViewModel option =
                              options.elementAt(index);
                          return GestureDetector(
                            onTap: () {
                              onSelected(option);
                            },
                            child: ListTile(
                              title: Text(option.proyNombre!,
                                  style: TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                      ),
              ),
            ),
          );
        },
        onSelected: (ProyectoViewModel selection) async {
          setState(() {
            controller.text = selection.proyNombre!;
            if (tipo == 'Salida') {
              flete.proyIdSalida = selection.proyId;
              actividadControllerSalida.clear();
            } else {
              flete.proyIdLlegada = selection.proyId;
              actividadControllerLlegada.clear();
            }
          });

          await _cargarActividadesPorProyecto(selection.proyId, tipo);
        },
      ),
      if ((tipo == 'Salida' ? actividadesSalida : actividadesLlegada)
          .isNotEmpty)
        SizedBox(height: 20),
      if ((tipo == 'Salida' ? actividadesSalida : actividadesLlegada)
          .isNotEmpty)
        _buildActividadAutocomplete(
            tipo == 'Salida'
                ? actividadControllerSalida
                : actividadControllerLlegada,
            tipo),
    ]);
  }

  Widget _buildActividadAutocomplete(
      TextEditingController controller, String tipo) {
    FocusNode focusNode = FocusNode();
    List<ActividadPorEtapaViewModel> actividades =
        tipo == 'Salida' ? actividadesSalida : actividadesLlegada;

    return Autocomplete<ActividadPorEtapaViewModel>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return actividades.isNotEmpty ? actividades : [];
        }
        return actividades.where((ActividadPorEtapaViewModel option) {
          return option.etapDescripcion!
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      displayStringForOption: (ActividadPorEtapaViewModel option) =>
          option.etapDescripcion! + ' - ' + option.actiDescripcion!,
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
            labelText: 'Actividad - Etapa',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.black,
            labelStyle: TextStyle(color: Colors.white),
            errorText: _actividadError ? _actividadErrorMessage : null,
            errorStyle: TextStyle(
              color: Colors.red,
              fontSize: 12,
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
                        if (tipo == 'Salida') {
                          flete.boasId = null;
                        } else {
                          flete.boatId = null;
                        }
                      });
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.arrow_drop_down, color: Color(0xFFFFF0C6)),
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
        );
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<ActividadPorEtapaViewModel> onSelected,
          Iterable<ActividadPorEtapaViewModel> options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: Container(
              width: MediaQuery.of(context).size.width -
                  73, // Asegura que el ancho sea igual al del input
              color: Colors.black,
              child: options.isEmpty
                  ? ListTile(
                      title: Text('No hay coincidencias',
                          style: TextStyle(color: Colors.white)),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(8.0),
                      itemCount: options.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        final ActividadPorEtapaViewModel option =
                            options.elementAt(index);
                        return GestureDetector(
                          onTap: () {
                            onSelected(option);
                          },
                          child: ListTile(
                            title: Text(
                              option.etapDescripcion! +
                                  ' - ' +
                                  option.actiDescripcion!,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        );
      },
      onSelected: (ActividadPorEtapaViewModel selection) {
        setState(() {
          controller.text =
              selection.etapDescripcion! + ' - ' + selection.actiDescripcion!;
          if (tipo == 'Salida') {
            flete.boasId = selection.acetId;
            _cargarInsumosPorActividadEtapa(flete.boasId!);
            _cargarEquiposDeSeguridadPorActividadEtapa(flete.boasId!);
          } else {
            flete.boatId = selection.acetId;
          }
          _actividadError = false;
          _actividadErrorMessage = '';
        });
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
          onChanged: (bool newValue) {
            setState(() {
              if (label == '¿Salida de Proyecto?') {
                esProyectosalida = newValue;
                flete.boasId = null;
                salidaController.clear();
              } else {
                esProyecto = newValue;
                flete.boatId = null;
                llegadaController.clear();
              }
            });
            onChanged(newValue);
          },
          activeColor: Color(0xFFFFF0C6),
        ),
      ],
    );
  }

  void _mostrarInsumosView() {
    setState(() {
      _mostrarInsumos = true;
    });
  }

  void _hideInsumosView() {
    setState(() {
      _mostrarInsumos = false;
    });
  }

  void _validarCamposYMostrarInsumos() {
    setState(() {
      // Resetear todos los errores
      _fechaSalidaError = false;
      _fechaSalidaErrorMessage = '';
      _fechaHoraEstablecidaError = false;
      _fechaHoraEstablecidaErrorMessage = '';
      _isEmpleadoError = false;
      _empleadoErrorMessage = '';
      _isSupervisorSalidaError = false;
      _supervisorSalidaErrorMessage = '';
      _isSupervisorLlegadaError = false;
      _supervisorLlegadaErrorMessage = '';
      _ubicacionSalidaError = false;
      _ubicacionSalidaErrorMessage = '';
      _ubicacionLlegadaError = false;
      _ubicacionLlegadaErrorMessage = '';
      _proyectoError = false;
      _proyectoErrorMessage = '';
      _actividadError = false;
      _actividadErrorMessage = '';

      bool hayErrores = false;

      // Validar Fecha y Hora de Salida
      if (flete.flenFechaHoraSalida == null) {
        _fechaSalidaError = true;
        _fechaSalidaErrorMessage = 'El campo es requerido.';
        hayErrores = true;
      }

      // Validar Fecha y Hora Establecida de Llegada
      if (flete.flenFechaHoraEstablecidaDeLlegada == null) {
        _fechaHoraEstablecidaError = true;
        _fechaHoraEstablecidaErrorMessage = 'El campo es requerido.';
        hayErrores = true;
      } else if (flete.flenFechaHoraSalida != null &&
          flete.flenFechaHoraSalida!
              .isAfter(flete.flenFechaHoraEstablecidaDeLlegada!)) {
        _fechaHoraEstablecidaError = true;
        _fechaHoraEstablecidaErrorMessage =
            'La fecha de salida no puede ser posterior a la de llegada.';
        hayErrores = true;
      } else if (flete.flenFechaHoraEstablecidaDeLlegada!
              .difference(flete.flenFechaHoraSalida!)
              .inMinutes <
          5) {
        _fechaHoraEstablecidaError = true;
        _fechaHoraEstablecidaErrorMessage =
            'Debe haber al menos 5 minutos de diferencia entre salida y llegada.';
        hayErrores = true;
      }

      // Validar Empleados
      if (flete.emtrId == null) {
        _isEmpleadoError = true;
        _empleadoErrorMessage = 'El campo es requerido.';
        hayErrores = true;
      }
      if (flete.emssId == null) {
        _isSupervisorSalidaError = true;
        _supervisorSalidaErrorMessage = 'El campo es requerido.';
        hayErrores = true;
      }
      if (flete.emslId == null) {
        _isSupervisorLlegadaError = true;
        _supervisorLlegadaErrorMessage = 'El campo es requerido.';
        hayErrores = true;
      }
      if (flete.emtrId == flete.emssId && flete.emtrId != null) {
        _isSupervisorSalidaError = true;
        _supervisorSalidaErrorMessage =
            'El supervisor de salida debe ser diferente al encargado';
        hayErrores = true;
      }
      if (flete.emtrId == flete.emslId && flete.emtrId != null) {
        _isSupervisorLlegadaError = true;
        _supervisorLlegadaErrorMessage =
            'El supervisor de llegada debe ser diferente al encargado';
        hayErrores = true;
      }
      if (flete.emssId == flete.emslId && flete.emssId != null) {
        _isSupervisorLlegadaError = true;
        _supervisorLlegadaErrorMessage =
            'El supervisor de llegada debe ser diferente al de salida';
        hayErrores = true;
      }
      if (flete.emtrId == flete.emssId &&
          flete.emssId == flete.emslId &&
          flete.emtrId != null &&
          flete.emssId != null) {
        _isSupervisorLlegadaError = true;
        _supervisorLlegadaErrorMessage =
            'Los supervisores deben ser diferentes';
        hayErrores = true;
      }

      // Validar Ubicaciones
      if (flete.boasId == null && esProyectosalida == false) {
        _ubicacionSalidaError = true;
        _ubicacionSalidaErrorMessage = 'El campo es requerido.';
        hayErrores = true;
      }
      if (flete.boasId == null && esProyectosalida && salidaController.text.isEmpty) {
        _ubicacionSalidaError = true;
        _ubicacionSalidaErrorMessage = 'El campo es requerido.';
        hayErrores = true;
      }
      if (flete.boatId == null && esProyecto && llegadaController.text.isEmpty) {
        _ubicacionLlegadaError = true;
        _ubicacionLlegadaErrorMessage = 'El campo es requerido.';
        hayErrores = true;
      }
      if (flete.boatId == null && esProyecto == false) {
        _ubicacionLlegadaError = true;
        _ubicacionLlegadaErrorMessage = 'El campo es requerido.';
        hayErrores = true;
      }
      if (flete.boasId == flete.boatId &&
          !esProyecto == false &&
          esProyectosalida == false) {
        _ubicacionLlegadaError = true;
        _ubicacionLlegadaErrorMessage =
            'Las ubicaciones de salida y llegada no pueden ser la misma.';
        hayErrores = true;
      }
      if (flete.boasId == flete.boatId && !esProyectosalida && esProyecto) {
        _ubicacionSalidaError = true;
        _ubicacionSalidaErrorMessage =
            'Las ubicaciones de salida y llegada no pueden ser la misma.';
        hayErrores = true;
      }
      if (flete.boasId == flete.boatId && !esProyectosalida && !esProyecto) {
        _ubicacionLlegadaError = true;
        _ubicacionLlegadaErrorMessage =
            'Las ubicaciones de salida y llegada no pueden ser la misma.';
        hayErrores = true;
      }

      // Validar Actividad por Etapa
      if (esProyectosalida &&
          actividadesSalida.isNotEmpty &&
          flete.boasId == null) {
        _actividadError = true;
        _actividadErrorMessage = 'El campo es requerido.';
        hayErrores = true;
      }

      if (esProyecto && actividadesLlegada.isNotEmpty && flete.boatId == null) {
        _actividadError = true;
        _actividadErrorMessage = 'El campo es requerido.';
        hayErrores = true;
      }

      if (esProyectosalida &&
          _noActividadesErrorsalida &&
          flete.boasId == null) {
        _ubicacionSalidaError = true;
        _ubicacionSalidaErrorMessage =
            'El proyecto no tiene actividades, seleccione otro.';
        hayErrores = true;
      }
      if (esProyecto && _noActividadesError && flete.boatId == null) {
        _ubicacionLlegadaError = true;
        _ubicacionLlegadaErrorMessage =
            'El proyecto no tiene actividades, seleccione otro.';
        hayErrores = true;
      }

      // Mostrar errores si los hay
      if (hayErrores) {
        return;
      }

      // Si no hay errores, mostrar la vista de insumos
      _mostrarInsumosView();
    });
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
        bottom: _mostrarInsumos
            ? PreferredSize(
                preferredSize:
                    _cargando ? Size.fromHeight(70.0) : Size.fromHeight(100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_cargando)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_back,
                                color: Color(0xFFFFF0C6),
                              ),
                              SizedBox(width: 5.0),
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

                    // Espacio adicional entre el botón y la TabBar
                    SizedBox(height: 10.0),

                    // TabBar
                    TabBar(
                      controller: _tabController,
                      tabs: [
                        Tab(text: 'Insumos'),
                        Tab(text: 'Equipos de Seguridad'),
                      ],
                      labelColor: Color(0xFFFFF0C6),
                      unselectedLabelColor: Colors.white,
                      indicatorColor: Color(0xFFFFF0C6),
                    ),
                  ],
                ),
              )
            : PreferredSize(
                preferredSize: Size.fromHeight(70.0),
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
                    SizedBox(height: 5),
                    if (!_cargando)
                      Row(
                        children: [
                          SizedBox(width: 5.0),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
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
      drawer: MenuLateral(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
      body: _cargando
          ? Container(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFFFFF0C6)),
              ),
            )
          : Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16.0),
              child: _mostrarInsumos ? _buildTabsView() : _buildFleteView(),
            ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
            bottom: _isKeyboardVisible
                ? MediaQuery.of(context).viewInsets.bottom
                : 0),
        child: _cargando ? SizedBox.shrink() : _botonDebajo(),
      ),
    );
  }

  Future<void> guardarFlete() async {
    setState(() {
      _cargando = true;
    });
    try {
      final pref = await SharedPreferences.getInstance();
      flete.usuaCreacion = int.tryParse(pref.getString('usuaId') ?? '');
      flete.flenEstado = false;
      flete.flenSalidaProyecto = esProyectosalida;
      flete.flenDestinoProyecto = esProyecto;

      // Verificar que no haya insumos seleccionados con cantidad 0 o vacía
      bool hayCantidadesInvalidas = false;
      bool hayCantidadesInvalidase = false;

      for (int i = 0; i < selectedInsumos.length; i++) {
        if (i >= quantityControllers.length) {
          // print("Error: La lista de controladores es más corta que la lista de insumos");
          break;
        }

        int? stock = selectedInsumos[i].bopiStock;
        int? cantidad = int.tryParse(quantityControllers[i].text);

        if (cantidad == null || cantidad <= 0) {
          setState(() {
            _cargando = false;
          });
          // print('Cantidad inválida detectada para ${selectedInsumos[i].insuDescripcion}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Cantidad inválida para insumo ${selectedInsumos[i].insuDescripcion}: $cantidad')),
          );
          quantityControllers[i].text = '1';
          selectedCantidades[i] = 1;
          hayCantidadesInvalidas = true;
        } else if (cantidad > stock!) {
          setState(() {
            _cargando = false;
          });
          // print('Cantidad excedida detectada para ${selectedInsumos[i].insuDescripcion}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Cantidad excedida para insumo ${selectedInsumos[i].insuDescripcion}: $cantidad')),
          );
          quantityControllers[i].text = stock.toString();
          selectedCantidades[i] = stock;
          hayCantidadesInvalidas = true;
        } else {
          selectedCantidades[i] = cantidad;
        }
      }

// Verificar equipos seleccionados
      for (int i = 0; i < selectedEquipos.length; i++) {
        if (i >= equipoQuantityControllers.length) {
          // print("Error: La lista de controladores de equipos es más corta que la lista de equipos");
          break;
        }

        int? stocke = selectedEquipos[i].bopiStock;
        int? cantidade = int.tryParse(equipoQuantityControllers[i].text);

        if (cantidade == null || cantidade <= 0) {
          setState(() {
            _cargando = false;
          });
          // print('Cantidad inválida detectada para equipo ${selectedEquipos[i].equsNombre}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Cantidad inválida para equipo ${selectedEquipos[i].equsNombre}: $cantidade')),
          );
          equipoQuantityControllers[i].text = '1';
          selectedCantidadesequipos[i] = 1;
          hayCantidadesInvalidase = true;
        } else if (cantidade > stocke!) {
          setState(() {
            _cargando = false;
          });
          // print('Cantidad excedida detectada para equipo ${selectedEquipos[i].equsNombre}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Cantidad excedida para equipo ${selectedEquipos[i].equsNombre}: $cantidade')),
          );
          equipoQuantityControllers[i].text = stocke.toString();
          selectedCantidadesequipos[i] = stocke;
          hayCantidadesInvalidase = true;
        } else {
          selectedCantidadesequipos[i] = cantidade;
        }
      }

      // Si hay cantidades inválidas, detener la ejecución
      if (hayCantidadesInvalidas || hayCantidadesInvalidase) {
        return;
      }

      // Verificar que al menos un insumo o equipo esté seleccionado
      if (selectedInsumos.isEmpty && selectedEquipos.isEmpty) {
        setState(() {
          _cargando = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Debe seleccionar al menos un insumo o equipo de seguridad.')),
        );
        return;
      }

      // print('Flete a insertar $flete');

      final int? flenIdNuevo =
          await FleteEncabezadoService.insertarFlete(flete);

      if (flenIdNuevo != null) {
        for (int i = 0; i < selectedInsumos.length; i++) {
          final detalle = FleteDetalleViewModel(
            fldeCantidad: selectedCantidades[i],
            fldeTipodeCarga: true,
            flenId: flenIdNuevo,
            inppId: selectedInsumos[i].inppId,
            usuaCreacion: int.tryParse(pref.getString('usuaId') ?? ''),
          );
          // print('Detalle data: ${detalle.toJson()}');
          await FleteDetalleService.insertarFleteDetalle(detalle);
        }
        for (int i = 0; i < selectedEquipos.length; i++) {
          final detalle = FleteDetalleViewModel(
            fldeCantidad: selectedCantidadesequipos[i],
            fldeTipodeCarga: false,
            flenId: flenIdNuevo,
            inppId: selectedEquipos[i].eqppId,
            usuaCreacion: int.tryParse(pref.getString('usuaId') ?? ''),
          );
          // print('Detalle eq: ${detalle.toJson()}');
          await FleteDetalleService.insertarFleteDetalle(detalle);
        }
        await _enviarNotificacionFletenuevo();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Flete(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insertado con Éxito.')),
        );
      } else {
        _cargando = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Algo salió mal. Comuníquese con un Administrador.')),
        );
      }
    } catch (e) {
      // print('Error: $e'); 
      debugPrint('Error: $e');

      // Mostrar mensaje en el SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Algo salió mal. Comuníquese con un Administrador.')),
      );
    }
  }

  Widget _buildTabsView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildInsumosTab(),
        _buildEquiposTab(),
      ],
    );
  }

  Widget _buildInsumosTab() {
    return ListView.builder(
      itemCount: insumos.length,
      itemBuilder: (context, index) {
        final insumo = insumos[index];
        int? stock = insumo.bopiStock;
        bool isSelected = selectedInsumos.contains(insumo);
        int cantidad = isSelected
            ? selectedCantidades[selectedInsumos.indexOf(insumo)]
            : 0;
        bool cantidadExcedida = cantidad > (stock ?? 0);

        return ListTile(
          title: Text(
            '${insumo.insuDescripcion ?? ''}',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Material: ${insumo.mateDescripcion}',
                  style: TextStyle(color: Colors.white70)),
              Text('Unidad: ${insumo.unmeNombre}',
                  style: TextStyle(color: Colors.white70)),
              Text('Stock: ${insumo.bopiStock}',
                  style: TextStyle(color: Colors.white70)),
              if (isSelected)
                Row(
                  children: [
                    Text('Cantidad: ', style: TextStyle(color: Colors.white70)),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: quantityControllers[
                            selectedInsumos.indexOf(insumo)],
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.white),
                        onChanged: (value) {
                          setState(() {
                            int? nuevaCantidad = int.tryParse(value);
                            if (nuevaCantidad == null || nuevaCantidad <= 0) {
                              cantidadExcedida = false;
                            } else if (nuevaCantidad > stock!) {
                              selectedCantidades[
                                  selectedInsumos.indexOf(insumo)] = stock!;
                              cantidadExcedida = true;
                            } else {
                              selectedCantidades[selectedInsumos
                                  .indexOf(insumo)] = nuevaCantidad;
                              cantidadExcedida = false;
                            }
                          });
                        },
                        onSubmitted: (value) {
                          setState(() {
                            int? nuevaCantidad = int.tryParse(value);
                            if (nuevaCantidad != null &&
                                nuevaCantidad > stock!) {
                              selectedCantidades[
                                  selectedInsumos.indexOf(insumo)] = stock!;
                              quantityControllers[
                                      selectedInsumos.indexOf(insumo)]
                                  .text = stock.toString();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              if (cantidadExcedida)
                Text(
                  'La cantidad no puede ser mayor que el stock disponible.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
            ],
          ),
          trailing: Checkbox(
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedInsumos.add(insumo);
                  quantityControllers.add(TextEditingController(text: '1'));
                  selectedCantidades.add(1);
                } else {
                  int removeIndex = selectedInsumos.indexOf(insumo);
                  selectedInsumos.removeAt(removeIndex);
                  quantityControllers.removeAt(removeIndex);
                  selectedCantidades.removeAt(removeIndex);
                }
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildEquiposTab() {
    return ListView.builder(
      itemCount: equiposdeSeguridad.length,
      itemBuilder: (context, index) {
        final equipo = equiposdeSeguridad[index];
        int? stockE = equipo.bopiStock;
        bool isSelected = selectedEquipos.contains(equipo);
        int cantidadE = isSelected
            ? selectedCantidadesequipos[selectedEquipos.indexOf(equipo)]
            : 0;
        bool cantidadExcedidaE = cantidadE > (stockE ?? 0);

        return ListTile(
          title: Text(
            '${equipo.equsNombre ?? ''}',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Descripción: ${equipo.equsDescripcion ?? ''}',
                  style: TextStyle(color: Colors.white70)),
              Text('Stock: ${equipo.bopiStock ?? 0}',
                  style: TextStyle(color: Colors.white70)),
              if (isSelected)
                Row(
                  children: [
                    Text('Cantidad: ', style: TextStyle(color: Colors.white70)),
                    SizedBox(
                      width: 50,
                      child: TextField(
                        controller: equipoQuantityControllers[
                            selectedEquipos.indexOf(equipo)],
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.white),
                        onChanged: (value) {
                          setState(() {
                            int? nuevaCantidadE = int.tryParse(value);
                            if (nuevaCantidadE == null || nuevaCantidadE <= 0) {
                              cantidadExcedidaE = false;
                            } else if (nuevaCantidadE > stockE!) {
                              selectedCantidadesequipos[
                                  selectedEquipos.indexOf(equipo)] = stockE!;
                              cantidadExcedidaE = true;
                            } else {
                              selectedCantidadesequipos[selectedEquipos
                                  .indexOf(equipo)] = nuevaCantidadE;
                              cantidadExcedidaE = false;
                            }
                          });
                        },
                        onSubmitted: (value) {
                          setState(() {
                            int? nuevaCantidadE = int.tryParse(value);
                            if (nuevaCantidadE != null &&
                                nuevaCantidadE > stockE!) {
                              selectedCantidadesequipos[
                                  selectedEquipos.indexOf(equipo)] = stockE!;
                              equipoQuantityControllers[
                                      selectedEquipos.indexOf(equipo)]
                                  .text = stockE.toString();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              if (cantidadExcedidaE)
                Text(
                  'La cantidad no puede ser mayor que el stock disponible.',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
            ],
          ),
          trailing: Checkbox(
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedEquipos.add(equipo);
                  equipoQuantityControllers
                      .add(TextEditingController(text: '1'));
                  selectedCantidadesequipos.add(1);
                } else {
                  int removeIndex = selectedEquipos.indexOf(equipo);
                  selectedEquipos.removeAt(removeIndex);
                  equipoQuantityControllers.removeAt(removeIndex);
                  selectedCantidadesequipos.removeAt(removeIndex);
                }
              });
            },
          ),
        );
      },
    );
  }

  Widget _botonDebajo() {
    return _mostrarInsumos ? _insumosBotones() : _fleteBoton();
  }

  Widget _fleteBoton() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(
                bottom: 10.0, right: 10.0), // Espacio adicional al lado y abajo
            child: Row(
              children: [
                Text(
                  'Agregar Materiales', // Texto que aparecerá junto al botón
                  style: TextStyle(
                    color: Color(0xFFFFF0C6), // Mismo color que el ícono
                    fontSize: 15.0,
                  ),
                ),
                SizedBox(width: 8.0), // Espacio entre el texto y el botón
                FloatingActionButton(
                  onPressed: _validarCamposYMostrarInsumos,
                  backgroundColor: Color(0xFF171717),
                  child: Icon(Icons.add,
                      color: Color(0xFFFFF0C6)), // Color del ícono
                  shape: CircleBorder(), // Mantener la forma circular
                  elevation: 2.0, // Ajusta la elevación si es necesario
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _insumosBotones() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: guardarFlete,
            icon: Icon(Icons.save, color: Colors.black),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFF0C6),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            label: Text(
              'Guardar',
              style: TextStyle(color: Colors.black, fontSize: 15),
            ),
          ),
          SizedBox(width: 18),
          ElevatedButton.icon(
            onPressed: _hideInsumosView,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF222222),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: Icon(Icons.close, color: Colors.white), // Icono de Cancelar
            label: Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 15),
            ),
          ),
        ],
      ),
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
                    'Fecha y Hora',
                    style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  _fechaSalida(),
                  SizedBox(height: 20),
                  _fechaHoraEstablecida(),
                  SizedBox(height: 20),
                  Text(
                    'Empleados',
                    style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  _buildAutocomplete('Encargado', encargadoController),
                  SizedBox(height: 20),
                  _buildAutocomplete(
                      'Supervisor de Salida', supervisorSalidaController),
                  SizedBox(height: 20),
                  _buildAutocomplete(
                      'Supervisor de Llegada', supervisorLlegadaController),
                  SizedBox(height: 20),
                  _switch('¿Salida de Proyecto?', esProyectosalida, (value) {
                    setState(() {
                      esProyectosalida = value;
                    });
                  }),
                  SizedBox(height: 20),
                  _switch('¿Dirigido a Proyecto?', esProyecto, (value) {
                    setState(() {
                      esProyecto = value;
                    });
                  }),
                  SizedBox(height: 20),
                  Text(
                    'Ubicaciones',
                    style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  esProyectosalida
                      ? _buildProyectoAutocompleteSalida()
                      : _buildBodegaAutocomplete('Salida', salidaController),
                  SizedBox(height: 20),
                  esProyecto
                      ? _buildProyectoAutocompleteLlegada()
                      : _buildBodegaAutocomplete('Llegada', llegadaController),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fechaSalida() {
    return TextField(
      readOnly: true,
      onTap: () async {
        await _FechaSeleccionada(isSalida: true);
      },
      decoration: InputDecoration(
        labelText: 'Salida',
        suffixIcon: Icon(Icons.calendar_today, color: Color(0xFFFFF0C6)),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.black,
        labelStyle: TextStyle(color: Colors.white),
        errorText: _fechaSalidaError ? _fechaSalidaErrorMessage : null,
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.red, width: 1.0), // Borde rojo en caso de error
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: const Color.fromARGB(255, 117, 102, 100),
              width: 1.0), // Borde rojo cuando está enfocado y hay error
        ),
        errorMaxLines: 3,
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 12,
          height: 1.0, // Controla el espaciado entre líneas
        ),
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
        await _FechaSeleccionada(isSalida: false);
        if (_fechaHoraEstablecidaError) {
          setState(() {
            _fechaHoraEstablecidaError = false;
            _fechaHoraEstablecidaErrorMessage = '';
          });
        }
      },
      focusNode: _fechaHoraEstablecidaFocusNode,
      decoration: InputDecoration(
        labelText: 'Establecida de Llegada',
        suffixIcon: Icon(Icons.calendar_today, color: Color(0xFFFFF0C6)),
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.black,
        labelStyle: TextStyle(color: Colors.white),
        errorText: _fechaHoraEstablecidaError
            ? _fechaHoraEstablecidaErrorMessage
            : null,
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.red, width: 1.0), // Borde rojo en caso de error
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Colors.red,
              width: 1.0), // Borde rojo cuando está enfocado y hay error
        ),
        errorMaxLines: 3, // Permitir varias líneas en el mensaje de error
        errorStyle: TextStyle(
          color: Colors.red,
          fontSize: 12,
          height: 1.0, // Controla el espaciado entre líneas
        ),
      ),
      style: TextStyle(color: Colors.white),
      controller: TextEditingController(
        text: establishedDate == null || establishedTime == null
            ? ''
            : "${establishedDate!.toLocal().toString().split(' ')[0]} ${establishedTime!.format(context)}",
      ),
    );
  }

  Widget _buildAutocomplete(String label, TextEditingController controller) {
    bool isError = false;
    String errorMessage = '';

    if (label == 'Encargado') {
      isError = _isEmpleadoError;
      errorMessage = _empleadoErrorMessage;
    } else if (label == 'Supervisor de Salida') {
      isError = _isSupervisorSalidaError;
      errorMessage = _supervisorSalidaErrorMessage;
    } else if (label == 'Supervisor de Llegada') {
      isError = _isSupervisorLlegadaError;
      errorMessage = _supervisorLlegadaErrorMessage;
    }

    FocusNode focusNode = FocusNode();

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Autocomplete<EmpleadoViewModel>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            List<EmpleadoViewModel> filteredEmpleados;

            if (textEditingValue.text.isEmpty) {
              filteredEmpleados = List.from(empleados);
            } else {
              filteredEmpleados = empleados.where((EmpleadoViewModel option) {
                return option.empleado!
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()) ||
                    option.emplDNI!
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
              }).toList();
            }

            filteredEmpleados.sort((a, b) =>
                a.empleado!.toLowerCase().compareTo(b.empleado!.toLowerCase()));

            return filteredEmpleados;
          },
          displayStringForOption: (EmpleadoViewModel option) =>
              option.empleado!,
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
                errorText: isError ? errorMessage : null,
                errorMaxLines: 3,
                errorStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  height: 1.0, // Controla el espaciado entre líneas
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.red,
                      width: 1.0), // Borde rojo en caso de error
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.red,
                      width:
                          1.0), // Borde rojo cuando está enfocado y hay error
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
                            if (label == 'Encargado') {
                              flete.emtrId = null;
                            } else if (label == 'Supervisor de Salida') {
                              flete.emssId = null;
                            } else if (label == 'Supervisor de Llegada') {
                              flete.emslId = null;
                            }
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
              AutocompleteOnSelected<EmpleadoViewModel> onSelected,
              Iterable<EmpleadoViewModel> options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: Container(
                  width: constraints.maxWidth,
                  color: Colors.black,
                  child: options.isEmpty
                      ? ListTile(
                          title: Text('No hay coincidencias',
                              style: TextStyle(color: Colors.white)),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(8.0),
                          itemCount: options.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            final EmpleadoViewModel option =
                                options.elementAt(index);
                            return GestureDetector(
                              onTap: () {
                                onSelected(option);
                              },
                              child: ListTile(
                                title: Text(option.empleado!,
                                    style: TextStyle(color: Colors.white)),
                              ),
                            );
                          },
                        ),
                ),
              ),
            );
          },
          onSelected: (EmpleadoViewModel selection) {
            setState(() {
              controller.text = selection.empleado!;
              if (label == 'Encargado') {
                flete.emtrId = selection.emplId;
              } else if (label == 'Supervisor de Salida') {
                flete.emssId = selection.emplId;
              } else if (label == 'Supervisor de Llegada') {
                flete.emslId = selection.emplId;
              }
            });
          },
        );
      },
    );
  }
}
