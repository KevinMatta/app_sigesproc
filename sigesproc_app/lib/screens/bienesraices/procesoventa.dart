import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:sigesproc_app/models/acceso/usuarioviewmodel.dart';
import 'package:sigesproc_app/models/bienesraices/procesoventaviewmodel.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/acceso/notificacion.dart';
import 'package:sigesproc_app/screens/acceso/perfil.dart';
import 'package:sigesproc_app/screens/appBar.dart';
import 'package:sigesproc_app/screens/bienesraices/terrenos.dart';
import 'package:sigesproc_app/screens/bienesraices/ubicacion.dart';
import 'package:sigesproc_app/screens/bienesraices/venta.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';
import 'package:sigesproc_app/services/acceso/usuarioservice.dart';
import 'package:sigesproc_app/services/bloc/notifications_bloc.dart';
import 'package:sigesproc_app/services/generales/monedaglobalservice.dart';
import '../menu.dart';
import 'package:sigesproc_app/services/bienesraices/procesoventaservice.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:sigesproc_app/screens/bienesraices/venta.dart';

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
  int _unreadCount = 0;
  int? userId;
  String _abreviaturaMoneda = "L";

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
    _loadUserId();

    _loadUserProfileData();
    _cargarProcesosVenta();
    _searchController.addListener(_filtradoProcesosVenta);
  }

  Future<void> _loadUserId() async {
    var prefs = PreferenciasUsuario();
    userId = int.tryParse(prefs.userId) ?? 0;

    _insertarToken();

    context
        .read<NotificationsBloc>()
        .add(InitializeNotificationsEvent(userId: userId!));

    _loadNotifications();
  }

  Future<void> _insertarToken() async {
    var prefs = PreferenciasUsuario();
    String? token = prefs.token;

    if (token != null && token.isNotEmpty) {
      await NotificationServices.insertarToken(userId!, token);
      print('Token insertado después del inicio de sesión: $token');
    } else {
      print('No se encontró token en las preferencias.');
    }
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications =
          await NotificationServices.BuscarNotificacion(userId!);
      setState(() {
        _unreadCount = notifications.where((n) => n.leida == "No Leida").length;
      });
    } catch (e) {
      print('Error al cargar notificaciones: $e');
    }
  }

  // Nueva función para cargar datos del usuario
  Future<void> _loadUserProfileData() async {
    var prefs = PreferenciasUsuario();
    int usua_Id = int.tryParse(prefs.userId) ?? 0;

    try {
      UsuarioViewModel usuario = await UsuarioService.Buscar(usua_Id);

      print('Datos del usuario cargados: ${usuario.usuaUsuario}');
    } catch (e) {
      print("Error al cargar los datos del usuario: $e");
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_filtradoProcesosVenta);
    _searchController.dispose();
    super.dispose();
  }

  String formatNumber(double value) {
    // Para asegurarse de que las comas estén en miles y el punto sea decimal
    final NumberFormat formatter = NumberFormat('#,##0.00',
        'en_US'); // Formato correcto para comas en miles y punto en decimales
    return formatter.format(value);
  }

  Future<void> _loadData() async {
    _abreviaturaMoneda =
        (await MonedaGlobalService.obtenerAbreviaturaMoneda())!;
    setState(() {}); // Refresca el widget para reflejar los nuevos datos
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
              // child: CircularProgressIndicator(color: Color(0xFFFFF0C6)),
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
                            }),
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
                                    'https://azureapisigesproc-hafzeraacxavbmd7.mexicocentral-01.azurewebsites.net$imagePath',
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
                                          btrpTerrenoOBienRaizId: procesoventa
                                                  .btrpTerrenoOBienRaizId!
                                              ? 1
                                              : 0,
                                          btrpBienoterrenoId:
                                              procesoventa.btrpBienoterrenoId!),
                                    ),
                                  );
                                }),
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
                              'https://azureapisigesproc-hafzeraacxavbmd7.mexicocentral-01.azurewebsites.net$imagePath',
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

                      SizedBox(height: 2.0),

                      Text(
                        'Cliente: ${venta.clieNombreCompleto ?? 'N/A'}',
                        style:
                            TextStyle(color: Color(0xFFFFF0C6), fontSize: 14),
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.white70),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              'DNI: ${venta.clieDNI ?? 'N/A'}',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                          Icon(Icons.phone, color: Colors.white70),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Text(
                              'Teléfono: ${venta.clieTelefono ?? 'N/A'}',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Divider(
                          color: Color.fromARGB(
                              179, 255, 255, 255)), // Línea de separación
                      SizedBox(height: 8.0),

                      Text(
                        'Agente: ${venta.agenNombreCompleto ?? 'N/A'}',
                        style:
                            TextStyle(color: Color(0xFFFFF0C6), fontSize: 14),
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
                                    'Valor Inicial: $_abreviaturaMoneda ${formatNumber(venta.btrpPrecioVentaInicio!.toDouble())}',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  if (venta.btrpIdentificador == false)
                                    Text(
                                      'Vendido por: $_abreviaturaMoneda ${formatNumber(venta.btrpPrecioVentaFinal!.toDouble())}\nFecha Vendida: ${venta.btrpFechaVendida != null ? DateFormat('EEE d MMM, hh:mm a').format(venta.btrpFechaVendida!) : 'N/A'}',
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
        // Container(
        //   color: Colors.black,
        //   padding: const EdgeInsets.all(10.0),
        //   child: Row(
        //     children: [
        //       Spacer(),
        //       ElevatedButton(
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: Color(0xFF171717),
        //           padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(12),
        //           ),
        //         ),
        //         onPressed: () {
        //           setState(() {
        //             _selectedVenta = null;
        //             _reiniciarProcesosVentaFiltros();
        //           });
        //         },
        //         child: Text(
        //           'Regresar',
        //           style: TextStyle(
        //             color: Colors.white,
        //             fontSize: 15,
        //             decoration: TextDecoration.underline,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
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
              height: 50,
            ),
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
        bottom: _selectedVenta != null
            ? PreferredSize(
                preferredSize: Size.fromHeight(90.0),
                child: Column(
                  children: [
                    Text(
                      'Detalle Bien Raíz',
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
                            setState(() {
                              _selectedVenta = null;
                              _reiniciarProcesosVentaFiltros();
                            });
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
                    SizedBox(height: 15.0),
                  ],
                ),
              ) :  PreferredSize(
                preferredSize: Size.fromHeight(40.0),
                child: Column(
                  children: [
                    Text(
                      'Bienes Raices',
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
            icon: Stack(
              children: [
                Icon(Icons.notifications),
                if (_unreadCount > 0)
                  Positioned(
                    right: 0,
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
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificacionesScreen(),
                ),
              );
              _loadNotifications();
            },
          ),
          IconButton(
            icon: Icon(Icons.person),
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
                            hintText: 'Buscar...',
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TerrenosMap(),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Color(0xFFFFF0C6),
                      size: 20,
                    ),
                    SizedBox(width: 4), // Espacio entre el ícono y el texto
                    Text(
                      'Ver todos los terrenos',
                      style: TextStyle(
                        color: Color(0xFFFFF0C6),
                        fontSize: 12,
                      ),
                    ),
                  ],
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
                      child:
                          CircularProgressIndicator(color: Color(0xFFFFF0C6)),
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
