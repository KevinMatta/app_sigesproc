import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigesproc_app/models/viaticos/CategoriaViaticoViewModel.dart';
import 'package:sigesproc_app/models/viaticos/viaticoDetViewModel.dart';
import 'package:sigesproc_app/services/viaticos/viaticoDetservice.dart';
import 'package:sigesproc_app/services/viaticos/viaticoservice.dart';
import 'package:sigesproc_app/models/viaticos/viaticoViewModel.dart';
import '../menu.dart';
import 'dart:io';

class AgregarFactura extends StatefulWidget {
  final int viaticoId;

  const AgregarFactura({Key? key, required this.viaticoId}) : super(key: key);

  @override
  _AgregarFacturaState createState() => _AgregarFacturaState();
}

class _AgregarFacturaState extends State<AgregarFactura> {
  int _selectedIndex = 5;
  final _formKey = GlobalKey<FormState>();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController montoGastadoController = TextEditingController();
  TextEditingController montoReconocidoController = TextEditingController();
  TextEditingController categoriaController = TextEditingController();
  String? categoriaSeleccionada;
  List<CategoriaVaticoViewModel> categorias = [];
  PlatformFile? facturaSeleccionada;
  List<PlatformFile> _uploadedImages = [];
  List<String> _loadedImages = []; // Aquí se almacenan las URLs de las imágenes cargadas

