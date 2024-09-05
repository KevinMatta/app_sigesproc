import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigesproc_app/models/proyectos/controlcalidadporactividadviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/imagenporcontrolcalidadviewmodel.dart';
import 'package:sigesproc_app/services/proyectos/controlcalidadporactividadservice.dart';
import '../menu.dart'; 
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ControlCalidadScreen extends StatefulWidget {
  final int acetId;
  final String? unidadMedida;
  final String? actividadNombre;



  const ControlCalidadScreen({Key? key, required this.acetId, this.unidadMedida, this.actividadNombre}) : super(key: key);

  @override
  _ControlCalidadScreenState createState() => _ControlCalidadScreenState();
}

class _ControlCalidadScreenState extends State<ControlCalidadScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController cantidadController = TextEditingController();
  DateTime? selectedDate;
  bool showFechaError = false;
  int? idScope = 0;
  String? unidadNombre;
  String? actividad;
  num? tCantidadTrabajada = 0;
  num? tTrabajar = 0;
  bool isCalculating = false;

  bool descripcionVacia = false;
  bool cantidadVacia = false;
  bool fechaVacia = false;


  List<PlatformFile> _uploadedImages = []; // Lista para almacenar las imágenes subidas

  void _selectImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true, // Permitir múltiples imágenes
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _uploadedImages.addAll(result.files);
      });
    }
  }


  @override
  void initState() {
    super.initState();
    // Asignar valor a unidadNombre en el initState
    unidadNombre = widget.unidadMedida ?? "";
    actividad = widget.actividadNombre ?? "";
    isCalculating = true;
    obtenerTotalCantidadTrabajada();
  }

  void _removeImage(int index) {
    setState(() {
      _uploadedImages.removeAt(index);
    });
  }


  num totalCantidadTrabajada = 0;
  num? totalTrabajar = 0;

