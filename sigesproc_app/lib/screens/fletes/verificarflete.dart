import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/screens/menu.dart';
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
          ),
          body: _isLoading
              ? Center(child: SpinKitCircle(color: Color(0xFFFFF0C6)))
              : SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      // Sección de Fecha y Hora de Llegada
                      Padding(
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
                      ),
                      // Expanded con los tabs
                      Column(
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
                            height: MediaQuery.of(context).size.height *
                                0.6, // Limitar la altura para evitar problemas con el teclado
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildScrollableInsumosTab(),
                                _buildScrollableEquiposTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
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
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        );
      },
    );
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

void _onCheckboxChanged(
    bool? value, FleteDetalleViewModel item, bool isInsumo) {
  print(
      "Checkbox cambiado para el item: ${item.insuDescripcion ?? item.equsNombre}, nuevo valor: $value");

  setState(() {
    item.verificado = value;

    if (value == true) {
      print("Checkbox marcado, moviendo a la lista de verificados");

      // Seleccionar la lista adecuada según si es Insumo o Equipo
      List<FleteDetalleViewModel> verifiedList = isInsumo ? insumosVerificados : equiposVerificados;
      List<FleteDetalleViewModel> notReceivedList = isInsumo ? insumosNoRecibidos : equiposNoRecibidos;

      // Buscar si ya existe en Verificados
      var existingVerified = verifiedList.firstWhere(
        (i) => isInsumo ? i.insuDescripcion == item.insuDescripcion : i.equsNombre == item.equsNombre,
        orElse: () {
          print("No se encontró un item verificado existente, creando uno nuevo");
          return FleteDetalleViewModel(fldeId: -1);
        },
      );

      if (existingVerified.fldeId != -1) {
        // Sumar cantidades si ya existe en Verificados
        print("Item encontrado en la lista de verificados, sumando cantidades");
        print(
            "Cantidad existente: ${existingVerified.cantidadRecibida}, Suma: ${item.fldeCantidad}");
        existingVerified.cantidadRecibida =
            (existingVerified.cantidadRecibida ?? 0) +
                (item.fldeCantidad ?? 0);
        print(
            "Nueva cantidad en verificados: ${existingVerified.cantidadRecibida}");

        // Actualizar el controlador del TextField
        _textControllers[existingVerified.fldeId]!.text =
            existingVerified.cantidadRecibida.toString();

        // Eliminar de No Recibidos
        print("Eliminando item de la lista de No Recibidos");
        notReceivedList.remove(item);
      } else {
        // Mover a Verificados si no existe
        print("Moviendo item a la lista de verificados");
        notReceivedList.remove(item);
        verifiedList.add(item);

        // Inicializar el controlador del TextField si no existe
        if (!_textControllers.containsKey(item.fldeId)) {
          _textControllers[item.fldeId!] = TextEditingController(
            text: item.cantidadRecibida?.toString() ??
                item.fldeCantidad?.toString(),
          );
        }
      }
    } else {
      print("Checkbox desmarcado, moviendo a la lista de no recibidos");

      // Moviendo de Verificados a No Recibidos
      List<FleteDetalleViewModel> verifiedList = isInsumo ? insumosVerificados : equiposVerificados;
      List<FleteDetalleViewModel> notReceivedList = isInsumo ? insumosNoRecibidos : equiposNoRecibidos;

      var existingNotReceived = notReceivedList.firstWhere(
        (i) => isInsumo ? i.insuDescripcion == item.insuDescripcion : i.equsNombre == item.equsNombre,
        orElse: () {
          print("No se encontró un item en no recibidos, creando uno nuevo");
          return FleteDetalleViewModel(fldeId: -1);
        },
      );

      if (existingNotReceived.fldeId != -1) {
        // Sumar cantidades si ya existe en No Recibidos
        print("Item encontrado en la lista de No Recibidos, sumando cantidades");
        print(
            "Cantidad existente: ${existingNotReceived.fldeCantidad}, Suma: ${item.cantidadRecibida}");
        existingNotReceived.fldeCantidad =
            (existingNotReceived.fldeCantidad ?? 0) +
                (item.cantidadRecibida ?? 0);
        print(
            "Nueva cantidad en No Recibidos: ${existingNotReceived.fldeCantidad}");

        verifiedList.remove(item);
      } else {
        // Mover a No Recibidos si no existe
        print("Moviendo item a la lista de No Recibidos");
        verifiedList.remove(item);
        notReceivedList.add(item);
      }
    }

  });
}


  void _onCantidadChanged(
    String value, FleteDetalleViewModel item, bool isInsumo) {
  print(
      "Cantidad cambiada para el item: ${item.insuDescripcion ?? item.equsNombre}, nuevo valor: $value");

  setState(() {
    int cantidadIngresada = int.tryParse(value) ?? 0;
    int cantidadOriginal = item.fldeCantidad!;
    item.cantidadRecibida = cantidadIngresada;

    print(
        "Cantidad ingresada: $cantidadIngresada, Cantidad original: $cantidadOriginal");

    List<FleteDetalleViewModel> noRecibidosList = isInsumo ? insumosNoRecibidos : equiposNoRecibidos;

    if (cantidadIngresada < cantidadOriginal) {
      int cantidadRestante = cantidadOriginal - cantidadIngresada;
      print("Cantidad restante: $cantidadRestante");

      FleteDetalleViewModel existente = noRecibidosList.firstWhere(
        (e) => isInsumo ? e.insuDescripcion == item.insuDescripcion : e.equsNombre == item.equsNombre,
        orElse: () {
          print(
              "No se encontró un item existente en No Recibidos, se creará uno nuevo");
          return FleteDetalleViewModel(fldeId: -1);
        },
      );

      if (existente.fldeId != -1) {
        // Actualizar cantidad si ya existe
        print("Item existente encontrado en No Recibidos, actualizando cantidad");
        existente.fldeCantidad = cantidadRestante;
        print("Cantidad actualizada en No Recibidos: ${existente.fldeCantidad}");
      } else {
        // Crear nuevo registro en No Recibidos
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
      // Si la cantidad verificada completa, eliminar de No Recibidos
      print("Cantidad completa recibida, eliminando de No Recibidos");
      noRecibidosList.removeWhere(
          (e) => isInsumo ? e.insuDescripcion == item.insuDescripcion : e.equsNombre == item.equsNombre);
    }

    print("Lista actual de No Recibidos: $noRecibidosList");
    print("Lista actual de Verificados: ${isInsumo ? insumosVerificados : equiposVerificados}");
  });
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
                            focusNode: _focusNode,
                            controller: _textControllers[itemId],
                            style: TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
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
                              _focusNodes.forEach((key, focusNode) {
                                if (key != itemId) {
                                  focusNode.unfocus();
                                }
                              });
                              _focusNodes[itemId]!.requestFocus();
                              _scrollToFocusedItem();
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

  Future<void> _guardarCambios() async {
    for (var item in insumosVerificados) {
      // await FleteDetalleService.Actualizar(item);
    }
    for (var item in equiposVerificados) {
      // await FleteDetalleService.Actualizar(item);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Datos guardados exitosamente')),
    );
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
            _scrollController.position.pixels +
                190, // Ajusta según sea necesario
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFF0C6),
              padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              await _guardarCambios();
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
        ],
      ),
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
      controller: TextEditingController(
        text: fechaHoraLlegada != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(fechaHoraLlegada!)
            : '',
      ),
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
        });
      }
    }
  }
}
