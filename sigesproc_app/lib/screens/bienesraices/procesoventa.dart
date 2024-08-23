import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:sigesproc_app/models/bienesraices/procesoventaviewmodel.dart';
import 'package:sigesproc_app/screens/bienesraices/ubicacion.dart';
import 'package:sigesproc_app/screens/bienesraices/venta.dart';
import '../menu.dart';
import 'package:sigesproc_app/services/bienesraices/procesoventaservice.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sigesproc_app/screens/bienesraices/vender.dart';

class ProcesoVenta extends StatefulWidget {
  @override
  _ProcesoVentaState createState() => _ProcesoVentaState();
}

class _ProcesoVentaState extends State<ProcesoVenta> {
  int _selectedIndex = 4;
  Future<List<ProcesoVentaViewModel>>? _procesosventaFuture;
  TextEditingController _searchController = TextEditingController();
  List<ProcesoVentaViewModel> _filteredProcesosVenta = [];
  List<ProcesoVentaViewModel>? _selectedVenta;
  bool _valorFueEditado = false;
  bool _fechaFueEditada = false;

  final ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: Color(0xFFFFF0C6),
      onPrimary: Colors.black,
      surface: Colors.black,
      onSurface: Colors.white,
    ),
    dialogBackgroundColor: Colors.black,
  );

  @override
  void initState() {
    super.initState();
    _cargarProcesosVenta();
    _searchController.addListener(_filtradoProcesosVenta);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtradoProcesosVenta);
    _searchController.dispose();
    super.dispose();
  }

  void _filtradoProcesosVenta() {
    final query = _searchController.text.toLowerCase();
    if (_procesosventaFuture != null) {
      _procesosventaFuture!.then((procesosventa) {
        setState(() {
          _filteredProcesosVenta = procesosventa.where((procesoventa) {
            final salida = procesoventa.descripcion?.toLowerCase() ?? '';
            return salida.contains(query);
          }).toList();
        });
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _verDetalles(int btrpId, bool terrenobienraizId, int? bienoterrenoid) {
    setState(() {
      _procesosventaFuture = ProcesoVentaService.Buscar(
          btrpId, terrenobienraizId ? 1 : 0, bienoterrenoid!);
      _procesosventaFuture!.then((value) {
        setState(() {
          _selectedVenta = value;
          print('Detalles venta: $_selectedVenta');
        });
      }).catchError((error) {
        print('Error: $error');
      });
    });
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir el enlace $url';
    }
  }

  void _reiniciarProcesosVentaFiltros() {
    setState(() {
      _filteredProcesosVenta = [];
    });
    _cargarProcesosVenta();
  }

  void _cargarProcesosVenta() {
    _procesosventaFuture = ProcesoVentaService.listarProcesosVenta();
    _procesosventaFuture!.then((procesosventa) {
      setState(() {
        _filteredProcesosVenta = procesosventa;
      });
    });
  }

  void _cargarImagenes(int btrpId, bool terrenobienraizId, int? bienoterrenoid,
      Function(List<String>) callback) {
    ProcesoVentaService.Buscar(
            btrpId, terrenobienraizId ? 1 : 0, bienoterrenoid!)
        .then((value) {
      List<String> imagenes = value.map((e) => e.imprImagen!).toList();
      callback(imagenes);
    }).catchError((error) {
      print('Error: $error');
      callback([]);
    });
  }

  void _modalEliminar(
      BuildContext context, ProcesoVentaViewModel procesoventa) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text('Eliminar propiedad', style: TextStyle(color: Colors.white)),
          content: Text(
            '¿Está seguro de querer eliminar la propiedad ${procesoventa.descripcion} del estado en venta?',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color(0xFF171717),
          actions: [
            TextButton(
              child:
                  Text('Eliminar', style: TextStyle(color: Color(0xFFFFF0C6))),
              onPressed: () async {
                try {
                  await ProcesoVentaService.Eliminar(procesoventa.btrpId);
                  setState(() {
                    print(_filteredProcesosVenta);
                    print(procesoventa);
                    _filteredProcesosVenta.remove(procesoventa);
                    print(_filteredProcesosVenta.remove(procesoventa));
                    print(_filteredProcesosVenta);
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bien raíz eliminado con éxito')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar el registro')),
                  );
                }
              },
            ),
            TextButton(
              child:
                  Text('Cancelar', style: TextStyle(color: Color(0xFFFFF0C6))),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _isValorInvalido(String valor) {
    if (valor.isEmpty) return true;
    final number = double.tryParse(valor);
    return number == null || number <= 0;
  }

  bool _isFechaInvalida(String fecha) {
    if (fecha.isEmpty) return true;
    try {
      DateFormat('dd/MM/yyyy').parseStrict(fecha);
      return false;
    } catch (e) {
      return true;
    }
  }

  // void _modalVender(BuildContext context, ProcesoVentaViewModel venta) {
  //   TextEditingController valorController = TextEditingController();
  //   TextEditingController fechaController = TextEditingController();

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             title: Text('Propiedad en venta',
  //                 style: TextStyle(color: Colors.white)),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 TextField(
  //                   controller: valorController,
  //                   decoration: InputDecoration(
  //                     hintText: 'Valor de venta',
  //                     hintStyle: TextStyle(color: Colors.white54),
  //                     filled: true,
  //                     fillColor: Colors.white24,
  //                     errorText: _valorFueEditado &&
  //                             _isValorInvalido(valorController.text)
  //                         ? 'Ingrese un valor válido'
  //                         : null,
  //                   ),
  //                   style: TextStyle(color: Colors.white),
  //                   keyboardType: TextInputType.number,
  //                   inputFormatters: [
  //                     FilteringTextInputFormatter
  //                         .digitsOnly, // Permitir solo dígitos
  //                   ],
  //                   onChanged: (text) {
  //                     setState(() {
  //                       _valorFueEditado = true;
  //                     });
  //                   },
  //                 ),
  //                 SizedBox(height: 10),
  //                 TextField(
  //                   controller: fechaController,
  //                   decoration: InputDecoration(
  //                     hintText: 'Fecha de venta',
  //                     hintStyle: TextStyle(color: Colors.white54),
  //                     filled: true,
  //                     fillColor: Colors.white24,
  //                     suffixIcon:
  //                         Icon(Icons.calendar_today, color: Colors.white54),
  //                     errorText: _fechaFueEditada &&
  //                             _isFechaInvalida(fechaController.text)
  //                         ? 'Ingrese una fecha válida'
  //                         : null,
  //                   ),
  //                   style: TextStyle(color: Colors.white),
  //                   keyboardType: TextInputType.datetime,
  //                   onTap: () async {
  //                     DateTime? pickedDate = await showDatePicker(
  //                       context: context,
  //                       initialDate: DateTime.now(),
  //                       firstDate: DateTime(2000),
  //                       lastDate: DateTime(2101),
  //                       builder: (BuildContext context, Widget? child) {
  //                         return Theme(
  //                           data: darkTheme,
  //                           child: child!,
  //                         );
  //                       },
  //                     );
  //                     if (pickedDate != null) {
  //                       fechaController.text =
  //                           DateFormat('dd/MM/yyyy').format(pickedDate);
  //                       setState(() {
  //                         _fechaFueEditada = true;
  //                       });
  //                     }
  //                   },
  //                   onChanged: (text) {
  //                     setState(() {
  //                       _fechaFueEditada = true;
  //                     });
  //                   },
  //                 ),
  //               ],
  //             ),
  //             backgroundColor: Color(0xFF171717),
  //             actions: [
  //               TextButton(
  //                 child: Text('Guardar',
  //                     style: TextStyle(color: Color(0xFFFFF0C6))),
  //                 onPressed: () async {
  //                   setState(() {
  //                     _valorFueEditado = true;
  //                     _fechaFueEditada = true;
  //                   });

  //                   if (_isValorInvalido(valorController.text) ||
  //                       _isFechaInvalida(fechaController.text)) {
  //                     return; // Mostrar errores si hay
  //                   }

  //                   try {
  //                     venta.btrpPrecioVentaFinal =
  //                         double.parse(valorController.text);
  //                     venta.btrpFechaVendida =
  //                         DateFormat('dd/MM/yyyy').parse(fechaController.text);

  //                     await ProcesoVentaService.venderProcesoVenta(venta);
  //                     Navigator.of(context).pop();
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(content: Text('Propiedad vendida con éxito')),
  //                     );
  //                     setState(() {
  //                       _selectedVenta = null;
  //                       _reiniciarProcesosVentaFiltros();
  //                     });
  //                   } catch (e) {
  //                     Navigator.of(context).pop();
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(content: Text('Error al vender la propiedad')),
  //                     );
  //                   }
  //                 },
  //               ),
  //               TextButton(
  //                 child: Text('Cancelar',
  //                     style: TextStyle(color: Color(0xFFFFF0C6))),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                   _valorFueEditado = false;
  //                   _fechaFueEditada = false;
  //                 },
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }

  Widget ProcesoVentaRegistro(ProcesoVentaViewModel procesoventa) {
    return FutureBuilder<List<String>>(
      future: ProcesoVentaService.Buscar(
              procesoventa.btrpId,
              procesoventa.btrpTerrenoOBienRaizId! ? 1 : 0,
              procesoventa.btrpBienoterrenoId!)
          .then((value) => value.map((e) => e.imprImagen!).toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              // child: SpinKitCircle(color: Color(0xFFFFF0C6)),
              );
        } else if (snapshot.hasError) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
            color: Color(0xFF171717),
            child: Stack(
              children: [
                ListTile(
                  title: Text(procesoventa.descripcion ?? 'N/A',
                      style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                      'Agente: ${procesoventa.agenDNI ?? 'N/A'} - ${procesoventa.agenNombreCompleto ?? 'N/A'}',
                      style: TextStyle(color: Colors.white70)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (procesoventa.btrpIdentificador == true)
                        IconButton(
                            icon: Icon(Icons.sell, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Venta(
                                        btrpId: procesoventa.btrpId,
                                        btrpTerrenoOBienRaizId:
                                            procesoventa.btrpTerrenoOBienRaizId!
                                                ? 1
                                                : 0,
                                        btrpBienoterrenoId:
                                            procesoventa.btrpBienoterrenoId!),
                                  ),
                                );
                            }
                            ),
                      IconButton(
                        icon: Icon(Icons.info_outline, color: Colors.white),
                        onPressed: () => _verDetalles(
                            procesoventa.btrpId,
                            procesoventa.btrpTerrenoOBienRaizId!,
                            procesoventa.btrpBienoterrenoId),
                      ),
                      Icon(
                          procesoventa.btrpIdentificador == true
                              ? Icons.adjust
                              : Icons.adjust,
                          color: procesoventa.btrpIdentificador == true
                              ? Colors.green
                              : Colors.red),
                    ],
                  ),
                ),
                if (procesoventa.btrpIdentificador == true)
                  Positioned(
                    right: 0,
                    bottom: 40,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        _modalEliminar(context, procesoventa);
                      },
                    ),
                  ),
              ],
            ),
          );
        } else {
          List<String> imagenes = snapshot.data ?? [];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0),
            color: Color(0xFF171717),
            child: Stack(
              children: [
                ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imagenes.isNotEmpty)
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 200.0,
                            autoPlay: true,
                            enlargeCenterPage: true,
                          ),
                          items: imagenes.map((imagePath) {
                            return Builder(
                              builder: (BuildContext context) {
                                return Container(
                                  color: Color(0xFF171717),
                                  child: Image.network(
                                    'http://www.backsigespro.somee.com$imagePath',
                                    fit: BoxFit.contain,
                                    width: MediaQuery.of(context).size.width,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Text(
                                          'Imagen no disponible',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            child: Text(procesoventa.descripcion ?? 'N/A',
                                style: TextStyle(color: Colors.white)),
                          ),
                          if (procesoventa.btrpIdentificador == true)
                            IconButton(
                                icon: Icon(Icons.sell, color: Colors.white),
                                onPressed: () {
                             Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Venta(
                                        btrpId: procesoventa.btrpId,
                                        btrpTerrenoOBienRaizId:
                                            procesoventa.btrpTerrenoOBienRaizId!
                                                ? 1
                                                : 0,
                                        btrpBienoterrenoId:
                                            procesoventa.btrpBienoterrenoId!),
                                  ),
                                );
                            }
                            ),
                          IconButton(
                            icon: Icon(Icons.info_outline, color: Colors.white),
                            onPressed: () => _verDetalles(
                                procesoventa.btrpId,
                                procesoventa.btrpTerrenoOBienRaizId!,
                                procesoventa.btrpBienoterrenoId),
                          ),
                          Icon(
                            procesoventa.btrpIdentificador == true
                                ? Icons.adjust
                                : Icons.adjust,
                            color: procesoventa.btrpIdentificador == true
                                ? Colors.green
                                : Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                  subtitle: Text(
                      'Agente: ${procesoventa.agenDNI ?? 'N/A'} - ${procesoventa.agenNombreCompleto ?? 'N/A'}',
                      style: TextStyle(color: Colors.white70)),
                ),
                if (procesoventa.btrpIdentificador == true)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        _modalEliminar(context, procesoventa);
                      },
                    ),
                  ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget VentaDetalles(List<ProcesoVentaViewModel> ventas) {
    ProcesoVentaViewModel venta = ventas.first;
    List<String> imagenes = ventas
        .where((e) => e.imprImagen != null)
        .map((e) => e.imprImagen!)
        .toList();
    print('Imagenes: $imagenes');

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imagenes.isNotEmpty) ...[
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 200.0,
                      autoPlay: true,
                      enlargeCenterPage: true,
                    ),
                    items: imagenes.map((imagePath) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            color: Color(0xFF171717),
                            child: Image.network(
                              'http://www.backsigespro.somee.com$imagePath',
                              fit: BoxFit.contain,
                              width: MediaQuery.of(context).size.width,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Text(
                                    'Imagen no disponible',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              venta.descripcion ?? 'N/A',
                              style: TextStyle(
                                  color: Color(0xFFFFF0C6), fontSize: 22),
                              overflow: TextOverflow.visible,
                            ),
                          ),
                          Icon(
                            venta.btrpIdentificador == true
                                ? Icons.adjust
                                : Icons.adjust,
                            color: venta.btrpIdentificador == true
                                ? Colors.green
                                : Colors.red,
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        'Area: ${venta.area ?? 'N/A'}',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      SizedBox(height: 8.0),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UbicacionBienRaiz(
                                  btrpId: venta.btrpId,
                                  btrpTerrenoOBienRaizId:
                                      venta.btrpTerrenoOBienRaizId! ? 1 : 0,
                                  btrpBienoterrenoId:
                                      venta.btrpBienoterrenoId!),
                            ),
                          );
                        },
                        child: Text(
                          'Ver ubicación',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),

                      SizedBox(height: 8.0),
                      Divider(
                          color: const Color.fromARGB(
                              179, 2, 2, 2)), // Línea de separación
                      SizedBox(height: 8.0),
                      Text(
                        venta.agenNombreCompleto ?? 'N/A',
                        style:
                            TextStyle(color: Color(0xFFFFF0C6), fontSize: 18),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.white70),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              'DNI: ${venta.agenDNI ?? 'N/A'}',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          Icon(Icons.phone, color: Colors.white70),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              'Teléfono: ${venta.agenTelefono ?? 'N/A'}',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFF0C6),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Valor Inicial: L. ${venta.btrpPrecioVentaInicio?.toStringAsFixed(2) ?? 'N/A'}',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  if (venta.btrpIdentificador == false)
                                    Text(
                                      'Vendido por: L. ${venta.btrpPrecioVentaFinal?.toStringAsFixed(2) ?? 'N/A'}\nFecha Vendida: ${venta.btrpFechaVendida != null ? DateFormat('EEE d MMM, hh:mm a').format(venta.btrpFechaVendida!) : 'N/A'}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                 if (venta.btrpIdentificador == true) {
                                //   _modalVender(context, venta);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Venta(
                                        btrpId: venta.btrpId,
                                        btrpTerrenoOBienRaizId:
                                            venta.btrpTerrenoOBienRaizId!
                                                ? 1
                                                : 0,
                                        btrpBienoterrenoId:
                                            venta.btrpBienoterrenoId!),
                                  ),
                                );
                                 }
                                
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: venta.btrpIdentificador == false
                                      ? Colors.black
                                      : Colors.black,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  venta.btrpIdentificador == false
                                      ? 'Vendido'
                                      : 'Vender',
                                  style: TextStyle(color: Color(0xFFFFF0C6)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
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
                  setState(() {
                    _selectedVenta = null;
                    _reiniciarProcesosVentaFiltros();
                  });
                },
                child: Text(
                  'Regresar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
              height: 50, // Ajusta la altura si es necesario
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
        iconTheme: const IconThemeData(color: Color(0xFFFFF0C6)),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: Icon(Icons.person), onPressed: () {}),
        ],
      ),
      drawer: MenuLateral(
          selectedIndex: _selectedIndex, onItemSelected: _onItemTapped),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (_selectedVenta == null) ...[
              SizedBox(height: 10),
              Card(
                color: Color(0xFF171717),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Buscar.....',
                            hintStyle: TextStyle(color: Colors.white54),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Colors.white54),
                          ),
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.filter_list, color: Colors.white54),
                          onPressed: () {}),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
            Expanded(
              child: FutureBuilder<List<ProcesoVentaViewModel>>(
                future: _procesosventaFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: SpinKitCircle(color: Color(0xFFFFF0C6)),
                    );
                  } else if (snapshot.hasError) {
                    print('Error: ${snapshot.error}');
                    return Center(
                      child: Text('Error al cargar los datos',
                          style: TextStyle(color: Colors.red)),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text('No hay datos disponibles',
                          style: TextStyle(color: Colors.white)),
                    );
                  } else {
                    if (_selectedVenta != null) {
                      return VentaDetalles(_selectedVenta!);
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.only(bottom: 80.0),
                        itemCount: _filteredProcesosVenta.isEmpty
                            ? snapshot.data!.length
                            : _filteredProcesosVenta.length,
                        itemBuilder: (context, index) {
                          return ProcesoVentaRegistro(
                              _filteredProcesosVenta.isEmpty
                                  ? snapshot.data![index]
                                  : _filteredProcesosVenta[index]);
                        },
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
