import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:sigesproc_app/models/fletes/fletedetalleviewmodel.dart';
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/models/insumos/equipoporproveedorviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/actividadesporetapaviewmodel.dart';
import 'package:sigesproc_app/screens/fletes/flete.dart';
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
  bool _showInsumos = false;
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
  TextEditingController llegadaController = TextEditingController();
  TextEditingController actividadController = TextEditingController();
  List<TextEditingController> quantityControllers = [];
  TextEditingController encargadoController = TextEditingController();
  TextEditingController supervisorSalidaController = TextEditingController();
  TextEditingController supervisorLlegadaController = TextEditingController();
  TextEditingController salidaController = TextEditingController();
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

  FleteEncabezadoViewModel flete = FleteEncabezadoViewModel(
    codigo: '',
    flenFechaHoraSalida: null,
    flenFechaHoraEstablecidaDeLlegada: null,
    emtrId: null,
    emssId: null,
    emslId: null,
    bollId: null,
    boatId: null,
    flenEstado: null,
    flenDestinoProyecto: null,
    usuaCreacion: null,
    flenFechaCreacion: null,
    usuaModificacion: null,
    flenFechaModificacion: null,
    flenEstadoFlete: null,
  );

  @override
  void initState() {
    super.initState();
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
    if (flete.bollId != null) {
      BodegaViewModel? salida =
          bodegas.firstWhere((bode) => bode.bodeId == flete.bollId);
      if (salida != null) {
        salidaController.text = salida.bodeDescripcion!;
      }
    }
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    super.dispose();
  }

  Future<void> _cargarEmpleados() async {
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

  Future<void> _cargarBodegas() async {
    try {
      List<BodegaViewModel> bodegasList = await BodegaService.listarBodegas();
      setState(() {
        bodegas = bodegasList;
      });
    } catch (e) {
      print('Error al cargar las bodegas: $e');
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
      print('Error al cargar los proyectos: $e');
    }
  }

  Future<void> _cargarActividadesPorProyecto(int proyId) async {
    try {
      actividades =
          await ActividadPorEtapaService.obtenerActividadesPorProyecto(proyId);
      if (actividades.isEmpty) {
        print('que $actividades');
        _noActividadesError = true;
      } else {
        _noActividadesError = false;
      }
    } catch (e) {
      print('Error al cargar las actividades: $e');
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
      setState(() {
        insumos = insumosList;
        // Inicializar controladores para cada insumo cargado
        quantityControllers = List.generate(
            insumos.length, (index) => TextEditingController(text: '1'));
        selectedCantidades = List.generate(insumos.length, (index) => 1);
      });
    } catch (e) {
      print('Error al cargar los insumos: $e');
    }
  }

  Future<void> _cargarEquiposDeSeguridadPorBodega(int bodeId) async {
    try {
      print('entra a equi');
      List<EquipoPorProveedorViewModel> equiposList =
          await FleteDetalleService.listarEquiposdeSeguridadPorBodega(bodeId);
      setState(() {
        equiposdeSeguridad = equiposList;
        print('equipos $equiposdeSeguridad');
        equipoQuantityControllers = List.generate(equiposdeSeguridad.length,
            (index) => TextEditingController(text: '1'));
        selectedCantidadesequipos =
            List.generate(equiposdeSeguridad.length, (index) => 1);
      });
    } catch (e) {
      print('Error al cargar los equipos de seguridad: $e');
    }
  }

  void _toggleEquiposDeSeguridad(bool value) {
    setState(() {
      _showEquiposDeSeguridad = value;
      if (_showEquiposDeSeguridad) {
        _cargarEquiposDeSeguridadPorBodega(flete.bollId!);
      }
    });
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
            if (textEditingValue.text.isEmpty) {
              return bodegas; // Mostrar todas las opciones cuando el campo está vacío
            }
            return bodegas.where((BodegaViewModel option) {
              return option.bodeDescripcion!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
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
                            if (label == 'Salida') {
                              flete.bollId = null;
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
                flete.bollId = selection.bodeId;
                _cargarInsumosPorBodega(flete.bollId!);
              } else if (label == 'Llegada') {
                flete.boatId = selection.bodeId;
              }
            });
          },
        );
      },
    );
  }

  Widget _buildProyectoAutocomplete(TextEditingController controller) {
    FocusNode focusNode = FocusNode();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Autocomplete<ProyectoViewModel>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return proyectos.isNotEmpty ? proyectos : [];
          }
          return proyectos.where((ProyectoViewModel option) {
            return option.proyNombre!
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase());
          });
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
              labelText: 'Llegada',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.black,
              labelStyle: TextStyle(color: Colors.white),
              errorText: _proyectoError ? _proyectoErrorMessage : null,
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
                          flete.boatId = null;
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
            _proyectoError = false;
            _proyectoErrorMessage = '';
            flete.boatId =
                null; // Limpia cualquier selección previa de actividad
            actividadController.clear();
          });

          // Cargar actividades inmediatamente después de seleccionar el proyecto
          await _cargarActividadesPorProyecto(selection.proyId!);

          // Forzar la actualización del estado para que se muestre el autocomplete de actividades
          setState(() {});
        },
      ),
      if (actividades.isNotEmpty)
        SizedBox(height: 20), // Añadir espacio entre los widgets
      if (actividades.isNotEmpty)
        _buildActividadAutocomplete(actividadController),
    ]);
  }

  Widget _buildActividadAutocomplete(TextEditingController controller) {
    FocusNode focusNode = FocusNode();

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
                        flete.boatId = null;
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
                                style: TextStyle(color: Colors.white)),
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
          flete.boatId = selection.acetId;
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
              flete.flenDestinoProyecto = newValue;
              llegadaController.clear();
            });
            onChanged(newValue);
          },
          activeColor: Color(0xFFFFF0C6),
        ),
      ],
    );
  }

  void _showInsumosView() {
    setState(() {
      _showInsumos = true;
    });
  }

  void _hideInsumosView() {
    setState(() {
      _showInsumos = false;
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

      // Validar Fecha y Hora de Salida
      if (flete.flenFechaHoraSalida == null) {
        _fechaSalidaError = true;
        _fechaSalidaErrorMessage = 'La fecha de salida no puede estar vacía';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fecha de salida inválida')),
        );
      }

      // Validar Fecha y Hora Establecida de Llegada
      if (flete.flenFechaHoraEstablecidaDeLlegada == null) {
        _fechaHoraEstablecidaError = true;
        _fechaHoraEstablecidaErrorMessage =
            'La fecha de llegada no puede estar vacía';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fecha de llegada inválida.')),
        );
      } else if (flete.flenFechaHoraSalida != null &&
          flete.flenFechaHoraSalida!
              .isAfter(flete.flenFechaHoraEstablecidaDeLlegada!)) {
        _fechaHoraEstablecidaError = true;
        _fechaHoraEstablecidaErrorMessage =
            'La fecha de salida no puede ser posterior a la de llegada.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fechas Inválidas.')),
        );
      } else if (flete.flenFechaHoraEstablecidaDeLlegada!
              .difference(flete.flenFechaHoraSalida!)
              .inMinutes <
          5) {
        _fechaHoraEstablecidaError = true;
        _fechaHoraEstablecidaErrorMessage =
            'Debe haber al menos 5 minutos de diferencia entre salida y llegada.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fechas Inválidas.')),
        );
      }

      // Validar Empleados
      if (flete.emtrId == null) {
        _isEmpleadoError = true;
        _empleadoErrorMessage = 'El encargado no puede estar vacío';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Empleado encargado inválido.')),
        );
      }
      if (flete.emssId == null) {
        _isSupervisorSalidaError = true;
        _supervisorSalidaErrorMessage =
            'El supervisor de salida no puede estar vacío';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Empleado supervisor inválido.')),
        );
      }
      if (flete.emslId == null) {
        _isSupervisorLlegadaError = true;
        _supervisorLlegadaErrorMessage =
            'El supervisor de llegada no puede estar vacío';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Empleado supervisor inválido.')),
        );
      }
      if (flete.emtrId == flete.emssId && flete.emtrId != null) {
        _isSupervisorSalidaError = true;
        _supervisorSalidaErrorMessage =
            'El supervisor de salida debe ser diferente al encargado';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Empleados Inválidos.')),
        );
      }
      if (flete.emtrId == flete.emslId && flete.emtrId != null) {
        _isSupervisorLlegadaError = true;
        _supervisorLlegadaErrorMessage =
            'El supervisor de llegada debe ser diferente al encargado';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Empleados Inválidos.')),
        );
      }
      if (flete.emssId == flete.emslId && flete.emssId != null) {
        _isSupervisorLlegadaError = true;
        _supervisorLlegadaErrorMessage =
            'El supervisor de llegada debe ser diferente al de salida';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Supervisores Inválidos.')),
        );
      }
      if (flete.emtrId == flete.emssId &&
          flete.emssId == flete.emslId &&
          flete.emtrId != null &&
          flete.emssId != null) {
        _isSupervisorLlegadaError = true;
        _supervisorLlegadaErrorMessage =
            'Los supervisores deben ser diferentes';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Supervisores Inválidos.')),
        );
      }

      // Validar Ubicaciones
      if (flete.bollId == null) {
        _ubicacionSalidaError = true;
        _ubicacionSalidaErrorMessage =
            'La ubicación de salida no puede estar vacía';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ubicación Inválida.')),
        );
      }
      if (flete.bollId == flete.boatId && !esProyecto) {
        _ubicacionLlegadaError = true;
        _ubicacionLlegadaErrorMessage =
            'Las ubicaciones de salida y llegada no pueden ser la misma bodega.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ubicaciones Inválidas.')),
        );
      }

      // Validar Actividad por Etapa
      if (esProyecto && actividades.isNotEmpty && flete.boatId == null) {
        _actividadError = true;
        _actividadErrorMessage = 'Debe seleccionar una actividad por etapa';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ubicacion de llegada inválida.')),
        );
      }

      if (esProyecto && _noActividadesError && flete.boatId == null) {
        _proyectoError = true;
        _proyectoErrorMessage =
            'El proyecto no tiene actividades, seleccione otro.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ubicacion de llegada inválida.')),
        );
        return;
      }

      // Mostrar errores si los hay
      if (_fechaSalidaError ||
          _fechaHoraEstablecidaError ||
          _isEmpleadoError ||
          _isSupervisorSalidaError ||
          _isSupervisorLlegadaError ||
          _ubicacionSalidaError ||
          _ubicacionLlegadaError ||
          _proyectoError ||
          _actividadError) {
        return;
      }

      // Si no hay errores, mostrar la vista de insumos
      _showInsumosView();
    });
  }

  void _mostrarDialogoError(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                _showInsumos ? 'Seleccionar Insumos' : 'Nuevo Flete',
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
        child: _showInsumos ? _buildInsumosView() : _buildFleteView(),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
            bottom: _isKeyboardVisible
                ? MediaQuery.of(context).viewInsets.bottom
                : 0),
        child: _showInsumos ? _buildInsumosBottomBar() : _buildFleteBottomBar(),
      ),
    );
  }

  Future<void> guardarFlete() async {
    flete.usuaCreacion = 3;
    flete.flenEstado = false;
    if (flete.flenDestinoProyecto == null) {
      flete.flenDestinoProyecto = false;
    }

    // Verificar que no haya insumos seleccionados con cantidad 0 o vacía
    bool hayCantidadesInvalidas = false;
    bool hayCantidadesInvalidase = false;

    // Filtrar insumos con cantidades inválidas o nulas
    selectedInsumos.removeWhere((insumo) {
      int? cantidad = int.tryParse(
          quantityControllers[selectedInsumos.indexOf(insumo)].text);
      if (cantidad == null || cantidad <= 0) {
        print(
            'Eliminando insumo ${insumo.insuDescripcion} con cantidad nula o inválida.');
        return true; // Eliminar el insumo del arreglo
      }
      return false;
    });

    // Verificar cantidades restantes en insumos
    for (int i = 0; i < selectedInsumos.length; i++) {
      int? stock = selectedInsumos[i].bopiStock;
      int? cantidad = int.tryParse(quantityControllers[i].text);

      if (cantidad! <= 0) {
        print(
            'Cantidad inválida para insumo ${selectedInsumos[i].insuDescripcion}: $cantidad');
        quantityControllers[i].text = '1';
        selectedCantidades[i] = 1;
        hayCantidadesInvalidas = true;
      } else if (cantidad == null) {
      } else if (cantidad > stock!) {
        print(
            'Cantidad excedida para insumo ${selectedInsumos[i].insuDescripcion}: $cantidad');
        quantityControllers[i].text = stock.toString();
        selectedCantidades[i] = stock;
        hayCantidadesInvalidas = true;
      } else {
        selectedCantidades[i] = cantidad;
      }
    }

    // Filtrar equipos con cantidades inválidas o nulas
    selectedEquipos.removeWhere((equipo) {
      int? cantidad = int.tryParse(
          equipoQuantityControllers[selectedEquipos.indexOf(equipo)].text);
      if (cantidad == null || cantidad <= 0) {
        print(
            'Eliminando equipo ${equipo.equsNombre} con cantidad nula o inválida.');
        return true; // Eliminar el equipo del arreglo
      }
      return false;
    });

    // Verificar cantidades restantes en equipos
    for (int i = 0; i < selectedEquipos.length; i++) {
      int? stocke = selectedEquipos[i].bopiStock;
      int? cantidade = int.tryParse(equipoQuantityControllers[i].text);

      if (cantidade! <= 0 ) {
        print(
            'Cantidad inválida para equipo ${selectedEquipos[i].equsNombre}: $cantidade');
        equipoQuantityControllers[i].text = '1';
        selectedCantidadesequipos[i] = 1;
        hayCantidadesInvalidase = true;
      } else if (cantidade == null) {
      } else if (cantidade > stocke!) {
        print(
            'Cantidad excedida para equipo ${selectedEquipos[i].equsNombre}: $cantidade');
        equipoQuantityControllers[i].text = stocke.toString();
        selectedCantidadesequipos[i] = stocke;
        hayCantidadesInvalidase = true;
      } else {
        selectedCantidadesequipos[i] = cantidade;
      }
    }

    if (hayCantidadesInvalidas) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Cantidades ajustadas de Insumos. Por favor, revise las cantidades.')),
      );
      return;
    }

    if (hayCantidadesInvalidase) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Cantidades ajustadas de Equipos. Por favor, revise las cantidades.')),
      );
      return;
    }

    // Cambiar la condición para verificar si ambos están vacíos
    if (selectedInsumos.isEmpty && selectedEquipos.isEmpty) {
      print('insumos vacio $selectedInsumos');
      print('equipos vacio $selectedEquipos');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Debe seleccionar al menos un insumo o equipo de seguridad.')),
      );
      return;
    }

    print('fleteaa $flete');

    final int? flenIdNuevo = await FleteEncabezadoService.insertarFlete(flete);
    print('guardo e id $flenIdNuevo');
    if (flenIdNuevo != null) {
      for (int i = 0; i < selectedInsumos.length; i++) {
        final detalle = FleteDetalleViewModel(
          fldeCantidad: selectedCantidades[i],
          fldeTipodeCarga: true,
          flenId: flenIdNuevo,
          inppId: selectedInsumos[i].inppId,
          usuaCreacion: 3,
        );
        print('Detalle data: ${detalle.toJson()}');
        await FleteDetalleService.insertarFleteDetalle(detalle);
      }
      for (int i = 0; i < selectedEquipos.length; i++) {
        final detalle = FleteDetalleViewModel(
          fldeCantidad: selectedCantidadesequipos[i],
          fldeTipodeCarga: false,
          flenId: flenIdNuevo,
          inppId: selectedEquipos[i].eqppId,
          usuaCreacion: 3,
        );
        print('Detalle eq: ${detalle.toJson()}');
        await FleteDetalleService.insertarFleteDetalle(detalle);
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Flete(),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Flete enviado con éxito')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el flete')),
      );
    }
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
                  _buildBodegaAutocomplete('Salida', salidaController),
                  SizedBox(height: 20),
                  esProyecto
                      ? _buildProyectoAutocomplete(llegadaController)
                      : _buildBodegaAutocomplete('Llegada', llegadaController),
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
                        'Insumos',
                        style:
                            TextStyle(color: Color(0xFFFFF0C6), fontSize: 18),
                      ),
                      FloatingActionButton(
                        onPressed: _validarCamposYMostrarInsumos,
                        backgroundColor: Color(0xFFFFF0C6),
                        mini: true,
                        child:
                            Icon(Icons.add_circle_outline, color: Colors.black),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildInsumosView() {
  final empleado = empleados.firstWhere(
    (emp) => emp.emplId == flete.emssId,
    orElse: () => EmpleadoViewModel(emplId: 0, empleado: 'N/A'),
  );

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Supervisor de envío: ${empleado.emplNombre} ${empleado.emplApellido}',
              style: TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            Text(
              'Flete del ${DateFormat('EEE d MMM, hh:mm a').format(flete.flenFechaHoraSalida ?? DateTime.now())}',
              style: TextStyle(fontSize: 14, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Equipos de Seguridad',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Switch(
                  value: _showEquiposDeSeguridad,
                  onChanged: (bool value) {
                    setState(() {
                      _showEquiposDeSeguridad = value;
                      if (_showEquiposDeSeguridad) {
                        _cargarEquiposDeSeguridadPorBodega(flete.bollId!);
                      }
                    });
                  },
                  activeColor: Color(0xFFFFF0C6),
                )
              ],
            ),
          ],
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ListView.builder(
            itemCount: _showEquiposDeSeguridad
                ? equiposdeSeguridad.length
                : insumos.length,
            itemBuilder: (context, index) {
              if (_showEquiposDeSeguridad) {
                // Renderizar Equipos de Seguridad
                final equipo = equiposdeSeguridad[index];
                int? stockE = equipo.bopiStock;
                int cantidadE = selectedCantidadesequipos.length > index
                    ? selectedCantidadesequipos[index]
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
                      if (selectedEquipos.contains(equipo))
                        Row(
                          children: [
                            Text('Cantidad: ',
                                style: TextStyle(color: Colors.white70)),
                            SizedBox(
                              width: 30,
                              child: TextField(
                                controller: equipoQuantityControllers[index],
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: Colors.white),
                                onChanged: (value) {
                                  setState(() {
                                    int? cantidadE = int.tryParse(value);
                                    if (cantidadE == null || cantidadE <= 0) {
                                      cantidadExcedidaE = false;
                                    } else if (cantidadE > stockE!) {
                                      selectedCantidadesequipos[index] =
                                          cantidadE;
                                      cantidadExcedidaE = true;
                                    } else {
                                      selectedCantidadesequipos[index] =
                                          cantidadE;
                                      cantidadExcedidaE = false;
                                    }
                                  });
                                },
                                onSubmitted: (value) {
                                  setState(() {
                                    int? cantidadE = int.tryParse(value);
                                    if (cantidadE != null &&
                                        cantidadE > stockE!) {
                                      selectedCantidadesequipos[index] = stockE;
                                      equipoQuantityControllers[index].text =
                                          stockE.toString();
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
                    value: selectedEquipos.contains(equipo),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedEquipos.add(equipo);
                          equipoQuantityControllers[index].text = '1';
                        } else {
                          int removeIndex =
                              selectedEquipos.indexOf(equipo);
                          selectedEquipos.removeAt(removeIndex);
                          selectedCantidadesequipos[removeIndex] = 0;
                          equipoQuantityControllers[removeIndex].clear();
                        }
                      });
                    },
                  ),
                );
              } else {
                // Renderizar Insumos
                final insumo = insumos[index];
                int? stock = insumo.bopiStock;
                int cantidad = selectedCantidades.length > index
                    ? selectedCantidades[index]
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
                      if (selectedInsumos.contains(insumo))
                        Row(
                          children: [
                            Text('Cantidad: ',
                                style: TextStyle(color: Colors.white70)),
                            SizedBox(
                              width: 30,
                              child: TextField(
                                controller: quantityControllers[index],
                                keyboardType: TextInputType.number,
                                style: TextStyle(color: Colors.white),
                                onChanged: (value) {
                                  setState(() {
                                    int? cantidad = int.tryParse(value);
                                    if (cantidad == null || cantidad <= 0) {
                                      cantidadExcedida = false;
                                    } else if (cantidad > stock!) {
                                      selectedCantidades[index] = cantidad;
                                      cantidadExcedida = true;
                                    } else {
                                      selectedCantidades[index] = cantidad;
                                      cantidadExcedida = false;
                                    }
                                  });
                                },
                                onSubmitted: (value) {
                                  setState(() {
                                    int? cantidad = int.tryParse(value);
                                    if (cantidad != null &&
                                        cantidad > stock!) {
                                      selectedCantidades[index] = stock;
                                      quantityControllers[index].text =
                                          stock.toString();
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
                    value: selectedInsumos.contains(insumo),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedInsumos.add(insumo);
                          quantityControllers[index].text = '1';
                        } else {
                          int removeIndex =
                              selectedInsumos.indexOf(insumo);
                          selectedInsumos.removeAt(removeIndex);
                          selectedCantidades[removeIndex] = 0;
                          quantityControllers[removeIndex].clear();
                        }
                      });
                    },
                  ),
                );
              }
            },
          ),
        ),
      ),
    ],
  );
}

  Widget _buildFleteBottomBar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF171717),
              padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Flete(),
                ),
              );
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
        ],
      ),
    );
  }

  Widget _buildInsumosBottomBar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: _hideInsumosView,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF171717),
              padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8.0), // Bordes menos redondeados
              ),
            ),
            child: Text(
              'Regresar',
              style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 15),
            ),
          ),
          ElevatedButton(
            onPressed: guardarFlete,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFF0C6),
              padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8.0), // Bordes menos redondeados
              ),
            ),
            child: Text(
              'Guardar',
              style: TextStyle(color: Colors.black, fontSize: 15),
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
          borderSide: BorderSide(color: Color(0xFFFFF0C6)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFF0C6)),
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
          borderSide: BorderSide(color: Color(0xFFFFF0C6)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFFF0C6)),
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

  Widget _buildLlegadaDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Llegada',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.black,
        labelStyle: TextStyle(color: Colors.white),
      ),
      items: esProyecto
          ? proyectos.map((ProyectoViewModel proyecto) {
              return DropdownMenuItem<String>(
                value: proyecto.proyNombre,
                child: Text(
                  proyecto.proyNombre!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14),
                ),
              );
            }).toList()
          : bodegas.map((BodegaViewModel bodega) {
              return DropdownMenuItem<String>(
                value: bodega.bodeDescripcion,
                child: Text(
                  bodega.bodeDescripcion!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
      onChanged: (newValue) {
        setState(() {
          if (esProyecto) {
            flete.boatId = proyectos
                .firstWhere((proyecto) => proyecto.proyNombre == newValue)
                .proyId;
          } else {
            final selectedBodega = bodegas
                .firstWhere((bodega) => bodega.bodeDescripcion == newValue);
            if (selectedBodega.bodeId == flete.bollId) {
              _mostrarDialogoError('Error',
                  'La bodega de llegada no puede ser la misma que la de salida.');
            } else {
              flete.boatId = selectedBodega.bodeId;
            }
          }
        });
      },
      dropdownColor: Colors.black,
      style: TextStyle(color: Colors.white),
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
            if (textEditingValue.text.isEmpty) {
              return empleados.isNotEmpty ? empleados : [];
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
