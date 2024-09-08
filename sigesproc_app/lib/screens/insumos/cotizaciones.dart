import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:sigesproc_app/models/acceso/usuarioviewmodel.dart';
import 'package:sigesproc_app/models/insumos/articuloviewmodel.dart';
import 'package:sigesproc_app/models/insumos/cotizacionviewmodel.dart';
import 'package:sigesproc_app/screens/acceso/notificacion.dart';
import 'package:sigesproc_app/screens/acceso/perfil.dart';
import 'package:sigesproc_app/services/acceso/usuarioservice.dart';
import 'package:sigesproc_app/services/generales/monedaglobalservice.dart';
import 'package:sigesproc_app/services/insumos/articuloservice.dart';
import '../menu.dart';
import 'package:sigesproc_app/services/insumos/cotizacionservice.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';
import 'package:sigesproc_app/services/bloc/notifications_bloc.dart';
import '../appBar.dart'; // Asegúrate de que estás importando el CustomAppBar

class Cotizacion extends StatefulWidget {
  @override
  _CotizacionState createState() => _CotizacionState();
}

class _CotizacionState extends State<Cotizacion> {
  int _selectedIndex = 3;
  Future<List<CotizacionViewModel>>? _cotizacionesFuture;
  Future<List<ArticuloViewModel>>? _articulosFuture;
  TextEditingController _searchController = TextEditingController();
  List<CotizacionViewModel> _cotizacionesFiltrados = [];
  bool _mostrarArticulos = false;
  int? _selectedCotiId;
  int _currentPage = 0;
  int _rowsPerPage = 10;
  int _unreadCount = 0;
  int? userId;
  String _abreviaturaMoneda = "L";

  @override
  void initState() {
    super.initState();
    _loadUserId();

    _loadUserProfileData();
    _cotizacionesFuture = CotizacionService.listarCotizaciones();
    _cotizacionesFuture!.then((cotizaciones) {
      setState(() {
        _cotizacionesFiltrados = cotizaciones;
      });
    });
    _searchController.addListener(_filterCotizaciones);
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
    _searchController.dispose();
    super.dispose();
  }

  void _filterCotizaciones() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      // Filtrar las cotizaciones
      _cotizacionesFiltrados = _cotizacionesFiltrados.where((cotizacion) {
        final salida = cotizacion.provDescripcion?.toLowerCase() ?? '';
        return salida.contains(query);
      }).toList();

      // Calcular el número total de registros y páginas
      final totalRecords = _cotizacionesFiltrados.length;
      final maxPages = (totalRecords / _rowsPerPage).ceil();

      // Si no hay registros, mostrar un mensaje o manejar el caso de la lista vacía
      if (totalRecords == 0) {}

