import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigesproc_app/models/viaticos/CategoriaViaticoViewModel.dart';
import 'package:sigesproc_app/models/viaticos/detalleviaticoViewModel.dart';
import 'package:sigesproc_app/models/viaticos/viaticoDetViewModel.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/acceso/notificacion.dart';
import 'package:sigesproc_app/screens/acceso/perfil.dart';
import 'package:sigesproc_app/screens/menu.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';
import 'package:sigesproc_app/services/viaticos/viaticoDetservice.dart';
import 'package:sigesproc_app/services/viaticos/viaticoservice.dart';
import 'dart:convert';
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
  List<String> _loadedImages = [];
  int _unreadCount = 0;
  late int userId;
  String? _descripcionError;
  String? _montoGastadoError;
  String? _montoReconocidoError;
  String? _categoriaError;
  bool? _esAdmin;

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
    var prefs = PreferenciasUsuario();
    userId = int.tryParse(prefs.userId) ?? 0;
    _loadNotifications();
    _cargarDetalleViatico();
    _cargarEsAdmin();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await NotificationServices.BuscarNotificacion(userId);
      setState(() {
        _unreadCount = notifications.where((n) => n.leida == "No Leida").length;
      });
    } catch (e) {
      print('Error al cargar notificaciones: $e');
    }
  }

  Future<void> _cargarCategorias() async {
    try {
      categorias = await ViaticosDetService.listarCategoriasViatico();
      setState(() {});
    } catch (e) {
      print('Error al cargar categorías: $e');
    }
  }

  Future<void> _cargarEsAdmin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _esAdmin = prefs.getString('EsAdmin') == 'true';
    });
  }