  String? _descripcionError;
  String? _montoGastadoError;
  String? _montoReconocidoError;
  String? _categoriaError;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
    _cargarDetalleViatico(); // Carga las imágenes existentes
  }

  Future<void> _cargarCategorias() async {
    try {
      categorias = await ViaticosDetService.listarCategoriasViatico();
      setState(() {});
    } catch (e) {
      print('Error al cargar categorías: $e');
    }
  }

  Future<void> _cargarDetalleViatico() async {
    try {
      final detalle = await ViaticosEncService.buscarViaticoDetalle(widget.viaticoId);
      setState(() {
        _loadedImages = detalle.imagenes; // Asegúrate de que 'imagenes' sea una lista de URLs en tu modelo
      });
    } catch (e) {
      print('Error al cargar el detalle del viático: $e');
    }
  }

  void _seleccionarImagen() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        facturaSeleccionada = result.files.first;
        _uploadedImages.insert(0, facturaSeleccionada!);  // Insertar la nueva imagen al inicio de la lista
      });
      print('Imagen seleccionada: ${facturaSeleccionada!.name}');
    } else {
      setState(() {
        facturaSeleccionada = null;
      });
      print('No se seleccionó ninguna imagen.');
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _uploadedImages.length) {
        _uploadedImages.removeAt(index);
      } else {
        _loadedImages.removeAt(index - _uploadedImages.length);
      }
    });
  }

  Future<void> _guardarFactura() async {
  _validarCampos();

  if (_descripcionError != null ||
      _montoGastadoError != null ||
      _montoReconocidoError != null ||
      _categoriaError != null) {
    return;
  }

  if (_uploadedImages.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Por favor, suba una imagen de la factura.')),
    );
    return;
  }

  final DateTime fechaCreacion = DateTime.now();

  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int usuaCreacion = int.parse(prefs.getString('usuaId') ?? '0'); // Obtener el ID del usuario logueado

    for (final image in _uploadedImages) {
      final String imagenUrl = await _subirImagenFactura(image);
      _loadedImages.insert(0, imagenUrl); // Insertar la URL de la imagen al inicio de la lista
    }
    
    final viaticoDet = ViaticoDetViewModel(
      videDescripcion: descripcionController.text,
      videImagenFactura: _loadedImages.join(','), // Guardar todas las imágenes como una cadena separada por comas
      videMontoGastado: montoGastadoController.text,
      vienId: widget.viaticoId,
      caviId: int.parse(categoriaSeleccionada!),
      usuaCreacion: usuaCreacion, // Usar el ID del usuario logueado
      videFechaCreacion: fechaCreacion,
      videMontoReconocido: double.parse(montoReconocidoController.text),
    );
  
    await ViaticosDetService.insertarViaticoDet(viaticoDet);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Insertado con Éxito.')),
    );
    _limpiarFormulario();
  } catch (e, stacktrace) {
    print('Error al guardar la factura: $e');
    print('Stacktrace: $stacktrace');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al guardar la factura: $e')),
    );
  }
}


  Future<String> _subirImagenFactura(PlatformFile file) async {
    final uniqueFileName = "${DateTime.now().millisecondsSinceEpoch}-${file.name}";
    final respuesta = await ViaticosDetService.uploadImage(file, uniqueFileName);
    return uniqueFileName; // Aquí deberías retornar la URL real de la imagen
  }

  void _limpiarFormulario() {
    setState(() {
      descripcionController.clear();
      montoGastadoController.clear();
      montoReconocidoController.clear();
      categoriaController.clear();
      categoriaSeleccionada = null;
      facturaSeleccionada = null;
      _uploadedImages.clear();

      // Resetear los errores también
      _descripcionError = null;
      _montoGastadoError = null;
      _montoReconocidoError = null;
      _categoriaError = null;
    });
  }

  void _validarCampos() {
    setState(() {
      _descripcionError = descripcionController.text.isEmpty ? 'El campo es requerido.' : null;
      _montoGastadoError = montoGastadoController.text.isEmpty ? 'El campo es requerido.' : null;
    
      double? montoGastado = double.tryParse(montoGastadoController.text);
      double? montoReconocido = double.tryParse(montoReconocidoController.text);
    
      if (montoReconocido == null || montoGastado == null) {
        _montoReconocidoError = 'Ingrese un número válido.';
      } else {
        _montoReconocidoError = montoReconocido > montoGastado
            ? 'El monto reconocido no puede ser mayor que el monto gastado.'
            : null;
      }
    
      _categoriaError = categoriaSeleccionada == null ? 'El campo es requerido.' : null;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBottomButtons() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 35.0, vertical: 15.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end, // Alinea los botones a la derecha
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFFF0C6),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Reduce el tamaño del padding para hacer los botones más delgados
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Ajusta el borde a un radio más pequeño si lo prefieres
            ),
          ),
          onPressed: () async {
            await _guardarFactura(); // Reemplazando con la función de guardar factura
          },
          child: Text(
            'Guardar',
            style: TextStyle(
              color: Colors.black,
              fontSize: 14, // Reduce el tamaño del texto
            ),
          ),
        ),
        SizedBox(width: 10), // Espacio entre los botones
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromARGB(255, 49, 49, 49),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Reduce el tamaño del padding para hacer los botones más delgados
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Ajusta el borde a un radio más pequeño si lo prefieres
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14, // Reduce el tamaño del texto
            ),
          ),
        ),
      ],
    ),
  );
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
                'Agregar Factura',
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
      drawer: MenuLateral(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Color(0xFF171717),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDescripcionTextField(),
                        if (_descripcionError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              _descripcionError!,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        SizedBox(height: 20),
                        _buildMontoGastadoTextField(),
                        if (_montoGastadoError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              _montoGastadoError!,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        SizedBox(height: 20),
                        _buildMontoReconocidoTextField(),
                        if (_montoReconocidoError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              _montoReconocidoError!,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        SizedBox(height: 20),
                        _buildCategoriaTypeAhead(),
                        if (_categoriaError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5.0),
                            child: Text(
                              _categoriaError!,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        SizedBox(height: 20),
                        _buildSubirImagenButton(), // Botón para subir imagen
                        SizedBox(height: 20),
                        _buildCarruselDeImagenes(), // Carrusel para visualizar imágenes
                        SizedBox(height: 40), // Espacio adicional para los botones
                        _buildBottomButtons(), // Aquí se agregan los nuevos botones
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescripcionTextField() {
    return TextFormField(
      controller: descripcionController,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Descripción',
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildMontoGastadoTextField() {
    return TextFormField(
      controller: montoGastadoController,
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Monto Gastado',
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildMontoReconocidoTextField() {
    return TextFormField(
      controller: montoReconocidoController,
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: 'Monto Reconocido',
        labelStyle: TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.black,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildCategoriaTypeAhead() {
    return TypeAheadFormField<CategoriaVaticoViewModel>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: categoriaController,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Categoría de Viático',
          labelStyle: TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.black,
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.arrow_drop_down, color: Color(0xFFFFF0C6)),
        ),
      ),
      suggestionsCallback: (pattern) async {
        return categorias
            .where((categoria) => categoria.caviDescripcion!.toLowerCase().contains(pattern.toLowerCase()))
            .toList();
      },
      itemBuilder: (context, CategoriaVaticoViewModel suggestion) {
        return ListTile(
          title: Text(suggestion.caviDescripcion ?? '', style: TextStyle(color: Colors.white)),
        );
      },
      onSuggestionSelected: (CategoriaVaticoViewModel suggestion) {
        setState(() {
          categoriaController.text = suggestion.caviDescripcion ?? '';
          categoriaSeleccionada = suggestion.caviId.toString();
        });
      },
      noItemsFoundBuilder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('No se encontraron categorías', style: TextStyle(color: Colors.white)),
      ),
      suggestionsBoxDecoration: SuggestionsBoxDecoration(
        color: Colors.black,
      ),
    );
  }

  Widget _buildSubirImagenButton() {
    return Center(  
      child: ElevatedButton(
        onPressed: _seleccionarImagen,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFFF0C6),
          foregroundColor: Color(0xFF171717),
        ),
        child: Text(facturaSeleccionada == null ? 'Subir Imagen' : 'Cambiar Imagen'),
      ),
    );
  }

  Widget _buildCarruselDeImagenes() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        enableInfiniteScroll: false,
        viewportFraction: 0.8,
        enlargeCenterPage: true,
      ),
      items: [
        ..._uploadedImages.asMap().entries.map((entry) {
          int index = entry.key;

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
                  child: entry.value.path != null && File(entry.value.path!).existsSync()
                      ? Image.file(
                          File(entry.value.path!),
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
                  onTap: () => _removeImage(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 189, 13, 0).withOpacity(0.7),
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
        ..._loadedImages.map((imageUrl) {
          return Container(
            margin: EdgeInsets.all(5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Color(0xFF222222),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: 1000.0,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}