import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:sigesproc_app/models/fletes/fletedetalleviewmodel.dart';
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/actividadesporetapaviewmodel.dart';
import 'package:sigesproc_app/screens/fletes/flete.dart';
import 'package:sigesproc_app/services/fletes/fletedetalleservice.dart';
import 'package:sigesproc_app/services/fletes/fleteencabezadoservice.dart';
import 'package:sigesproc_app/services/proyectos/actividadesporetapaservice.dart';
import 'package:sigesproc_app/models/generales/empleadoviewmodel.dart';
import 'package:sigesproc_app/models/insumos/bodegaviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/proyectoviewmodel.dart';
import 'package:sigesproc_app/models/insumos/insumoporproveedorviewmodel.dart';
import 'package:sigesproc_app/services/generales/empleadoservice.dart';
import 'package:sigesproc_app/services/insumos/bodegaservice.dart';
import 'package:sigesproc_app/services/proyectos/proyectoservice.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class EditarFlete extends StatefulWidget {
  final int flenId;

  EditarFlete({required this.flenId});

  @override
  _EditarFleteState createState() => _EditarFleteState();
}

class _EditarFleteState extends State<EditarFlete> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  DateTime? establishedDate;
  TimeOfDay? establishedTime;
  bool esProyecto = false;
  bool _showInsumos = false;
  bool _desabilitartextbox = false;
  List<EmpleadoViewModel> empleados = [];
  List<BodegaViewModel> bodegas = [];
  List<ProyectoViewModel> proyectos = [];
  List<ActividadPorEtapaViewModel> actividades = [];
  List<InsumoPorProveedorViewModel> insumos = [];
  List<InsumoPorProveedorViewModel> selectedInsumos = [];
  List<int> selectedCantidades = [];
  String? selectedBodegaLlegada;
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
  TextEditingController llegadaController = TextEditingController();
  TextEditingController actividadController = TextEditingController();
  List<TextEditingController> quantityControllers = [];
  TextEditingController encargadoController = TextEditingController();
  TextEditingController supervisorSalidaController = TextEditingController();
  TextEditingController supervisorLlegadaController = TextEditingController();
  TextEditingController salidaController = TextEditingController();
  late StreamSubscription<bool> keyboardSubscription;
  bool _isKeyboardVisible = false;
  bool _isLoading = true;
  bool isEditing = false;

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
    _cargarDatosIniciales();
    var keyboardVisibilityController = KeyboardVisibilityController();
    _isKeyboardVisible = keyboardVisibilityController.isVisible;
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

  Future<void> _cargarDatosIniciales() async {
    setState(() {
      _isLoading = true; // Inicia el spinner
    });
    try {
      // Cargar los datos del flete
      FleteEncabezadoViewModel? fleteCargado =
          await FleteEncabezadoService.obtenerFleteDetalle(widget.flenId);
      if (fleteCargado != null) {
        flete = fleteCargado;
        isEditing = true;

        selectedDate = flete.flenFechaHoraSalida;
        selectedTime = TimeOfDay.fromDateTime(flete.flenFechaHoraSalida!);
        establishedDate = flete.flenFechaHoraEstablecidaDeLlegada;
        establishedTime =
            TimeOfDay.fromDateTime(flete.flenFechaHoraEstablecidaDeLlegada!);

        // Cargar el encargado
        if (flete.emtrId != null) {
          EmpleadoViewModel? encargado =
              await EmpleadoService.obtenerEmpleado(flete.emtrId!);
          print('Encargado: $encargado');
          if (encargado != null) {
            encargadoController.text = encargado.empleado!;
          }
        }

        // Cargar el supervisor de salida
        if (flete.emssId != null) {
          EmpleadoViewModel? supervisorSalida =
              await EmpleadoService.obtenerEmpleado(flete.emssId!);
          print('Supervisor Salida: $supervisorSalida');
          if (supervisorSalida != null) {
            supervisorSalidaController.text = supervisorSalida.empleado!;
          }
        }

        // Cargar el supervisor de llegada
        if (flete.emslId != null) {
          EmpleadoViewModel? supervisorLlegada =
              await EmpleadoService.obtenerEmpleado(flete.emslId!);
          print('Supervisor Llegada: $supervisorLlegada');
          if (supervisorLlegada != null) {
            supervisorLlegadaController.text = supervisorLlegada.empleado!;
          }
        }

        esProyecto = flete.flenDestinoProyecto ?? false;
        if (esProyecto) {
          ProyectoViewModel? proyectoSeleccionado =
              await ProyectoService.obtenerProyecto(flete.proyId!);
          if (proyectoSeleccionado != null) {
            llegadaController.text = proyectoSeleccionado.proyNombre!;

            List<ActividadPorEtapaViewModel> actividades =
                await ActividadPorEtapaService.obtenerActividadesPorProyecto(
                    flete.proyId!);

            if (actividades.isNotEmpty && flete.boatId != null) {
              ActividadPorEtapaViewModel etapaactividad = actividades
                  .firstWhere((actividad) => actividad.acetId == flete.boatId!,
                      orElse: () => ActividadPorEtapaViewModel(
                          etapDescripcion: '', actiDescripcion: ''));

              if (etapaactividad.etapDescripcion!.isNotEmpty) {
                actividadController.text = etapaactividad.etapDescripcion! +
                    ' - ' +
                    etapaactividad.actiDescripcion!;
              }

              setState(() {
                this.actividades = actividades;
              });
            }
          }
        } else {
          BodegaViewModel? llegada = await BodegaService.buscar(flete.boatId!);
          if (llegada != null) {
            llegadaController.text = llegada.bodeDescripcion!;
          }
        }

        // Cargar la bodega de salida
        if (flete.bollId != null) {
          BodegaViewModel? salida = await BodegaService.buscar(flete.bollId!);
          print('Bodega de Salida: $salida');
          if (salida != null) {
            salidaController.text = salida.bodeDescripcion!;
            _cargarInsumosPorBodega(flete.bollId!);
          }
        }

        if (flete.bollId != null) {
          List<InsumoPorProveedorViewModel> insumosList =
              await FleteDetalleService.listarInsumosPorProveedorPorBodega(
                  flete.bollId!);

          // Cargar los detalles de insumos ya seleccionados en el flete
          List<FleteDetalleViewModel> detallesCargados =
              await FleteDetalleService.Buscar(flete.flenId!);

          setState(() {
            selectedCantidades = [];
            quantityControllers = [];

            for (var insumo in insumosList) {
              // Buscar si el insumo ya está en los detalles del flete
              var detalle = detallesCargados.firstWhere(
                  (detalle) => detalle.inppId == insumo.inppId,
                  orElse: () => FleteDetalleViewModel());

              // Si el insumo está en los detalles, se selecciona y se asigna la cantidad
              if (detalle.fldeId != null) {
                var cantidad = detalle.fldeCantidad;
                print('cant $cantidad');
                selectedInsumos.add(insumo);
                quantityControllers
                    .add(TextEditingController(text: cantidad.toString()));
                selectedCantidades.add(cantidad!); // Añadir la cantidad real
              } else {
                // Insumo no seleccionado, pero se agrega a la lista
                quantityControllers.add(TextEditingController(text: '1'));
                selectedCantidades.add(1); // Añadir cantidad por defecto (1)
              }
            }

            // Actualizar la lista de insumos a mostrar
            insumos = insumosList;
          });
        }
      }
    } catch (e) {
      print('Error al cargar los datos del flete: $e');
    } finally {
      setState(() {
        _isLoading =
            false; // Detiene el spinner cuando los datos estén cargados
      });
    }
  }

  Future<void> _cargarInsumosPorBodega(int bodeId) async {
    try {
      List<InsumoPorProveedorViewModel> insumosList =
          await FleteDetalleService.listarInsumosPorProveedorPorBodega(bodeId);
      setState(() {
        insumos = insumosList;
        quantityControllers = List.generate(
            insumos.length, (index) => TextEditingController(text: '1'));
        selectedCantidades = List.generate(insumos.length, (index) => 1);
      });
    } catch (e) {
      print('Error al cargar los insumos: $e');
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
      print('aaa $actividades');
      setState(() {
        actividadController
            .clear(); // Limpia la selección de actividades previas
      });
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
                suffixIcon: IconButton(
                  icon: Icon(Icons.arrow_drop_down, color: Color(0xFFFFF0C6)),
                  onPressed: () {
                    if (focusNode.hasFocus) {
                      focusNode.unfocus();
                    } else {
                      focusNode.requestFocus();
                    }
                  },
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<ProyectoViewModel>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return proyectos; // Mostrar todas las opciones cuando el campo está vacío
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
                labelText: 'Proyecto de Llegada',
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
                suffixIcon: IconButton(
                  icon: Icon(Icons.arrow_drop_down, color: Color(0xFFFFF0C6)),
                  onPressed: () {
                    if (focusNode.hasFocus) {
                      focusNode.unfocus();
                    } else {
                      focusNode.requestFocus();
                    }
                  },
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
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: options.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      final ProyectoViewModel option = options.elementAt(index);
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
          onSelected: (ProyectoViewModel selection) {
            setState(() {
              controller.text = selection.proyNombre!;
              _cargarActividadesPorProyecto(selection.proyId!);
              actividadController.clear();
              flete.boatId = null;
              _proyectoError = false;
              _proyectoErrorMessage = '';
            });
          },
        ),
        if (actividades.isNotEmpty) SizedBox(height: 20),
        if (actividades.isNotEmpty)
          _buildActividadAutocomplete(actividadController),
      ],
    );
  }

  Widget _buildActividadAutocomplete(TextEditingController controller) {
    return Autocomplete<ActividadPorEtapaViewModel>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        // Si estamos en modo de edición, mostrar la actividad preseleccionada
        if (textEditingValue.text.isEmpty &&
            isEditing &&
            flete.boatId != null) {
          return actividades.where((ActividadPorEtapaViewModel option) {
            return option.acetId == flete.boatId;
          });
        }

        // Mostrar las actividades que coincidan con el texto ingresado
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
        // Si estamos en modo de edición y la actividad está seleccionada, mostrarla
        if (isEditing &&
            textEditingController.text.isEmpty &&
            flete.boatId != null) {
          final selectedActivity = actividades.firstWhere(
            (actividad) => actividad.acetId == flete.boatId,
            orElse: () => ActividadPorEtapaViewModel(
                etapDescripcion: '', actiDescripcion: ''),
          );

          textEditingController.text = selectedActivity.etapDescripcion! +
              ' - ' +
              selectedActivity.actiDescripcion!;
        }

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
            suffixIcon: IconButton(
              icon: Icon(Icons.arrow_drop_down, color: Color(0xFFFFF0C6)),
              onPressed: () {
                if (fieldFocusNode.hasFocus) {
                  fieldFocusNode.unfocus();
                } else {
                  fieldFocusNode.requestFocus();
                }
              },
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
              child: ListView.builder(
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

      if (flete.flenFechaHoraSalida == null) {
        _fechaSalidaError = true;
        _fechaSalidaErrorMessage = 'La fecha de salida no puede estar vacía';
      }

      if (flete.flenFechaHoraEstablecidaDeLlegada == null) {
        _fechaHoraEstablecidaError = true;
        _fechaHoraEstablecidaErrorMessage =
            'La fecha de llegada no puede estar vacía';
      } else if (flete.flenFechaHoraSalida != null &&
          flete.flenFechaHoraSalida!
              .isAfter(flete.flenFechaHoraEstablecidaDeLlegada!)) {
        _fechaHoraEstablecidaError = true;
        _fechaHoraEstablecidaErrorMessage =
            'La fecha de salida no puede ser posterior a la de llegada.';
      } else if (flete.flenFechaHoraEstablecidaDeLlegada!
              .difference(flete.flenFechaHoraSalida!)
              .inMinutes <
          5) {
        _fechaHoraEstablecidaError = true;
        _fechaHoraEstablecidaErrorMessage =
            'Debe haber al menos 5 minutos de diferencia entre salida y llegada.';
      }

      if (flete.emtrId == null) {
        _isEmpleadoError = true;
        _empleadoErrorMessage = 'El encargado no puede estar vacío';
      }
      if (flete.emssId == null) {
        _isSupervisorSalidaError = true;
        _supervisorSalidaErrorMessage =
            'El supervisor de salida no puede estar vacío';
      }
      if (flete.emslId == null) {
        _isSupervisorLlegadaError = true;
        _supervisorLlegadaErrorMessage =
            'El supervisor de llegada no puede estar vacío';
      }
      if (flete.emtrId == flete.emssId && flete.emtrId != null) {
        _isSupervisorSalidaError = true;
        _supervisorSalidaErrorMessage =
            'El supervisor de salida debe ser diferente al encargado';
      }
      if (flete.emtrId == flete.emslId && flete.emtrId != null) {
        _isSupervisorLlegadaError = true;
        _supervisorLlegadaErrorMessage =
            'El supervisor de llegada debe ser diferente al encargado';
      }
      if (flete.emssId == flete.emslId && flete.emssId != null) {
        _isSupervisorLlegadaError = true;
        _supervisorLlegadaErrorMessage =
            'El supervisor de llegada debe ser diferente al de salida';
      }
      if (flete.emtrId == flete.emssId &&
          flete.emssId == flete.emslId &&
          flete.emtrId != null &&
          flete.emssId != null) {
        _isSupervisorLlegadaError = true;
        _supervisorLlegadaErrorMessage =
            'Los supervisores deben ser diferentes';
      }

      if (flete.bollId == null) {
        _ubicacionSalidaError = true;
        _ubicacionSalidaErrorMessage =
            'La ubicación de salida no puede estar vacía';
      }
      if (esProyecto && flete.boatId == null) {
        _proyectoError = true;
        _proyectoErrorMessage = 'Debe seleccionar un proyecto';
      } else if (!esProyecto && flete.boatId == null) {
        _ubicacionLlegadaError = true;
        _ubicacionLlegadaErrorMessage =
            'La ubicación de llegada no puede estar vacía';
      } else if (flete.bollId == flete.boatId && !esProyecto) {
        _ubicacionLlegadaError = true;
        _ubicacionLlegadaErrorMessage =
            'Las ubicaciones de salida y llegada no pueden ser la misma bodega.';
      }

      if (esProyecto && actividades.isNotEmpty && flete.boatId == null) {
        _actividadError = true;
        _actividadErrorMessage = 'Debe seleccionar una actividad por etapa';
      }

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

      _showInsumosView();
    });
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
                _showInsumos ? 'Seleccionar Insumos' : 'Editar Flete',
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
      body: _isLoading
          ? Container(
              color: Colors.black,
              child: Center(
                child: SpinKitCircle(color: Color(0xFFFFF0C6)),
              ),
            )
          : Container(
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

  Future<void> editarFlete() async {
    try {
      flete.usuaModificacion = 3;
      flete.usuaCreacion = 3;
      flete.flenFechaHoraLlegada = null;

      print('Flete data: ${flete.toJson()}');

      // Verificar que no haya insumos seleccionados con cantidad 0 o vacía
      bool hayCantidadesInvalidas = false;
      for (int i = 0; i < selectedInsumos.length; i++) {
        int? stock = selectedInsumos[i].bopiStock;
        int? cantidad = int.tryParse(quantityControllers[i].text);

        if (cantidad == null || cantidad <= 0) {
          print(
              'Cantidad inválida para insumo ${selectedInsumos[i].insuDescripcion}: $cantidad');
          quantityControllers[i].text = '1';
          selectedCantidades[i] = 1;
          hayCantidadesInvalidas = true;
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

      if (hayCantidadesInvalidas) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Cantidades ajustadas. Por favor, revise las cantidades.')),
        );
        return;
      }

      if (selectedInsumos.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Debe seleccionar al menos un insumo')),
        );
        return;
      }

      final int? newId = widget.flenId;
      if (newId != null) {
        print('New Flete ID: $newId');

        // Obtener los detalles existentes para verificar cambios
        final detallesExistentes =
            await FleteDetalleService.listarDetallesdeFlete(newId);

        // Insertar o actualizar detalles
       for (int i = 0; i < selectedInsumos.length; i++) {
  final detalleExistente = detallesExistentes.firstWhere(
    (detalle) => detalle.inppId == selectedInsumos[i].inppId,
    orElse: () => FleteDetalleViewModel(), // Crear un objeto vacío
  );

  final detalle = FleteDetalleViewModel(
    fldeId: detalleExistente.fldeId,  // Solo se pasa si existe, en caso de creación será null
    fldeCantidad: selectedCantidades[i],
    fldeTipodeCarga: true,
    flenId: newId,
    inppId: selectedInsumos[i].inppId,
    usuaModificacion: 3,
    usuaCreacion: 3,
  );

  if (detalleExistente.fldeId != null) {
    // Actualizar detalle existente
    await FleteDetalleService.editarFleteDetalle(detalle);
  } else {
    // Insertar nuevo detalle
    await FleteDetalleService.insertarFleteDetalle(detalle);
  }
}


        // Eliminar insumos que fueron desmarcados
        for (var detalle in detallesExistentes) {
          final insumoCorrespondiente = selectedInsumos.firstWhere(
            (insumo) => insumo.inppId == detalle.inppId,
            orElse: () =>
                InsumoPorProveedorViewModel(inppId: 0), // Crear un objeto vacío
          );

          if (insumoCorrespondiente == null) {
            await FleteDetalleService.Eliminar(detalle.fldeId!);
          }
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
    } catch (e) {
      print('Error al editar el flete: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error al editar el flete')),
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
                  Text('Fecha y Hora',
                      style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 18)),
                  SizedBox(height: 10),
                  _fechaSalida(),
                  SizedBox(height: 20),
                  _fechaHoraEstablecida(),
                  SizedBox(height: 20),
                  Text('Empleados',
                      style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 18)),
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
                  Text('Ubicaciones',
                      style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 18)),
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
                      Text('Insumos',
                          style: TextStyle(
                              color: Color(0xFFFFF0C6), fontSize: 18)),
                      FloatingActionButton(
                        onPressed: _validarCamposYMostrarInsumos,
                        backgroundColor: Color(0xFFFFF0C6),
                        mini: true,
                        child:
                            Icon(Icons.add_circle_outline, color: Colors.black),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildInsumosView() {
    final empleado = empleados.firstWhere(
      (emp) => emp.emplId == flete.emssId,
      orElse: () => EmpleadoViewModel(),
    );
    print('emple $empleado');

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
                  textAlign: TextAlign.center),
              Text(
                  'Flete del ${DateFormat('EEE d MMM, hh:mm a').format(flete.flenFechaHoraSalida ?? DateTime.now())}',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ListView.builder(
              itemCount: insumos.length,
              itemBuilder: (context, index) {
                int? stock = insumos[index].bopiStock;
                int cantidad = selectedCantidades.length > index
                    ? selectedCantidades[index]
                    : 0;
                bool cantidadExcedida = cantidad > (stock ?? 0);

                return ListTile(
                  title: Text('${insumos[index].insuDescripcion ?? ''}',
                      style: TextStyle(color: Colors.white)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Material: ${insumos[index].mateDescripcion}',
                          style: TextStyle(color: Colors.white70)),
                      Text('Unidad: ${insumos[index].unmeNombre}',
                          style: TextStyle(color: Colors.white70)),
                      Text('Stock: ${insumos[index].bopiStock}',
                          style: TextStyle(color: Colors.white70)),
                      if (selectedInsumos.contains(insumos[index]))
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
                                    if (cantidad != null && cantidad > stock!) {
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
                            style: TextStyle(color: Colors.red, fontSize: 12)),
                    ],
                  ),
                  trailing: Checkbox(
                    value: selectedInsumos.contains(insumos[index]),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedInsumos.add(insumos[index]);
                          if (selectedCantidades.length <= index) {
                            selectedCantidades[index] = 1;
                            quantityControllers[index].text = '1';
                          } else {
                            selectedCantidades[index] = 1;
                            quantityControllers[index].text = '1';
                          }
                        } else {
                          int removeIndex =
                              selectedInsumos.indexOf(insumos[index]);
                          selectedInsumos.removeAt(removeIndex);
                          selectedCantidades[removeIndex] = 0;
                          quantityControllers[removeIndex].text = '';
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
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
                  context, MaterialPageRoute(builder: (context) => Flete()));
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
            onPressed: editarFlete,
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
              print('empleados $empleados');
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