Future<void> _cargarDetalleViatico() async {
  try {
    final List<Detalleviaticoviewmodel> detalles = await ViaticosEncService.buscarViaticoDetalle(widget.viaticoId);
    setState(() {
      // Limpiar la lista de imágenes cargadas previamente
      _loadedImages.clear();
      _detallesImagenes.clear(); // Limpiar los detalles anteriores

      // Iterar sobre cada detalle para obtener las imágenes
      for (var detalle in detalles) {
        if (detalle.videImagenFacturaList != null && detalle.videImagenFacturaList!.isNotEmpty) {
          // Agregar cada imagen individual a la lista _loadedImages
          _loadedImages.addAll(detalle.videImagenFacturaList!);
          _detallesImagenes.add(detalle); // Agregar los detalles correspondientes
        }
      }

      // Depuración para ver cuántas imágenes se cargaron
      print("Imágenes cargadas: ${_loadedImages.length}");
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
        _uploadedImages.insert(0, facturaSeleccionada!);
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


  
  Detalleviaticoviewmodel? _currentViatico;
  bool isEditing = false; // Nueva variable de estado para saber si estamos editando

Future<void> _guardarFactura() async {
  _validarCampos();

  // Validar los campos, si hay errores salimos del método
  if (_descripcionError != null ||
      _montoGastadoError != null ||
      _montoReconocidoError != null ||
      _categoriaError != null) {
    return;
  }

  // Si estamos insertando (no es edición) y no hay imágenes subidas, mostramos error
  if (!isEditing && _uploadedImages.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Por favor, suba una imagen de la factura.')),
    );
    return;
  }

  final DateTime fechaCreacion = DateTime.now();
  const String rutaBaseImagenes = "/uploads/";

  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int usuaCreacion = int.parse(prefs.getString('usuaId') ?? '0');
    final int usuaModificacion = usuaCreacion; // Usamos el mismo ID para modificación por ahora
    
    List<String> rutasImagenes = [];

    // Subimos nuevas imágenes solo si existen imágenes cargadas por el usuario
    if (_uploadedImages.isNotEmpty) {
      for (final image in _uploadedImages) {
        final String imagenNombre = await _subirImagenFactura(image);
        final String rutaCompletaImagen = rutaBaseImagenes + imagenNombre;
        rutasImagenes.add(rutaCompletaImagen);
        setState(() {
          _loadedImages.insert(0, rutaCompletaImagen);
        });
      }
    }

    // Crear el objeto ViaticoDetViewModel para la inserción o actualización
    ViaticoDetViewModel viaticoDet = ViaticoDetViewModel(
      videId: isEditing ? _currentViatico?.videId : null,  // Usar el ID si estamos editando
      videDescripcion: descripcionController.text,
      videImagenFactura: rutasImagenes.isNotEmpty
          ? rutasImagenes.join(',')  // Solo agregar nuevas imágenes si se subieron
          : isEditing ? _currentViatico?.videImagenFactura ?? '' : '',  // Mantener la imagen existente si estamos editando
      videMontoGastado: montoGastadoController.text,
      vienId: widget.viaticoId,
      caviId: int.parse(categoriaSeleccionada!),
      usuaCreacion: usuaCreacion,
      videFechaCreacion: fechaCreacion,
      videMontoReconocido: _esAdmin == true
          ? double.parse(montoReconocidoController.text)
          : null,
      // Añadimos los campos para modificación solo si estamos editando
      usuaModificacion: isEditing ? usuaModificacion : null,  // Enviar el ID del usuario que modificó
      videFechaModificacion: isEditing ? DateTime.now() : null,  // Fecha de modificación
    );

    // Imprimir los datos que se van a enviar
    print("Datos del viático que se van a enviar:");
    print(viaticoDet.toJson(isEditing: isEditing));

    // Si el viático ya tiene un ID, actualizamos, de lo contrario insertamos
    if (isEditing) {
      print("Actualizando viático...");
      await ViaticosDetService.actualizarViaticoDet(viaticoDet.toJson(isEditing: true));  // Llamar al servicio para actualizar
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Factura actualizada con éxito.')),
      );
    } else {
      print("Insertando nuevo viático...");
      final response = await ViaticosDetService.insertarViaticoDet(viaticoDet.toJson(isEditing: false));  // Llamar al servicio para insertar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Factura insertada con éxito.')),
      );
      
    }

    _limpiarFormulario();
    _cargarDetalleViatico();

  } catch (e, stacktrace) {
    print('Error al guardar la factura: $e');
    print('Stacktrace: $stacktrace');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al guardar la factura. Detalles: $e')),
    );
  }
}





  Future<String> _subirImagenFactura(PlatformFile file) async {
    print('Nombre del archivo: ${file.name}');
    print('Ruta del archivo: ${file.path}');
    print('Tamaño del archivo: ${file.size} bytes');
    final uniqueFileName = "${DateTime.now().millisecondsSinceEpoch}-${file.name}";
    final respuesta = await ViaticosDetService.uploadImage(file, uniqueFileName);
    print('Respuesta de la API al subir la imagen: ${respuesta.message}');
    return uniqueFileName;
  }

void _limpiarFormulario() {
  setState(() {
    descripcionController.clear();
    montoGastadoController.clear();
    montoReconocidoController.clear();
    categoriaController.clear();
    categoriaSeleccionada = null;
    facturaSeleccionada = null;
    _uploadedImages.clear(); // Limpiar las imágenes subidas
    _descripcionError = null;
    _montoGastadoError = null;
    _montoReconocidoError = null;
    _categoriaError = null;
    _currentViatico = null; // Limpiar el viático actual
  });
}


  void _validarCampos() {
  setState(() {
    // Validar campo de descripción
    _descripcionError = descripcionController.text.isEmpty ? 'El campo es requerido.' : null;

    // Validar campo de monto gastado
    _montoGastadoError = montoGastadoController.text.isEmpty ? 'El campo es requerido.' : null;
    double? montoGastado = double.tryParse(montoGastadoController.text);

    // Validar campo de monto reconocido si el usuario es administrador
    if (_esAdmin == true) {
      if (montoReconocidoController.text.isEmpty) {
        _montoReconocidoError = 'El campo es requerido.';  // Si el campo está vacío
      } else {
        double? montoReconocido = double.tryParse(montoReconocidoController.text);
        
        if (montoReconocido == null || montoGastado == null) {
          _montoReconocidoError = 'Ingrese un número válido.';
        } else if (montoReconocido > montoGastado) {
          _montoReconocidoError = 'El monto reconocido no puede ser mayor que el monto gastado.';  // Si el monto reconocido es mayor al gastado
        } else {
          _montoReconocidoError = null;  // Si todo es correcto, no hay error
        }
      }
    } else {
      _montoReconocidoError = null; // Si no es admin, no validamos el monto reconocido
    }

    // Validar la categoría
    _categoriaError = categoriaSeleccionada == null ? 'El campo es requerido.' : null;
  });
}

