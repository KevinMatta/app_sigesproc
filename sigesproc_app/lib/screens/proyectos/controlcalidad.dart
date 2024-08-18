import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sigesproc_app/models/proyectos/controlcalidadporactividadviewmodel.dart';
import 'package:sigesproc_app/models/proyectos/imagenporcontrolcalidadviewmodel.dart';
import 'package:sigesproc_app/services/proyectos/controlcalidadporactividadservice.dart';
import '../menu.dart'; 
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';

class ControlCalidadScreen extends StatefulWidget {
  final int acetId;
  final String? unidadMedida;


  const ControlCalidadScreen({Key? key, required this.acetId, this.unidadMedida}) : super(key: key);

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
  }

  void _removeImage(int index) {
    setState(() {
      _uploadedImages.removeAt(index);
    });
  }

  Future<void> procesarControlCalidadYSubirImagenes(
  ControlDeCalidadesPorActividadesViewModel controlDeCalidadesViewModel,
  List<PlatformFile> uploadedImages,
) async {
  try {
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
                  usuaCreacion: 3,
                  iccaFechaCreacion: DateTime.now(),
                );

                // Insertar en ImagenPorControlCalidad
                final respuestaInsercion = await ControlDeCalidadesPorActividadesService.insertarImagenPorControlCalidad(imagenPorControlCalidad);

                if (!respuestaInsercion.success!) {
                  throw Exception('Error al insertar la imagen por control de calidad en la base de datos');
                }

              } else {
                throw Exception('Error al obtener la URL de la imagen subida');
              }
            } else {
              throw Exception('Error al subir la imagen al servidor');
            }
        } catch (e) {
          print('Error al procesar la imagen: $e');
          // Lanzar una excepción específica si falla la inserción en la tabla de imágenes
          throw Exception("Error al subir o insertar la imagen: ${imagen.name} debido a: $e");
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Guardado con éxito"),
        backgroundColor: Colors.green,
      ));
      Navigator.of(context).pop();
    } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("La cantidad del control de calidad de excede por $idScope"),
          backgroundColor: Colors.red,
        ));
      throw Exception("Error al guardar el control de calidad.");
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Error: $e"),
      backgroundColor: Colors.red,
    ));
    print("Error al guardar el control de calidad o subir imágenes: $e");
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
          preferredSize: Size.fromHeight(40.0),
          child: Column(
            children: [
              Text(
                'Control de Calidad',
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
                      Text(
                        'Ingresar la descripción:',
                        style: TextStyle(color: Color(0xFFFFF0C6)),
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
                          if (value == null || value.isEmpty) {
                            return 'La descripción es requerida';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Ingresar la cantidad de $unidadNombre:',
                        style: TextStyle(color: Color(0xFFFFF0C6)),
                      ),
                      SizedBox(height: 5),
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
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La cantidad es requerida';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
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
                            'La fecha es requerida',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFF0C6),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _selectImages,
                  child: Text(
                    'Subir Imagen',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF222222),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFFF0C6),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
                        usuaCreacion: 3, // Usuario predeterminado
                        cocaCantidadtrabajada: double.tryParse(cantidadController.text) ?? 0.0,
                        acetId: widget.acetId,
                      );

                      try {
                        // Procesa el control de calidad y las imágenes
                        await procesarControlCalidadYSubirImagenes(controlDeCalidadesViewModel, _uploadedImages);
                      } catch (e) {
                        // Manejo del error y mostrar mensaje de error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Guardar',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              height: 100,  
              color: Colors.black,  // Fondo negro
            ),
          ],
        ),
      ),
    );
  }
}
