import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sigesproc_app/models/fletes/fletecontrolcalidadviewmodel.dart';
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/screens/fletes/flete.dart';
import 'package:sigesproc_app/screens/menu.dart';
import 'package:sigesproc_app/services/fletes/fletecontrolcalidadservice.dart';
import 'package:sigesproc_app/services/fletes/fletedetalleservice.dart';
import 'package:sigesproc_app/models/fletes/fletedetalleviewmodel.dart';
import 'package:sigesproc_app/services/fletes/fleteencabezadoservice.dart';
import 'package:intl/intl.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class VerificarFlete extends StatefulWidget {
  final int flenId;

  VerificarFlete({required this.flenId});

  @override
  _VerificarFleteState createState() => _VerificarFleteState();
}

class _VerificarFleteState extends State<VerificarFlete>
    with SingleTickerProviderStateMixin {
  DateTime? fechaHoraLlegada;
  TextEditingController _fechaHoraController = TextEditingController();

  List<FleteDetalleViewModel> insumosNoRecibidos = [];
  List<FleteDetalleViewModel> insumosVerificados = [];
  List<FleteDetalleViewModel> equiposNoRecibidos = [];
  List<FleteDetalleViewModel> equiposVerificados = [];

  ScrollController _scrollController = ScrollController();
  FocusNode _focusNode = FocusNode();
  TabController? _tabController;
  int _selectedIndex = 2;

  bool _isLoading = true;
  bool _isKeyboardVisible = false;

  bool _fechaLlegadaError = false;
  String _fechaLlegadaErrorMessage = '';
  TextEditingController _descripcionIncidenciaController =
      TextEditingController();
  TextEditingController _fechaHoraIncidenciaController =
      TextEditingController();
  bool _descripcionError = false;
  String _descripcionErrorMessage = '';
  bool _fechaHoraIncidenciaError = false;
  String _fechaHoraIncidenciaErrorMessage = '';

  bool _mostrarFormularioIncidencia = false;

  final Map<int, TextEditingController> _textControllers = {};
  Map<int, FocusNode> _focusNodes = {};

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
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatosFlete();

    var keyboardVisibilityController = KeyboardVisibilityController();
    keyboardVisibilityController.onChange.listen((bool visible) {
      setState(() {
        _isKeyboardVisible = visible;
      });
    });
  }

  @override
  void dispose() {
    _fechaHoraController.dispose();
    _descripcionIncidenciaController.dispose();
    _fechaHoraIncidenciaController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _cargarDatosFlete() async {
    print('Cargando datos del flete...');
    // Cargar el encabezado del flete
    flete = (await FleteEncabezadoService.obtenerFleteDetalle(widget.flenId))!;

    // Cargar los detalles del flete
    List<FleteDetalleViewModel> detalles =
        await FleteDetalleService.Buscar(widget.flenId);

    // Separar los insumos y equipos en listas diferentes
    setState(() {
      insumosNoRecibidos = detalles
          .where((detalle) =>
              detalle.fldeTipodeCarga == true &&
              (detalle.cantidadRecibida == null ||
                  detalle.cantidadRecibida! < detalle.fldeCantidad!))
          .toList();

      equiposNoRecibidos = detalles
          .where((detalle) =>
              detalle.fldeTipodeCarga == false &&
              (detalle.cantidadRecibida == null ||
                  detalle.cantidadRecibida! < detalle.fldeCantidad!))
          .toList();

      _isLoading = false; // Datos cargados
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: _buildAppBar(),
          body: _isLoading
              ? Center(child: SpinKitCircle(color: Color(0xFFFFF0C6)))
              : SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      _buildFechaHoraLlegadaCard(),
                      _buildTabSection(),
                      if (_mostrarFormularioIncidencia)
                        _buildNuevaIncidenciaCard(),
                    ],
                  ),
                ),
          bottomNavigationBar: Padding(
            padding: isKeyboardVisible
                ? EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom)
                : EdgeInsets.zero,
            child: _buildBottomButtons(),
          ),
          drawer: MenuLateral(
            selectedIndex: _selectedIndex,
            onItemSelected: _onItemTapped,
          ),
        );
      },
    );
  }

  // AppBar
  AppBar _buildAppBar() {
    return AppBar(
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
    );
  }

  Widget _buildFechaHoraLlegadaCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
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
    );
  }

  Widget _buildTabSection() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: Color(0xFFFFF0C6),
          tabs: [
            Tab(text: 'Insumos'),
            Tab(text: 'Equipos de Seguridad'),
          ],
          labelColor: Color(0xFFFFF0C6),
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.6,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildScrollableInsumosTab(),
              _buildScrollableEquiposTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNuevaIncidenciaCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF171717),
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nueva Incidencia Flete',
              style: TextStyle(
                color: Color(0xFFFFF0C6),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _descripcionIncidenciaController,
              decoration: InputDecoration(
                labelText: 'Descripción de la Incidencia',
                errorText: _descripcionError ? _descripcionErrorMessage : null,
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black,
                labelStyle: TextStyle(color: Colors.white),
                errorStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _fechaHoraIncidenciaController,
              readOnly: true,
              onTap: _seleccionarFechaHoraIncidencia,
              decoration: InputDecoration(
                labelText: 'Fecha y Hora de la Incidencia',
                errorText: _fechaHoraIncidenciaError
                    ? _fechaHoraIncidenciaErrorMessage
                    : null,
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.black,
                suffixIcon:
                    Icon(Icons.calendar_today, color: Color(0xFFFFF0C6)),
                labelStyle: TextStyle(color: Colors.white),
                errorStyle: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            _buildIncidenciaFormButtons(),
          ],
        ),
      ),
    );
  }

  Future<void> _seleccionarFechaHoraIncidencia() async {
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
          DateTime fechaHoraIncidencia = DateTime(
            fechaSeleccionada.year,
            fechaSeleccionada.month,
            fechaSeleccionada.day,
            horaSeleccionada.hour,
            horaSeleccionada.minute,
          );

          if (fechaHoraIncidencia.isBefore(flete.flenFechaHoraLlegada!)) {
            _fechaHoraIncidenciaError = true;
            _fechaHoraIncidenciaErrorMessage =
                'La fecha de la incidencia no puede ser anterior a la fecha de llegada.';
          } else {
            _fechaHoraIncidenciaError = false;
            _fechaHoraIncidenciaErrorMessage = '';
            _fechaHoraIncidenciaController.text =
                DateFormat('dd/MM/yyyy HH:mm').format(fechaHoraIncidencia);
          }
        });
      }
    }
  }

  Widget _buildScrollableInsumosTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTablaNoRecibidos(insumosNoRecibidos, true),
          _buildTablaVerificados(insumosVerificados, true),
        ],
      ),
    );
  }

  Widget _buildScrollableEquiposTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTablaNoRecibidos(equiposNoRecibidos, false),
          _buildTablaVerificados(equiposVerificados, false),
        ],
      ),
    );
  }

  Widget _buildTablaNoRecibidos(
      List<FleteDetalleViewModel> items, bool isInsumo) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isInsumo ? 'Insumos No Recibidos' : 'Equipos No Recibidos',
            style: TextStyle(
              color: Color(0xFFFFF0C6),
              fontSize: 18,
            ),
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildTable(items, isInsumo),
          ),
        ],
      ),
    );
  }

  Widget _buildTablaVerificados(
      List<FleteDetalleViewModel> items, bool isInsumo) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isInsumo ? 'Insumos Verificados' : 'Equipos Verificados',
            style: TextStyle(
              color: Color(0xFFFFF0C6),
              fontSize: 18,
            ),
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _buildTable(items, isInsumo),
          ),
        ],
      ),
    );
  }

  void _onCheckboxChanged(bool? value, FleteDetalleViewModel item, bool isInsumo) {
  print("Checkbox cambiado para el item: ${item.insuDescripcion ?? item.equsNombre}, nuevo valor: $value");

  setState(() {
    item.verificado = value;

    List<FleteDetalleViewModel> verifiedList = isInsumo ? insumosVerificados : equiposVerificados;
    List<FleteDetalleViewModel> notReceivedList = isInsumo ? insumosNoRecibidos : equiposNoRecibidos;

    if (value == true) {
      print("Checkbox marcado, moviendo a la lista de verificados");

      var existingVerified = verifiedList.firstWhere(
        (i) => isInsumo
            ? i.insuDescripcion == item.insuDescripcion
            : i.equsNombre == item.equsNombre,
        orElse: () {
          print("No se encontró un item verificado existente, creando uno nuevo");
          return FleteDetalleViewModel(fldeId: -1);
        },
      );

      if (existingVerified.fldeId != -1) {
        print("Item encontrado en la lista de verificados, sumando cantidades");
        existingVerified.cantidadRecibida =
            (existingVerified.cantidadRecibida ?? 0) +
                (item.fldeCantidad ?? 0);
        _textControllers[existingVerified.fldeId]!.text =
            existingVerified.cantidadRecibida.toString();
        notReceivedList.remove(item);
      } else {
        print("Moviendo item a la lista de verificados");
        notReceivedList.remove(item);
        verifiedList.add(item);

        if (!_textControllers.containsKey(item.fldeId)) {
          _textControllers[item.fldeId!] = TextEditingController(
            text: item.cantidadRecibida?.toString() ??
                item.fldeCantidad?.toString(),
          );
        }
      }

      _enfocarYScroll(item.fldeId!);
    } else {
      print("Checkbox desmarcado, moviendo a la lista de no recibidos");

      var existingNotReceived = notReceivedList.firstWhere(
        (i) => isInsumo
            ? i.insuDescripcion == item.insuDescripcion
            : i.equsNombre == item.equsNombre,
        orElse: () {
          print("No se encontró un item en no recibidos, creando uno nuevo");
          return FleteDetalleViewModel(fldeId: -1);
        },
      );

      if (existingNotReceived.fldeId != -1) {
        print("Item encontrado en la lista de No Recibidos, sumando cantidades");
        existingNotReceived.fldeCantidad =
            (existingNotReceived.fldeCantidad ?? 0) +
                (item.cantidadRecibida ?? 0);
        verifiedList.remove(item);
      } else {
        print("Moviendo item a la lista de No Recibidos");
        verifiedList.remove(item);
        notReceivedList.add(item);
      }
    }
  });
}

  void _onCantidadChanged(String value, FleteDetalleViewModel item, bool isInsumo) {
  print("Cantidad cambiada para el item: ${item.insuDescripcion ?? item.equsNombre}, nuevo valor: $value");

  setState(() {
    int cantidadIngresada = int.tryParse(value) ?? 0;
    print('Cantidad ingresada: $cantidadIngresada');
    int cantidadOriginal = item.fldeCantidad!;

    if (cantidadIngresada > cantidadOriginal) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('La cantidad no puede ser mayor que la cantidad original: $cantidadOriginal')),
      );
      cantidadIngresada = cantidadOriginal;
      _textControllers[item.fldeId]!.text = cantidadOriginal.toString();
    }

    item.cantidadRecibida = cantidadIngresada;  // Aquí se debe asegurar que se está asignando correctamente
    print("Después de cambiar la cantidad, item.cantidadRecibida: ${item.cantidadRecibida}");


      print(
          "Cantidad ingresada: $cantidadIngresada, Cantidad original: $cantidadOriginal");

      List<FleteDetalleViewModel> noRecibidosList =
          isInsumo ? insumosNoRecibidos : equiposNoRecibidos;

      if (cantidadIngresada < cantidadOriginal) {
        int cantidadRestante = cantidadOriginal - cantidadIngresada;
        print("Cantidad restante: $cantidadRestante");

        FleteDetalleViewModel existente = noRecibidosList.firstWhere(
          (e) => isInsumo
              ? e.insuDescripcion == item.insuDescripcion
              : e.equsNombre == item.equsNombre,
          orElse: () {
            print(
                "No se encontró un item existente en No Recibidos, se creará uno nuevo");
            return FleteDetalleViewModel(fldeId: -1);
          },
        );

        if (existente.fldeId != -1) {
          print(
              "Item existente encontrado en No Recibidos, actualizando cantidad");
          existente.fldeCantidad = cantidadRestante;
          print(
              "Cantidad actualizada en No Recibidos: ${existente.fldeCantidad}");
        } else {
          print("Creando nuevo item en No Recibidos");
          FleteDetalleViewModel restanteItem = FleteDetalleViewModel(
            codigo: item.codigo,
            fldeId: item.fldeId,
            fldeCantidad: cantidadRestante,
            fldeTipodeCarga: item.fldeTipodeCarga,
            flenId: item.flenId,
            insuDescripcion: item.insuDescripcion,
            equsNombre: item.equsNombre,
            unmeNomenclatura: item.unmeNomenclatura,
            verificado: false,
            insuId: item.insuId,
          );

          noRecibidosList.add(restanteItem);
          print("Nuevo item agregado a No Recibidos: $restanteItem");
        }
      } else {
        print("Cantidad completa recibida, eliminando de No Recibidos");
        noRecibidosList.removeWhere((e) => isInsumo
            ? e.insuDescripcion == item.insuDescripcion
            : e.equsNombre == item.equsNombre);
      }

      print("Lista actual de No Recibidos: $noRecibidosList");
      print(
          "Lista actual de Verificados: ${isInsumo ? insumosVerificados : equiposVerificados}");
    });
  }

  void _enfocarYScroll(int itemId) {
    _focusNodes.forEach((key, focusNode) {
      if (key != itemId) {
        focusNode.unfocus();
      }
    });
    _focusNodes[itemId]?.requestFocus();
    _scrollToFocusedItem();
  }

  Widget _buildTable(List<FleteDetalleViewModel> items, bool isInsumo) {
    List<DataRow> rows = items.isEmpty
        ? [
            DataRow(cells: [
              DataCell(Checkbox(value: false, onChanged: null)),
              DataCell(Container(
                width: MediaQuery.of(context).size.width * 0.2,
                child: Text(
                  '',
                  style: TextStyle(color: Colors.transparent),
                ),
              )),
              DataCell(Container(
                width: MediaQuery.of(context).size.width * 0.2,
                child: Text(
                  '',
                  style: TextStyle(color: Colors.transparent),
                ),
              )),
              DataCell(Container(
                width: MediaQuery.of(context).size.width * 0.1,
                child: Text(
                  '',
                  style: TextStyle(color: Colors.transparent),
                ),
              )),
            ])
          ]
        : items.map((item) {
            int itemId = item.fldeId!;
            if (!_textControllers.containsKey(itemId)) {
              _textControllers[itemId] = TextEditingController(
                text: item.cantidadRecibida?.toString() ??
                    item.fldeCantidad?.toString(),
              );
            }

            return DataRow(
              cells: [
                DataCell(
                  Checkbox(
                    value: item.verificado ?? false,
                    onChanged: (value) {
                      setState(() {
                        _onCheckboxChanged(value, item, isInsumo);
                      });
                    },
                  ),
                ),
                DataCell(
                  Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Text(
                      isInsumo
                          ? item.insuDescripcion ?? ''
                          : item.equsNombre ?? '',
                      style: TextStyle(color: Colors.white),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: Text(
                      isInsumo
                          ? item.unmeNomenclatura ?? ''
                          : item.equsDescripcion ?? '',
                      style: TextStyle(color: Colors.white),
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    width: MediaQuery.of(context).size.width * 0.1,
                    child: item.verificado == true
                        ? TextField(
                            focusNode: _focusNodes[itemId],
                            controller: _textControllers[itemId],
                            style: TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ], // Solo permite números
                            decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFFFFF0C6)),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFFFFF0C6)),
                              ),
                            ),
                            onChanged: (value) {
                              _onCantidadChanged(value, item, isInsumo);
                            },
                            onTap: () {
                              _enfocarYScroll(itemId);
                            },
                          )
                        : Text(
                            item.fldeCantidad?.toString() ?? '',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            );
          }).toList();

    return DataTable(
      headingRowColor:
          MaterialStateColor.resolveWith((states) => Color(0xFF171717)),
      columnSpacing: 13.0,
      horizontalMargin: 10.0,
      columns: [
        DataColumn(
          label: Text(
            '',
            style: TextStyle(
                color: Color(0xFFFFF0C6), fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            isInsumo ? 'Descripción' : 'Equipo',
            style: TextStyle(
                color: Color(0xFFFFF0C6), fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            isInsumo ? 'Unidad de Medida' : 'Descripción',
            style: TextStyle(
                color: Color(0xFFFFF0C6), fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Cantidad',
            style: TextStyle(
                color: Color(0xFFFFF0C6), fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: rows,
    );
  }

 Future<void> _verificarFlete() async {
  print("Iniciando verificación del flete...");
  
  flete.usuaModificacion = 3;
  flete.flenEstado = true;

  bool hayNoVerificados = false;
  bool hayErrores = false;
  bool hayErrorFecha = false;

  bool _validarCantidad(FleteDetalleViewModel item) {
    print("Validando cantidad para el item: ${item.insuDescripcion ?? item.equsNombre}");
    print("Cantidad recibida: ${item.cantidadRecibida}, Cantidad original: ${item.fldeCantidad}");

    if ((item.cantidadRecibida == null || item.cantidadRecibida == 0) &&
        flete.flenFechaHoraLlegada != null &&
        (insumosVerificados.isNotEmpty || equiposVerificados.isNotEmpty)) {
      item.cantidadRecibida = item.fldeCantidad;
      _textControllers[item.fldeId!]!.text = item.cantidadRecibida.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cantidad ajustada, no puede ser vacía')),
      );
      hayErrores = true;
      return false;
    }
    return true;
  }

  // Verificación de condiciones iniciales
  if (insumosVerificados.isEmpty && equiposVerificados.isEmpty) {
    print("Error: No hay insumos ni equipos verificados");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Es necesario seleccionar insumos o equipos de seguridad.')),
    );
    return;
  }

  if (flete.flenFechaHoraLlegada == null) {
    print("Error: Fecha de llegada es nula");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('La fecha de llegada no puede ser vacía.')),
    );
    _fechaLlegadaError = true;
    _fechaLlegadaErrorMessage = 'La fecha de llegada no puede estar vacía';
    hayErrorFecha = true;
    return;
  }

  // Validar Insumos Verificados
  for (var item in insumosVerificados) {
    print('Validando insumo verificado: ${item.insuDescripcion}');
    if (!_validarCantidad(item)) return;
  }

  // Validar Insumos No Recibidos
  for (var item in insumosNoRecibidos) {
    print('Validando insumo no recibido: ${item.insuDescripcion}');
    if (!_validarCantidad(item)) return;
  }

  // Validar Equipos Verificados
  for (var item in equiposVerificados) {
    print('Validando equipo verificado: ${item.equsNombre}');
    if (!_validarCantidad(item)) return;
  }

  // Validar Equipos No Recibidos
  for (var detalle in equiposNoRecibidos) {
    print('Validando equipo no recibido: ${detalle.equsNombre}');
    if (!_validarCantidad(detalle)) return;
  }

  // Si hay errores, no continuar con el guardado
  if (hayErrores) {
    print("Error: Hay errores en la validación de cantidades");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se puede guardar, revise las cantidades.')),
    );
    return;
  }

  // Guardar Insumos Verificados
  for (var item in insumosVerificados) {
    print('Guardando insumo verificado: ${item.insuDescripcion}');
    item.fldeLlegada = true;
    item.usuaModificacion = 3;
    await FleteDetalleService.editarFleteDetalle(item);
  }

  // Guardar Insumos No Recibidos
  for (var item in insumosNoRecibidos) {
    print('Guardando insumo no recibido: ${item.insuDescripcion}');
    if (item.cantidadRecibida! < item.fldeCantidad!) {
      var detalleNuevo = FleteDetalleViewModel(
        flenId: item.flenId,
        inppId: item.inppId,
        usuaCreacion: item.usuaCreacion,
        fldeFechaCreacion: item.fldeFechaCreacion,
        fldeCantidad: item.cantidadRecibida!,
        fldeTipodeCarga: item.fldeTipodeCarga,
        fldeLlegada: false,
        usuaModificacion: 3,
      );

      try {
        final resp = await FleteDetalleService.insertarFleteDetalle2(detalleNuevo);
        if (resp['success'] && resp['data'] != null && resp['data']['codeStatus'] != null) {
          var detalleInsertado = FleteDetalleViewModel(
            fldeId: resp['data']['codeStatus'],
            fldeCantidad: detalleNuevo.fldeCantidad,
            flenId: detalleNuevo.flenId,
            inppId: detalleNuevo.inppId,
            usuaCreacion: detalleNuevo.usuaCreacion,
            fldeFechaCreacion: detalleNuevo.fldeFechaCreacion,
            usuaModificacion: 3,
            fldeFechaModificacion: DateTime.now(),
            fldeLlegada: false,
            fldeTipodeCarga: detalleNuevo.fldeTipodeCarga,
          );

          await FleteDetalleService.editarFleteDetalle(detalleInsertado);
          hayNoVerificados = true;
        } else {
          throw Exception('Error al insertar detalle: Respuesta no exitosa o datos nulos');
        }
      } catch (e) {
        print('Error al insertar detalle: $e');
      }
    } else {
      item.fldeLlegada = false;
      item.usuaModificacion = 3;
      hayNoVerificados = true;
      await FleteDetalleService.editarFleteDetalle(item);
    }
  }

  // Guardar Equipos Verificados
  for (var item in equiposVerificados) {
    print('Guardando equipo verificado: ${item.equsNombre}');
    item.fldeLlegada = true;
    item.usuaModificacion = 3;
    await FleteDetalleService.editarFleteDetalle(item);
  }

  // Guardar Equipos No Recibidos
  for (var detalle in equiposNoRecibidos) {
    print('Guardando equipo no recibido: ${detalle.equsNombre}');
    if (detalle.cantidadRecibida! < detalle.fldeCantidad!) {
      var detalleNuevo = FleteDetalleViewModel(
        flenId: detalle.flenId,
        inppId: detalle.inppId,
        usuaCreacion: detalle.usuaCreacion,
        fldeFechaCreacion: detalle.fldeFechaCreacion,
        fldeCantidad: detalle.cantidadRecibida!,
        fldeTipodeCarga: detalle.fldeTipodeCarga,
        fldeLlegada: false,
        usuaModificacion: 3,
      );

      try {
        final resp = await FleteDetalleService.insertarFleteDetalle2(detalleNuevo);
        if (resp['success'] && resp['data'] != null && resp['data']['codeStatus'] != null) {
          var detalleInsertado = FleteDetalleViewModel(
            fldeId: resp['data']['codeStatus'],
            fldeCantidad: detalleNuevo.fldeCantidad,
            flenId: detalleNuevo.flenId,
            inppId: detalleNuevo.inppId,
            usuaCreacion: detalleNuevo.usuaCreacion,
            fldeFechaCreacion: detalleNuevo.fldeFechaCreacion,
            usuaModificacion: 3,
            fldeFechaModificacion: DateTime.now(),
            fldeLlegada: false,
            fldeTipodeCarga: detalleNuevo.fldeTipodeCarga,
          );

          await FleteDetalleService.editarFleteDetalle(detalleInsertado);
          hayNoVerificados = true;
        } else {
          throw Exception('Error al insertar detalle: Respuesta no exitosa o datos nulos');
        }
      } catch (e) {
        print('Error al insertar detalle: $e');
      }
    } else {
      detalle.fldeLlegada = false;
      detalle.usuaModificacion = 3;
      hayNoVerificados = true;
      await FleteDetalleService.editarFleteDetalle(detalle);
    }
  }

  if (hayNoVerificados) {
    print("Hay insumos o equipos no verificados. Mostrando formulario de incidencia.");
    setState(() {
      _mostrarFormularioIncidencia = true;
    });
  } else {
    try {
      await FleteEncabezadoService.editarFlete(flete);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos guardados exitosamente')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Flete(),
        ),
      );
    } catch (e) {
      print('Error al guardar el flete: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el flete')),
      );
    }
  }
  print("Verificación del flete completada.");
}

  Future<void> _guardarIncidencia() async {
    if (_descripcionIncidenciaController.text.isEmpty) {
      setState(() {
        _descripcionError = true;
        _descripcionErrorMessage = 'La descripción no puede estar vacía';
      });
      return;
    }

    if (_fechaHoraIncidenciaController.text.isEmpty) {
      setState(() {
        _fechaHoraIncidenciaError = true;
        _fechaHoraIncidenciaErrorMessage =
            'La fecha y hora no pueden estar vacías';
      });
      return;
    }

    try {
      final incidencia = FleteControlCalidadViewModel(
        flenId: flete.flenId!,
        flccDescripcionIncidencia: _descripcionIncidenciaController.text,
        flccFechaHoraIncidencia: DateFormat('dd/MM/yyyy HH:mm')
            .parse(_fechaHoraIncidenciaController.text),
        usuaCreacion: 3,
        usuaModificacion: 3,
      );

      bool resultado =
          await FleteControlCalidadService.insertarIncidencia(incidencia);

      if (resultado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incidencia guardada exitosamente')),
        );

        // Reiniciar el formulario y regresar a la vista de fletes
        setState(() {
          _mostrarFormularioIncidencia = false;
          _descripcionIncidenciaController.clear();
          _fechaHoraIncidenciaController.clear();
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Flete(),
          ),
        );
      }
    } catch (e) {
      print('Error al guardar la incidencia: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la incidencia')),
      );
    }
  }

  Widget _buildInsumosTab() {
    return Column(
      children: [
        _buildTablaNoRecibidos(insumosNoRecibidos, true),
        _buildTablaVerificados(insumosVerificados, true),
      ],
    );
  }

  Widget _buildEquiposTab() {
    return Column(
      children: [
        _buildTablaNoRecibidos(equiposNoRecibidos, false),
        _buildTablaVerificados(equiposVerificados, false),
      ],
    );
  }

  void _scrollToFocusedItem() {
    if (!_isKeyboardVisible) {
      // Solo desplaza la vista si el teclado no está visible
      Future.delayed(Duration(milliseconds: 300)).then((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.pixels + 190,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Widget _buildBottomButtons() {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 35.0, vertical: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFF0C6),
              padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              await _verificarFlete();
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF171717),
              padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
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
        ],
      ),
    );
  }

  // Botón Guardar y Cancelar del formulario de incidencia
  Widget _buildIncidenciaFormButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFFF0C6),
            padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            await _guardarIncidencia();
          },
          child: Text(
            'Guardar Incidencia',
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF171717),
            padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            setState(() {
              _mostrarFormularioIncidencia = false;
              _descripcionIncidenciaController.clear();
              _fechaHoraIncidenciaController.clear();
            });
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
      controller: _fechaHoraController, // Usa el controlador persistente aquí
    );
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
          flete.flenFechaHoraLlegada = DateTime(
            fechaSeleccionada.year,
            fechaSeleccionada.month,
            fechaSeleccionada.day,
            horaSeleccionada.hour,
            horaSeleccionada.minute,
          );

          // Actualiza el controlador con la fecha y hora seleccionadas
          _fechaHoraController.text = DateFormat('dd/MM/yyyy HH:mm')
              .format(flete.flenFechaHoraLlegada!);
        });
      }
    }
  }
}