void _cargarDatosDeImagen(Detalleviaticoviewmodel detalleImagen) {
  setState(() {
    descripcionController.text = detalleImagen.videDescripcion ?? '';
    montoGastadoController.text = detalleImagen.videMontoGastado?.toString() ?? '';
    montoReconocidoController.text = detalleImagen.videMontoReconocido?.toString() ?? '';
    categoriaController.text = detalleImagen.caviDescripcion ?? '';
    categoriaSeleccionada = detalleImagen.caviId.toString();  // Guardar la categoría seleccionada
    
    // Cargar el vide_Id y vide_ImagenFactura
    _currentViatico = detalleImagen;  // Asignamos el viático seleccionado como el actual para edición
  });
}





List<Detalleviaticoviewmodel> _detallesImagenes = [];





Widget _buildCarruselDeImagenes() {
  return CarouselSlider(
    options: CarouselOptions(
      height: 200.0,
      enableInfiniteScroll: false,
      viewportFraction: 0.8,
      enlargeCenterPage: true,
    ),
    items: [
      // Imágenes subidas por el usuario
      if (_uploadedImages.isNotEmpty)
        ..._uploadedImages.asMap().entries.map((entry) {
          int index = entry.key;
          final imagePath = entry.value.path;
          if (imagePath != null && File(imagePath).existsSync()) {
            return GestureDetector(
              onTap: () async {
                // Llamar a la función para cargar los datos primero, y luego actualizar el estado
                await _cargarDatosDeImagenYActualizar(index);
              },
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Color(0xFF222222),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                        width: 1000.0,
                      ),
                    ),
                  ),
                  // Tooltip con diálogo emergente
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Tooltip(
                      message: 'Información de la imagen',
                      child: GestureDetector(
                        onTap: () {
                          // Mostrar el diálogo emergente cuando se toca el Tooltip
                          _mostrarDialogo(context);
                        },
                        child: Icon(
                          Icons.info_outline,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  // Botón para eliminar imágenes subidas
                  Positioned(
                    top: 5,
                    right: 35,
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
              ),
            );
          } else {
            return Center(
              child: Text(
                'No se pudo cargar la imagen',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
        }).toList(),

      // Imágenes cargadas desde la API
      if (_loadedImages.isNotEmpty)
        ..._loadedImages.asMap().entries.map((entry) {
          int index = entry.key;
          final fullImageUrl = entry.value; // La URL completa de la imagen cargada desde la API

          return GestureDetector(
            onTap: () async {
              // Llamar a la función para cargar los datos primero, y luego actualizar el estado
              await _cargarDatosDeImagenYActualizar(index);
            },
            child: Container(
              margin: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: Color(0xFF222222),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      fullImageUrl,
                      fit: BoxFit.cover,
                      width: 1000.0,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Center(
                            child: Text(
                              'Imagen no disponible',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Tooltip con diálogo emergente
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Tooltip(
                      message: 'Información de la imagen',
                      child: GestureDetector(
                        onTap: () {
                          // Mostrar el diálogo emergente cuando se toca el Tooltip
                          _mostrarDialogo(context);
                        },
                        child: Icon(
                          Icons.info_outline,
                          color: const Color.fromARGB(255, 0, 0, 0),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
    ],
  );
}

void _mostrarDialogo(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.black, // Fondo negro para el diálogo
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ), // Bordes redondeados
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Información',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: Color(0xFFFFF0C6), // Texto blanco
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Para poder ver el detalle de la factura, dar click en la imagen. '
                'De igual manera, podrá editar la factura.',
                style: TextStyle(
                  color: Colors.white, // Texto blanco para que sea legible
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cerrar el diálogo
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black, backgroundColor: Color(0xFFFFF0C6), // Texto negro en el botón
                ),
                child: Text('Cerrar'),
              ),
            ],
          ),
        ),
      );
    },
  );
}




Future<void> _cargarDatosDeImagenYActualizar(int index) async {
  // Activamos el modo edición
  setState(() {
    isEditing = true;
  });

  // Llamamos a la función para cargar los datos del viático
  if (index < _detallesImagenes.length) {
    // Esperar a que los datos estén cargados antes de actualizar el estado
    _cargarDatosDeImagen(_detallesImagenes[index]);

    // Ahora que los datos están cargados, actualizamos el estado
    setState(() {
      // Aquí podrías actualizar cualquier otro dato del estado si es necesario
    });
  }
}





    void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
            SizedBox(width: 10),
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
          preferredSize: Size.fromHeight(80.0),
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
              SizedBox(height: 5),
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
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications, color: Color(0xFFFFF0C6)),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificacionesScreen(),
                    ),
                  );
                  if (result != null) {
                    _loadNotifications();
                  }
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
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
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.person, color: Color(0xFFFFF0C6)),
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
        iconTheme: IconThemeData(color: Color(0xFFFFF0C6)),
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
                        if (_esAdmin == true)
                          _buildMontoReconocidoTextField(),
                        if (_montoReconocidoError != null && _esAdmin == true)
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
                        _buildSubirImagenButton(),
                        SizedBox(height: 20),
                        _buildCarruselDeImagenes(),
                        SizedBox(height: 40),
                        _buildBottomButtons(),
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

