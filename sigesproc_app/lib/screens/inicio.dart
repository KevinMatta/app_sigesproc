import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigesproc_app/models/acceso/usuarioviewmodel.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/dashboards/DashboardVentasPorAgente.dart';
import 'package:sigesproc_app/screens/dashboards/dashboardCompraMesActual.dart';
import 'package:sigesproc_app/screens/dashboards/dashboardProyectoIncidenciasMensuales.dart';
import 'package:sigesproc_app/services/acceso/usuarioservice.dart';
import 'package:sigesproc_app/services/bloc/notifications_bloc.dart';
import 'menu.dart';
import 'package:sigesproc_app/screens/acceso/perfil.dart';
import 'package:sigesproc_app/screens/acceso/notificacion.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';
import 'appBar.dart';
import 'package:sigesproc_app/screens/dashboards/dashboardTop5Proveedores.dart';
import 'package:sigesproc_app/screens/dashboards/dashboardFletesTop5ProyectosRelacionados.dart';
import 'package:sigesproc_app/screens/dashboards/dashboardTop5ProyectosPresupuesto.dart';
import 'package:sigesproc_app/screens/dashboards/dashboardFleteIncidenciasMes.dart';
import 'package:sigesproc_app/screens/dashboards/dasboardTop5Articulos.dart';
import 'package:sigesproc_app/screens/dashboards/dashboardFletesTop5Bodegas.dart';
import 'package:sigesproc_app/screens/dashboards/dashboardMaximoPresupuestoMes.dart';
import 'package:sigesproc_app/screens/dashboards/dashboardViaticosPrestados.dart';
import 'package:sigesproc_app/screens/dashboards/dashboardPrestamosDiasMes.dart';
import 'package:sigesproc_app/screens/dashboards/dashboardTop5Bancos.dart';
import 'package:sigesproc_app/screens/dashboards/dashboardProyectosPorDepartamento.dart';
import 'package:sigesproc_app/screens/dashboards/dashboardVentaBienRaiz .dart';
import 'package:sigesproc_app/screens/dashboards/dashboardVentaTerreno.dart';

class Inicio extends StatefulWidget {
  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  TabController? _tabController;
  int _unreadCount = 0;
  int? userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    _loadUserId();

    _loadUserProfileData();
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var prefs = PreferenciasUsuario();
    print('Token:' + prefs.token);

    context.read<NotificationsBloc>().requestPermision();
    print('Token después de solicitar permisos: ' + prefs.token);