Future<void> obtenerTotalCantidadTrabajada() async {
  try {
    // Llama al servicio para listar los controles de calidad
    final List<ListarControlDeCalidadesPorActividadesViewModel> controles = await ControlDeCalidadesPorActividadesService.listarControlCalidad();

    // Filtra los controles de calidad que coincidan con acetId y suma cocaCantidadtrabajada
    totalCantidadTrabajada = 0; // Reinicia la variable antes de sumar
    for (var control in controles) {
      if (control.acetId == widget.acetId) {
        totalCantidadTrabajada += (control.cocaCantidadtrabajada ?? 0.0);

        // Aquí forzamos la conversión de int a double si es necesario
        try {
          if (control.acetCantidad != null) {
            if (control.acetCantidad is int) {
              totalTrabajar = (control.acetCantidad as int).toDouble();
            } else if (control.acetCantidad is double) {
              totalTrabajar = control.acetCantidad;
            } else {
              throw Exception("Tipo inesperado para acetCantidad: ${control.acetCantidad.runtimeType}. Valor: ${control.acetCantidad}");
            }
          }
        } catch (e) {
          throw Exception("Error al convertir acetCantidad: ${control.acetCantidad.runtimeType} a double. Valor: ${control.acetCantidad}");
        }
      }
    }
    tCantidadTrabajada = totalCantidadTrabajada;
    tTrabajar = totalTrabajar;
    setState(() {
      isCalculating = false; // Finaliza el cálculo
    });
  } catch (e, stackTrace) {
    print("Error al obtener el total de cantidad trabajada: $e");
    print("Stack trace: $stackTrace");
  }
}






  Future<void> procesarControlCalidadYSubirImagenes(
  ControlDeCalidadesPorActividadesViewModel controlDeCalidadesViewModel,
  List<PlatformFile> uploadedImages,
) async {
  int usuarioLogueado;

      final SharedPreferences pref = await SharedPreferences.getInstance();
              String idParse = pref.getString('usuaId')!;
        usuarioLogueado = int.parse(idParse);
  try {

    if(uploadedImages.length > 0)
    {
          // Guardar el control de calidad
    final respuesta = await ControlDeCalidadesPorActividadesService.insertarControlCalidad(controlDeCalidadesViewModel);

    // Accede a codeStatus desde respuesta.data
    int? idScope = respuesta.data['codeStatus'];

    if (respuesta.success == true && idScope != null) {

      // Subir las imágenes una por una
      for (var imagen in uploadedImages) {
        print('Subiendo imagen: ${imagen.name}');
        try {
          final uniqueFileName = "${DateTime.now().millisecondsSinceEpoch}-${imagen.name}";

          final respuestaImagen = await ControlDeCalidadesPorActividadesService.uploadImage(imagen, uniqueFileName);

          if (respuestaImagen.message == "Éxito" ) {
              // Validar si la imagen se subió correctamente

              if (uniqueFileName != null && uniqueFileName.isNotEmpty) {
                // Crear el modelo para insertar en ImagenPorControlCalidad
                final imagenPorControlCalidad = ImagenPorControlCalidadViewModel(
                  iccaImagen: uniqueFileName,  // La URL de la imagen subida
                  cocaId: idScope!,  // El ID del control de calidad guardado
                  usuaCreacion: usuarioLogueado,
                  iccaFechaCreacion: DateTime.now(),
                );

                // Insertar en ImagenPorControlCalidad
                final respuestaInsercion = await ControlDeCalidadesPorActividadesService.insertarImagenPorControlCalidad(imagenPorControlCalidad);

                if (!respuestaInsercion.success!) {
                  throw Exception('Error al insertar la imagen por control de calidad en la base de datos.');
                }

              } else {
                throw Exception('Error al obtener la URL de la imagen subida.');
              }
            } else {
              throw Exception('Error al subir la imagen al servidor.');
            }
        } catch (e) {
          print('Error al procesar la imagen: $e.');
          // Lanzar una excepción específica si falla la inserción en la tabla de imágenes
          throw Exception("Error al subir o insertar la imagen: ${imagen.name} debido a: $e.");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Insertado con Éxito."),
      ));
      Navigator.of(context).pop();
    } else {
          obtenerTotalCantidadTrabajada();
          double? n = idScope!.abs().toDouble();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("La cantidad del control de calidad se excede por: $n."),
          
        ));
      // throw Exception("Error al guardar el control de calidad.");
    }
  } else {

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Imágenes Requeridas"),
      ));

      }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Error: $e."),
    ));
    print("Error al guardar el control de calidad o subir imágenes: $e.");
  }
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
  preferredSize: Size.fromHeight(90.0),
  child: Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Colors.black, // Color del borde negro
          width: 2.0, // Grosor del borde
        ),
      ),
    ),
    child: Column(
      children: [
        Text(
          'Actividad: $actividad',
          style: TextStyle(
            color: Color(0xFFFFF0C6),
            fontSize: 15,
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
                // Acción para el botón de "Regresar"
                Navigator.pop(context);
              },
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
            SizedBox(width: 20), // Espacio entre el botón y el texto
            Padding(
              padding: const EdgeInsets.only(top: 30.0), // Padding superior
              child: Text(
                'Nuevo Control de Calidad',
                style: TextStyle(
                  color: Color(0xFFFFF0C6),
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
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
      selectedIndex: 1,
      onItemSelected: (index) {
        // Handle menu item selection
      },
    ),
    body: Container(
      color: Colors.black,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),

                    // Label con asterisco condicional para Descripción
                    Row(
                      children: [
                        Text(
                          'Ingresar la descripción',
                          style: TextStyle(color: Color(0xFFFFF0C6)),
                        ),
                        if (descripcionVacia)
                          Text(
                            ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                    SizedBox(height: 5),
                    TextFormField(
                      controller: descripcionController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Descripción',
                        hintStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Color(0xFF222222),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        setState(() {}); // Para actualizar el estado y mostrar/ocultar el asterisco
                        if (value == null || value.isEmpty) {
                          descripcionVacia = true;
                          return 'El campo es requerido.';
                        }
                        descripcionVacia = false;
                        return null;
                      },
                    ),

                    SizedBox(height: 10),

                    // Label con asterisco condicional para Cantidad
                    Row(
                      children: [
                        Text(
                          'Ingresar la cantidad de $unidadNombre',
                          style: TextStyle(color: Color(0xFFFFF0C6)),
                        ),
                        if (cantidadVacia)
                          Text(
                            ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Caja de texto
                        TextFormField(
                          controller: cantidadController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Cantidad',
                            hintStyle: TextStyle(color: Colors.white54),
                            filled: true,
                            fillColor: Color(0xFF222222),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // Limita a dos decimales
                          ],
                          validator: (value) {
                            setState(() {}); // Para actualizar el estado y mostrar/ocultar el asterisco
                            if (value == null || value.isEmpty) {
                              cantidadVacia = true;
                              obtenerTotalCantidadTrabajada();
                              return 'El campo es requerido.';
                            }
                            cantidadVacia = false;
                            return null;
                          },
                        ),

                        SizedBox(height: 5),

                        // Texto siempre visible
                        // Mostrar un indicador de carga o el texto calculado
                        isCalculating
                            ? SizedBox(
                                width: 15.0, // Ancho deseado
                                height: 15.0, // Alto deseado
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFFF0C6), // Indicador de carga mientras se calcula
                                  strokeWidth: 3.0, // Grosor del indicador
                                ),
                              )
                            : Text(
                                'Cantidad total de $unidadNombre: $tTrabajar , $unidadNombre trabajados: $tCantidadTrabajada.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                      ],
                    ),
                    
                    SizedBox(height: 15),

                    ListTile(
                      title: Text(
                        selectedDate == null
                            ? 'Seleccionar Fecha'
                            : DateFormat('dd-MM-yyyy').format(selectedDate!),
                        style: TextStyle(color: Color(0xFFFFF0C6)),
                      ),
                      trailing: Icon(Icons.calendar_today, color: Color(0xFFFFF0C6)),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          locale: const Locale("es", "ES"),
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(
                                  primary: Color(0xFFFFF0C6),
                                  surface: Colors.black,
                                ),
                                dialogBackgroundColor: Color(0xFF222222),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                            showFechaError = false;
                          });
                        }
                      },
                    ),
                    if (showFechaError)
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Text(
                          'El campo es requerido.',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFFF0C6),
                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _selectImages,
                            icon: Icon(Icons.upload_file, color: Colors.black), // Icono de subir archivo
                            label: Text(
                              'Subir Imágenes',
                              style: TextStyle(color: Colors.black),
                            ),
                          )
                      ],
                    ),
                    SizedBox(height: 20),

                    // Carrusel de imágenes
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
                                  child: Image.file(
                                    File(file.path!),
                                    fit: BoxFit.cover,
                                    width: 1000.0,
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
                      ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20),

          // Botones de Guardar y Cancelar
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFF0C6),
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (selectedDate == null) {
                      setState(() {
                        showFechaError = true;
                      });
                      return;
                    }

                    final controlDeCalidadesViewModel = ControlDeCalidadesPorActividadesViewModel(
                      cocaDescripcion: descripcionController.text,
                      cocaFecha: selectedDate!,
                      usuaCreacion: 3,  // Usuario predeterminado
                      cocaCantidadtrabajada: double.tryParse(cantidadController.text) ?? 0.0,
                      acetId: widget.acetId,
                    );

                    try {
                      await procesarControlCalidadYSubirImagenes(controlDeCalidadesViewModel, _uploadedImages);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error: $e"),
                        ),
                      );
                    }
                  }
                },
                icon: Icon(Icons.save, color: Colors.black), // Icono de Guardar
                label: Text(
                  'Guardar',
                  style: TextStyle(color: Colors.black, fontSize: 15),
                ),
              ),
              SizedBox(width: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF222222),
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.close, color: Colors.white), // Icono de Cancelar
                label: Text(
                  'Cancelar',
                  style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 15),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    ),
  );
}

}