Widget _buildBottomButtons() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 35.0, vertical: 15.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end, // Alinea los botones a la derecha
      children: [
        Flexible(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFF0C6),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Reduce el padding horizontal
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              _guardarFactura();
            },
            icon: Icon(Icons.save, color: Colors.black),
            label: Text(
              'Guardar',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14, // Tamaño de texto más pequeño
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Flexible(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF171717),
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Reduce el padding horizontal
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.close, color: Colors.white),
            label: Text(
              'Cancelar',
              style: TextStyle(
                color: Color(0xFFFFF0C6),
                fontSize: 14, // Tamaño de texto más pequeño
              ),
            ),
          ),
        ),
      ],
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
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFFF0C6),
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: _seleccionarImagen, // Acción para seleccionar o cambiar imagen
        icon: Icon(Icons.upload_file, color: Colors.black), // Icono de subir archivo
        label: Text(
          facturaSeleccionada == null ? 'Subir Imágenes' : 'Cambiar Imagen',
          style: TextStyle(color: Colors.black), // Estilo del texto
        ),
      ),
      SizedBox(width: 10), // Espacio entre botones
      ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF171717),
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          // Lógica para limpiar el formulario y activar el modo de inserción
          _limpiarFormulario();
          setState(() {
            isEditing = false; // Entramos en modo insertar
          });
        },
        icon: Icon(Icons.delete, color: Color(0xFFFFF0C6)), // Icono del botón de limpiar
        label: Text(
          'Limpiar',
          style: TextStyle(color: Colors.white), // Estilo del texto
        ),
      ),
    ],
  );
}

}
