import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sigesproc_app/models/fletes/fletecontrolcalidadviewmodel.dart';
import 'package:sigesproc_app/models/fletes/fleteencabezadoviewmodel.dart';
import 'package:sigesproc_app/models/insumos/equipoporproveedorviewmodel.dart';
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
  List<PlatformFile> _uploadedImages = [];
  PlatformFile? comprobante;
  bool _descripcionError = false;
  String _descripcionErrorMessage = '';
  bool _fechaHoraIncidenciaError = false;
  String _fechaHoraIncidenciaErrorMessage = '';



  bool _mostrarFormularioIncidencia = false;
  Map<int, int> _cantidadesRecibidasTemp = {};

  final Map<int, TextEditingController> _textControllers = {};
  Map<int, FocusNode> _focusNodes = {};

  bool _mostrarErrores = false;

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
    // Cargar el encabezado del flete
    flete = (await FleteEncabezadoService.obtenerFleteDetalle(widget.flenId))!;

    // Cargar los detalles del flete
    List<FleteDetalleViewModel> detalles =
        await FleteDetalleService.Buscar(widget.flenId);

    // Cargar la lista de equipos
    List<EquipoPorProveedorViewModel> equiposLista =
        await FleteDetalleService.listarEquiposdeSeguridadPorBodega(
            flete.boasId!);

    // Filtrar y unir las listas de detalles y equipos
    equiposNoRecibidos = equiposLista.where((equipo) {
      var detalle = detalles.firstWhere(
        (detalle) =>
            detalle.fldeTipodeCarga == false && detalle.inppId == equipo.eqppId,
        orElse: () => FleteDetalleViewModel(fldeId: -1),
      );
      return detalle.fldeId != -1 &&
          (detalle.cantidadRecibida == null ||
              detalle.cantidadRecibida! < detalle.fldeCantidad!);
    }).map((equipo) {
      var detalle = detalles.firstWhere((detalle) =>
          detalle.fldeTipodeCarga == false && detalle.inppId == equipo.eqppId);
      return FleteDetalleViewModel(
        fldeId: detalle.fldeId,
        flenId: detalle.flenId,
        inppId: detalle.inppId,
        fldeCantidad: detalle.fldeCantidad,
        cantidadRecibida: detalle.cantidadRecibida,
        equsNombre: equipo.equsNombre,
        equsDescripcion: equipo.equsDescripcion,
        verificado: detalle.verificado,
        usuaCreacion: detalle.usuaCreacion,
        fldeFechaCreacion: detalle.fldeFechaCreacion,
        fldeTipodeCarga: detalle.fldeTipodeCarga,
      );
    }).toList();

    // Filtrar los insumos no recibidos
    insumosNoRecibidos = detalles
        .where((detalle) =>
            detalle.fldeTipodeCarga == true &&
            (detalle.cantidadRecibida == null ||
                detalle.cantidadRecibida! < detalle.fldeCantidad!))
        .toList();

    setState(() {
      _isLoading = false;
    });
  }

  void _seleccionarImagen() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        comprobante = result.files.first;
        _uploadedImages = [
          comprobante!
        ]; // Reemplaza la lista anterior con la nueva imagen
      });
      print('Imagen seleccionada: ${comprobante!.name}');
    } else {
      setState(() {
        comprobante = null;
      });
      print('No se seleccionó ninguna imagen.');
    }
  }

  void _removeImage() {
    setState(() {
      _uploadedImages.clear();
      comprobante = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black,
          appBar: _buildAppBar(),
          body: _isLoading
              ? Center(child: SpinKitCircle(color: Color(0xFFFFF0C6)))
              : SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      if (!_mostrarFormularioIncidencia) ...[
                        _buildFechaHoraLlegadaCard(),
                        _buildTabSection(),
                      ],
                      if (_mostrarFormularioIncidencia) ...[
                        _buildNuevaIncidenciaCard(),
                        _buildIncidenciasTable(),
                      ],
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
            _buildFechaHoraLlegadaInput(
                showError: _mostrarErrores && _fechaHoraController.text.isEmpty,
                errorMessage: 'El campo es requerido.'),
            SizedBox(height: 20),
            Center(
              child: _buildSubirImagenButton(),
            ),
            SizedBox(height: 20),
            if (_uploadedImages.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  height: 200.0,
                  enableInfiniteScroll: false,
                  viewportFraction: 0.8,
                  enlargeCenterPage: true,
                ),
                items: _uploadedImages.asMap().entries.map((entry) {
                  int index = entry.key;
                  PlatformFile file = entry.value;

                  return Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Color(0xFF222222),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child:
                              file.path != null && File(file.path!).existsSync()
                                  ? Image.file(
                                      File(file.path!),
                                      fit: BoxFit.cover,
                                      width: 1000.0,
                                    )
                                  : Center(
                                      child: Text(
                                        'No se pudo cargar la imagen',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () => _removeImage(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 189, 13, 0)
                                  .withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.all(5),
                            child: Icon(
                              Icons.delete_forever,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubirImagenButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFFF0C6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: _seleccionarImagen,
      child: Text(comprobante == null ? 'Subir Imagen' : 'Cambiar Imagen'),
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
            'Agregar Incidencia',
            style: TextStyle(
              color: Color(0xFFFFF0C6),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
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
              suffixIcon: Icon(Icons.calendar_today, color: Color(0xFFFFF0C6)),
              labelStyle: TextStyle(color: Colors.white),
              errorStyle: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end, 
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFF0C6),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                await _guardarIncidencia();
              },
                child: Text(
                  'Guardar',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(width: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF222222),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                setState(() {
                  // _mostrarFormularioIncidencia = false;
                  _descripcionIncidenciaController.clear();
                  _fechaHoraIncidenciaController.clear();
                });
                Navigator.pop(context);
              },
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildIncidenciasTable() {
    return FutureBuilder<List<FleteControlCalidadViewModel>>(
      future: FleteControlCalidadService.buscarIncidencias(
          flete.flenId!), // Obtener incidencias del flete actual
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SpinKitCircle(color: Color(0xFFFFF0C6)),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al cargar las incidencias',
              style: TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {

          return Center(
            child: Text(
              'No hay incidencias registradas',
              style: TextStyle(color: Colors.white),
            ),
          );
        } else {
          return Table(
            columnWidths: {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Color(0xFF171717),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'No.',
                      style: TextStyle(
                        color: Color(0xFFFFF0C6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Incidencia',
                      style: TextStyle(
                        color: Color(0xFFFFF0C6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Fecha',
                      style: TextStyle(
                        color: Color(0xFFFFF0C6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              ...snapshot.data!.asMap().entries.map((entry) {
                final index = entry.key;
                final incidencia = entry.value;
                return _filaIncidencias(incidencia, index);
              }).toList(),
            ],
          );
        }
      },
    );
  }

  TableRow _filaIncidencias(
      FleteControlCalidadViewModel incidencia, int index) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              (index + 1).toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              incidencia.flccDescripcionIncidencia ?? 'N/A',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
       TableCell(
  child: Padding(
    padding: const EdgeInsets.all(8.0),
    child: Text(
      incidencia.flccFechaHoraIncidencia != null
          ? DateFormat('dd/MM/yyyy hh:mm a').format(incidencia.flccFechaHoraIncidencia!)
          : 'N/A',
      style: TextStyle(color: Colors.white),
    ),
  ),
),
      ],
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

  void _onCheckboxChanged(
      bool? value, FleteDetalleViewModel item, bool isInsumo) {
    setState(() {
      item.verificado = value;

      List<FleteDetalleViewModel> verifiedList =
          isInsumo ? insumosVerificados : equiposVerificados;
      List<FleteDetalleViewModel> notReceivedList =
          isInsumo ? insumosNoRecibidos : equiposNoRecibidos;

      if (value == true) {
        var verificacionexistente = verifiedList.firstWhere(
          (i) => isInsumo
              ? i.insuDescripcion == item.insuDescripcion
              : i.equsNombre == item.equsNombre,
          orElse: () {
            return FleteDetalleViewModel(fldeId: -1);
          },
        );

        if (verificacionexistente.fldeId != -1) {
          verificacionexistente.cantidadRecibida =
              (verificacionexistente.cantidadRecibida ?? 0) +
                  (item.fldeCantidad ?? 0);
          _textControllers[verificacionexistente.fldeId]!.text =
              verificacionexistente.cantidadRecibida.toString();
          notReceivedList.remove(item);
        } else {
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
        var existentenorecibido = notReceivedList.firstWhere(
          (i) => isInsumo
              ? i.insuDescripcion == item.insuDescripcion
              : i.equsNombre == item.equsNombre,
          orElse: () {
            return FleteDetalleViewModel(fldeId: -1);
          },
        );

        if (existentenorecibido.fldeId != -1) {
          existentenorecibido.fldeCantidad =
              (existentenorecibido.fldeCantidad ?? 0) +
                  (item.cantidadRecibida ?? 0);
          verifiedList.remove(item);
        } else {
          verifiedList.remove(item);
          notReceivedList.add(item);
        }
      }
    });
  }

  void _onCantidadChanged(
      String value, FleteDetalleViewModel item, bool isInsumo) {
    setState(() {
      print(value);
      int cantidadIngresada = int.tryParse(value) ?? 0;
      int cantidadOriginal = item.fldeCantidad!;
      print('cantidad origi $cantidadOriginal');

      if (cantidadIngresada > cantidadOriginal) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'La cantidad no puede ser mayor que la cantidad original: $cantidadOriginal',
            ),
          ),
        );
        cantidadIngresada = cantidadOriginal;
        _textControllers[item.fldeId]!.text = cantidadOriginal.toString();
      }

      // Actualizar el mapa temporal con la cantidad ingresada
      _cantidadesRecibidasTemp[item.fldeId!] = cantidadIngresada;
      print('en onchange $cantidadIngresada');

      // Actualizar el valor en el modelo
      item.cantidadRecibida = cantidadIngresada;

      print(
          'Cantidad ingresada: $cantidadIngresada para item ID: ${item.fldeId}');
      print('Mapa temporal actualizado: $_cantidadesRecibidasTemp');

      // Asegurarte de que no se pierden valores importantes
      if (cantidadIngresada < cantidadOriginal) {
        int cantidadRestante = cantidadOriginal - cantidadIngresada;

        List<FleteDetalleViewModel> noRecibidosList =
            isInsumo ? insumosNoRecibidos : equiposNoRecibidos;
        print('norecibidoslis antes de actualizar: $noRecibidosList');
        var existente = noRecibidosList.firstWhere(
          (e) => isInsumo
              ? e.insuDescripcion == item.insuDescripcion
              : e.equsNombre == item.equsNombre,
          orElse: () => FleteDetalleViewModel(fldeId: -1),
        );

        if (existente.fldeId != -1) {
          existente.fldeCantidad = cantidadRestante;
        } else {
          FleteDetalleViewModel restanteItem = FleteDetalleViewModel(
            codigo: item.codigo,
            fldeId: item.fldeId,
            inppId: item.inppId,
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
        }
      } else {
        _eliminarDeNoRecibidos(item, isInsumo);
      }
    });
  }

// Método para eliminar un elemento de la lista de no recibidos
  void _eliminarDeNoRecibidos(FleteDetalleViewModel item, bool isInsumo) {
    List<FleteDetalleViewModel> noRecibidosList =
        isInsumo ? insumosNoRecibidos : equiposNoRecibidos;

    print('elminar de no recib $noRecibidosList');
    noRecibidosList.removeWhere((e) => isInsumo
        ? e.insuDescripcion == item.insuDescripcion
        : e.equsNombre == item.equsNombre);
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

// Método para construir la tabla con los elementos
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
                          : item.equsNombre ??
                              '', // Asegúrate de que estas propiedades coincidan con el modelo correcto
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
                          : item.equsDescripcion ??
                              '', // Asegúrate de que estas propiedades coincidan con el modelo correcto
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
                              print('al cambiar $value, $item, $isInsumo');
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

  Future<String> _subirImagenFactura(PlatformFile file) async {
    final uniqueFileName =
        "${DateTime.now().millisecondsSinceEpoch}-${file.name}";
    final respuesta =
        await FleteEncabezadoService.uploadImage(file, uniqueFileName);
    return uniqueFileName;
  }

  Future<void> _verificarFlete() async {
    flete.usuaModificacion = 3;
    flete.flenEstado = true;

    final String imagenUrl = await _subirImagenFactura(comprobante!);
    print('Imagen URL: $imagenUrl');

    flete.flenComprobanteLLegada = imagenUrl;

    bool hayNoVerificados = false;
    bool hayErrores = false;

    void _actualizarCantidadesVerificadas(List<FleteDetalleViewModel> items) {
      for (var item in items) {
        int cantidadIngresada =
            int.tryParse(_textControllers[item.fldeId!]!.text) ?? 0;
        item.fldeCantidad = cantidadIngresada;

        if (cantidadIngresada <= 0) {
          hayErrores = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('La cantidad no puede ser vacía o cero.')),
          );
        }

        print(
            'Cantidad actualizada para item ID: ${item.fldeId} es ${item.fldeCantidad}');
      }
    }

    if (flete.flenFechaHoraLlegada == null) {
      return;
    }
    print('compobante $comprobante');
    if (comprobante == null) {
      hayErrores = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, suba el comprobante.')),
      );
      return;
    }

    // Actualizar las cantidades en insumos y equipos verificados antes de guardar
    _actualizarCantidadesVerificadas(insumosVerificados);
    _actualizarCantidadesVerificadas(equiposVerificados);

    if (hayErrores) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se puede guardar, revise las cantidades.')),
      );
      return;
    }

    // Cargar la lista de equipos desde el servicio
    List<EquipoPorProveedorViewModel> equiposLista =
        await FleteDetalleService.listarEquiposdeSeguridadPorBodega(
            flete.boasId!);

    // Asignar el eqppId a los detalles de equipos verificados
    List<FleteDetalleViewModel> equiposVerificadosConIds =
        equiposVerificados.map((detalle) {
      var equipo = equiposLista.firstWhere(
        (eq) => eq.eqppId == detalle.inppId,
        orElse: () => EquipoPorProveedorViewModel(),
      );

      // Asigna el eqppId correcto al inppId del detalle
      detalle.inppId = equipo.eqppId;
      print(
          'Equipo asignado: ${equipo.eqppId} a detalle ID: ${detalle.fldeId}');

      return detalle;
    }).toList();

    // Guardar Insumos Verificados
    for (var item in insumosVerificados) {
      item.fldeLlegada = true;
      item.usuaModificacion = 3;
      item.fldeCantidad = _cantidadesRecibidasTemp[item.fldeId!] ??
          item.fldeCantidad; // <-- Usa la cantidad ingresada por el usuario
      print('Guardar insumo verificado: $item');
      await FleteDetalleService.editarFleteDetalle(item);
    }

    // Guardar Insumos No Recibidos
    for (var item in insumosNoRecibidos) {
      print('Procesando insumo no recibido: $item');

      // Verifica y asigna valores por defecto si es necesario
      var detalleNuevo = FleteDetalleViewModel(
        flenId: item.flenId,
        fldeId: item.fldeId,
        inppId: item.inppId,
        usuaCreacion: item.usuaCreacion ?? 3,
        fldeFechaCreacion: item.fldeFechaCreacion ?? DateTime.now(),
        fldeCantidad: item.fldeCantidad ?? 0,
        fldeTipodeCarga: item.fldeTipodeCarga ?? true,
        fldeLlegada: false,
        insuDescripcion: item.insuDescripcion,
      );

      print('Detalle nuevo en insumo no recibido: $detalleNuevo');
      hayNoVerificados = true;

      try {
        final resp =
            await FleteDetalleService.insertarFleteDetalle2(detalleNuevo);
        print('respuesta insumos norecibidos $resp');
        if (resp['success'] &&
            resp['data'] != null &&
            resp['data']['codeStatus'] != null) {
          var s = resp['data']['codeStatus'];
          print('ID RESPUESTA $s');
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
          print('Detalle insertado: $detalleInsertado');

          await FleteDetalleService.editarFleteDetalle(detalleInsertado);
          hayNoVerificados = true;
        } else {
          throw Exception(
              'Error al insertar detalle: Respuesta no exitosa o datos nulos');
        }
      } catch (e) {
        print('Error al insertar detalle: $e');
      }
    }

    print('Equipos verificados con IDs asignados: $equiposVerificadosConIds');

    // Guardar Equipos Verificados
    for (var item in equiposVerificados) {
      item.fldeLlegada = true;
      item.usuaModificacion = 3;
      item.fldeCantidad = _cantidadesRecibidasTemp[item.fldeId!] ??
          item.fldeCantidad; // <-- Usa la cantidad ingresada por el usuario
      print('Guardar equipo verificado: $item');
      await FleteDetalleService.editarFleteDetalle(item);
    }

    // Guardar Equipos No Recibidos
    for (var detalle in equiposNoRecibidos) {
      print('Procesando equipo no recibido: $detalle');

      // Verifica y asigna valores por defecto si es necesario
      var detalleNuevo = FleteDetalleViewModel(
        flenId: detalle.flenId,
        fldeId: detalle.fldeId,
        inppId: detalle.inppId,
        usuaCreacion: detalle.usuaCreacion ?? 3,
        fldeFechaCreacion: detalle.fldeFechaCreacion ?? DateTime.now(),
        fldeCantidad: detalle.fldeCantidad ?? 0,
        fldeTipodeCarga: detalle.fldeTipodeCarga ?? true,
        fldeLlegada: false,
        equsNombre: detalle.equsNombre,
      );

      print('Guardar equipo no recibido: $detalleNuevo');
      hayNoVerificados = true;

      try {
        final resp =
            await FleteDetalleService.insertarFleteDetalle2(detalleNuevo);
        print('resp equipo no rec $resp');
        if (resp['success'] &&
            resp['data'] != null &&
            resp['data']['codeStatus'] != null) {
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
          print('Detalle insertado: $detalleInsertado');

          await FleteDetalleService.editarFleteDetalle(detalleInsertado);
          hayNoVerificados = true;
        } else {
          throw Exception(
              'Error al insertar detalle: Respuesta no exitosa o datos nulos');
        }
      } catch (e) {
        print('Error al insertar detalle: $e');
      }
    }

    print('Flete a enviar: $flete');
    try {
      await FleteEncabezadoService.editarFlete(flete);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Datos guardados exitosamente')),
      );

      if (hayNoVerificados) {
        setState(() {
          print('hay no verificados');
          _mostrarFormularioIncidencia = true;
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Flete(),
          ),
        );
      }
    } catch (e) {
      print('Error al guardar el flete: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el flete')),
      );
    }
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
      DateTime fechaHoraIncidencia = DateFormat('dd/MM/yyyy HH:mm')
          .parse(_fechaHoraIncidenciaController.text);

      final incidencia = FleteControlCalidadViewModel(
        flenId: flete.flenId!,
        flccDescripcionIncidencia: _descripcionIncidenciaController.text,
        flccFechaHoraIncidencia: fechaHoraIncidencia,
        usuaCreacion: 3,
        usuaModificacion: 3, // Si es necesario agregar usuaModificacion
      );

      print('Incidencia a insertar: $incidencia');

      int? resultado =
          await FleteControlCalidadService.insertarIncidencia(incidencia);

      if (resultado != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incidencia guardada exitosamente')),
        );

        // Reiniciar el formulario y regresar a la vista de fletes
        setState(() {
          // _mostrarFormularioIncidencia = false;
          _fechaHoraIncidenciaController.clear();
          _descripcionIncidenciaController.clear();
        });
        FleteControlCalidadService.buscarIncidencias(widget.flenId);

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => Flete(),
        //   ),
        // );
      } else {
        throw Exception('Error al guardar la incidencia');
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
          if (_mostrarFormularioIncidencia) ...[
            
          ] else ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFF0C6),
                padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                setState(() {
                  _mostrarErrores = true;
                });
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
        ],
      ),
    );
  }

  // Botón Guardar y Cancelar del formulario de incidencia
  Widget _buildFechaHoraLlegadaInput(
      {bool showError = false, String? errorMessage}) {
    return TextField(
      readOnly: true,
      onTap: _seleccionarFechaHora,
      decoration: InputDecoration(
        suffixIcon: Icon(Icons.calendar_today, color: Color(0xFFFFF0C6)),
        border: OutlineInputBorder(),
        errorText: showError ? errorMessage : null,
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