      // Evitar que _currentPage sea negativo
      if (_currentPage >= maxPages) {
        _currentPage = maxPages > 0 ? maxPages - 1 : 0;
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _reiniciarCotizacionesFiltros() {
    setState(() {
      _cotizacionesFiltrados = [];
    });
    _cargarCotizaciones();
  }

  void _cargarCotizaciones() {
    _cotizacionesFuture = CotizacionService.listarCotizaciones();
    _cotizacionesFuture!.then((cotizaciones) {
      setState(() {
        _cotizacionesFiltrados = cotizaciones;
      });
    });
  }

  void _verArticulos(int cotiId) {
    setState(() {
      _mostrarArticulos = true;
      _selectedCotiId = cotiId;
      print('cotiid: $cotiId');
      _articulosFuture = ArticuloService.ListarArticulosPorCotizacion(cotiId);
    });
  }

  TableRow _buildCotizacionRow(CotizacionViewModel cotizacion, int index) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.info_outline, color: Colors.white),
              onPressed: () => _verArticulos(cotizacion.cotiId),
            ),
          ),
        ),
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
              'Cotización ${cotizacion.cotiId}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              cotizacion.provDescripcion ?? 'N/A',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }

  void _previousPage() {
    setState(() {
      if (_currentPage > 0) {
        _currentPage--;
      }
    });
  }

  void _nextPage() {
    setState(() {
      if (_cotizacionesFiltrados.length > (_currentPage + 1) * _rowsPerPage) {
        _currentPage++;
      }
    });
  }

  Widget ArticuloRegistro(ArticuloViewModel articulo) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          articulo.codigo.toString(),
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Color(0xFFFFF0C6),
      ),
      title: Text(
        articulo.articulo,
        style: TextStyle(color: Colors.white),
        maxLines: 2, // Limitar a 2 líneas si es necesario
        overflow: TextOverflow.ellipsis, // Para manejar textos muy largos
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primer bloque con precio y cantidad
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Precio: $_abreviaturaMoneda ${formatNumber(double.parse(articulo.precio.replaceAll(",", "")))}',
                  style: TextStyle(color: Colors.white70),
                  softWrap: true,
                ),
              ),
              Expanded(
                child: Text(
                  'Cantidad: ${articulo.cantidad}',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.end, // Alineado al final
                  softWrap: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.0),
          // Segundo bloque con impuesto y total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Impuesto: $_abreviaturaMoneda ${formatNumber(double.parse(articulo.impuesto.replaceAll(",", "")))}',
                  style: TextStyle(color: Colors.white70),
                  softWrap: true,
                ),
              ),
              Expanded(
                child: Text(
                  'Total: $_abreviaturaMoneda ${formatNumber(double.parse(articulo.total.replaceAll(",", "")))}',
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.end, // Alineado al final
                  softWrap: true,
                ),
              ),
            ],
          ),
        ],
      ),
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
        bottom: _mostrarArticulos
            ? PreferredSize(
                preferredSize: Size.fromHeight(70.0),
                child: Column(
                  children: [
                    Text(
                      'Artículos',
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
                              _selectedCotiId = null;
                              _reiniciarCotizacionesFiltros();
                              _mostrarArticulos = false;
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
              )
            : PreferredSize(
                preferredSize: Size.fromHeight(30.0),
                child: Column(
                  children: [
                    Text(
                      'Cotizaciones',
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
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
      body: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
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
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: _mostrarArticulos
                  ? FutureBuilder<List<ArticuloViewModel>>(
                      future: _articulosFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFFFF0C6)),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error al cargar los datos',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No hay datos disponibles',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        } else {
                          return ListView.builder(
                            padding: EdgeInsets.only(bottom: 80.0),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return ArticuloRegistro(snapshot.data![index]);
                            },
                          );
                        }
                      },
                    )
                  : FutureBuilder<List<CotizacionViewModel>>(
                      future: _cotizacionesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFFFF0C6)),
                          );
                        } else if (snapshot.hasError) {
                          print('tiene error $snapshot');
                          return Center(
                            child: Text(
                              'Error al cargar los datos',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'No hay datos disponibles',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        } else {
                          _cotizacionesFiltrados =
                              _searchController.text.isEmpty
                                  ? snapshot.data!
                                  : _cotizacionesFiltrados;
                          final int totalRecords =
                              _cotizacionesFiltrados.length;
                          final int startIndex = _currentPage * _rowsPerPage;
                          final int endIndex =
                              (startIndex + _rowsPerPage > totalRecords)
                                  ? totalRecords
                                  : startIndex + _rowsPerPage;

                          return Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Table(
                                    columnWidths: {
                                      0: FlexColumnWidth(2),
                                      1: FlexColumnWidth(1),
                                      2: FlexColumnWidth(2.5),
                                      3: FlexColumnWidth(3),
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
                                              'Artículos',
                                              style: TextStyle(
                                                color: Color(0xFFFFF0C6),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
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
                                              'Descripción',
                                              style: TextStyle(
                                                color: Color(0xFFFFF0C6),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Proveedor',
                                              style: TextStyle(
                                                color: Color(0xFFFFF0C6),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      ..._cotizacionesFiltrados
                                          .sublist(startIndex, endIndex)
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final index = entry.key;
                                        final cotizacion = entry.value;
                                        return _buildCotizacionRow(
                                            cotizacion, startIndex + index);
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Mostrando ${startIndex + 1} al ${endIndex} de $totalRecords entradas',
                                style: TextStyle(color: Colors.white),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: _previousPage,
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward),
                                    onPressed: _nextPage,
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
            ),
            // Visibility(
            //   visible: _mostrarArticulos,
            //   child: Container(
            //     color: Colors.black,
            //     padding: const EdgeInsets.all(10.0),
            //     child: Row(
            //       children: [
            //         Spacer(),
            //         ElevatedButton(
            //           style: ElevatedButton.styleFrom(
            //             backgroundColor: Color(0xFF171717),
            //             padding: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
            //             shape: RoundedRectangleBorder(
            //               borderRadius: BorderRadius.circular(12),
            //             ),
            //           ),
            //           onPressed: () {
            //             setState(() {
            //               _selectedCotiId = null;
            //               _reiniciarCotizacionesFiltros();
            //               _mostrarArticulos = false;
            //             });
            //           },
            //           child: Text(
            //             'Regresar',
            //             style: TextStyle(
            //               color: Colors.white,
            //               fontSize: 15,
            //               decoration: TextDecoration.underline,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