    return Scaffold(
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
        bottom: TabBar(
          controller: _tabController,
          labelPadding: EdgeInsets.symmetric(horizontal: 5.0),
          tabs: [
            Tab(text: 'Cotizaciones'),
            Tab(text: 'Fletes'),
            Tab(text: 'Proyectos'),
            Tab(text: 'Bienes'),
            Tab(text: 'Planilla'),
          ],
          labelColor: Color(0xFFFFF0C6),
          unselectedLabelColor: Colors.white,
          indicatorColor: Color(0xFFFFF0C6),
        ),
      ),
      drawer: MenuLateral(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCotizacionesTab(),
          _buildFletesTab(),
          _buildProyectosTab(),
          _buildBienesTab(),
          _buildBienesPlanilla(),
        ],
      ),
    );
  }

  Widget _buildCotizacionesTab() {
  
    return Container(
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
        Card(
  color: Color(0xFF171717),
  child: Padding(
    padding: const EdgeInsets.all(1.0),
    child: DashboardCompraMesActual(), // Componente nuevo para compras del mes
  ),
   ),

            SizedBox(height: 10),
            Card(
              color: Color(0xFF171717),
              child: Container(
                height: 270,
                child: Padding(
                  padding: const EdgeInsets.all(1.0),
                  child:
                      TopArticlesDashboard(), // Gráfico de los top 5 artículos
                ),
              ),
            ),
            SizedBox(height: 10),
            Card(
              color: Color(0xFF171717),
              child: Container(
                height: 230,
                padding: const EdgeInsets.all(
                      8.0),
                  child:
                      TopProveedoresDashboard(), // Gráfico de los top 5 proveedores
              
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFletesTab() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(14.0),
      child: Column(
        children: [
          SizedBox(height: 8),
          Expanded(
            child: Card(
              color: Color(0xFF171717),
              child: Container(
                height: 250,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IncidenceDashboardCard(),
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Card(
              color: Color(0xFF171717),
              child: Container(
                height: 250, // Aumenta la altura del contenedor
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                      TopWarehousesDashboard(), // Call TopArticlesDashboard in Dashboard 1
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Card(
              color: Color(0xFF171717),
              child: Container(
                height: 180, // Aumenta la altura del contenedor
                child: Padding(
                  padding: const EdgeInsets.all(
                      8.0), // Añade padding si es necesario
                  child:
                      TopProjectsDashboard(), // Call TopArticlesDashboard in Dashboard 1
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProyectosTab() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // First dashboard (spans the entire row)
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Color(0xFF171717),
                    child: Container(
                      height: 280, // Reduced height for the container
                      child: Padding(
                        padding: const EdgeInsets.all(
                            8.0), // Add padding if necessary
                        child:
                            TopProjectsBudgetDashboard(), // Call the updated dashboard here
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(height: 10),

            // Dashboard 3 and Dashboard 4
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Color(0xFF171717),
                    child: Container(
                      height: 115, // Reduced height for the container
                      child: Padding(
                        padding: const EdgeInsets.all(
                            8.0), // Add padding if necessary
                        child:
                            IncidenceCostDashboardCard(), // Call the updated dashboard here
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Expanded(
                  child: Card(
                    color: Color(0xFF171717),
                    child: Container(
                      height: 115, // Reduced height for the container
                      child: Padding(
                        padding: const EdgeInsets.all(
                            8.0), // Add padding if necessary
                        child:
                            ProjectCostDashboardCard(), // Call the updated dashboard here
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Color(0xFF171717),
                    child: Container(
                      height: 300, // Reduced height for the container
                      child: Padding(
                        padding: const EdgeInsets.all(
                            8.0), // Add padding if necessary
                        child:
                            TopEstadosDashboard(), // Call the updated dashboard here
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

Widget _buildBienesTab() {
  return Container(
    color: Colors.black,
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Card(
                color: Color(0xFF171717),
                child: Container(
                  height: 200,
                    padding: const EdgeInsets.all(
                      8.0), 
                  child: DashboardVentaBienRaiz(), // Dashboard de Bienes Raíces
                ),
              ),
            ),
            SizedBox(width: 5),
            Expanded(
              child: Card(
                color: Color(0xFF171717),
                child: Container(
                  height: 200,
                    padding: const EdgeInsets.all(
                      8.0), 
                  child: DashboardVentaTerreno(), // Nuevo Dashboard de Terrenos
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Expanded(
          child: Card(
            color: Color(0xFF171717),
            child: Container(
              height: 200,
                padding: const EdgeInsets.all(
                      8.0),  // Ajusta la altura si es necesario
              child: DashboardVentasPorAgente(), // Dashboard de Ventas por Agente (nuevo gráfico circular)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBienesPlanilla() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            color: Color(0xFF171717),
            child: Container(
              height: 150,
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child:
                    DashboardViaticosMesActual(), // Componente nuevo para compras del mes
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Card(
              color: Color(0xFF171717),
              child: Container(
                height: 130, // Reduced height for the container
                child: Padding(
                  padding:
                      const EdgeInsets.all(8.0), // Add padding if necessary
                  child:
                      PrestamosViaticosDashboard(), // Call the updated dashboard here
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Card(
              color: Color(0xFF171717),
              child: Container(
                height: 130,
                child: Padding(
                  padding:
                      const EdgeInsets.all(8.0), // Add padding if necessary
                  child:
                      Top5BancosDashboard(), // Call the updated dashboard here
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
