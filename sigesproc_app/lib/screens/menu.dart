import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigesproc_app/auth/login.dart';
import 'package:sigesproc_app/models/acceso/pantallaviewmodel.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/bienesraices/procesoventa.dart';
import 'package:sigesproc_app/screens/insumos/cotizaciones.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';
import 'package:sigesproc_app/screens/viaticos/viaticos.dart'; // Importa la pantalla de viáticos
import 'package:sigesproc_app/services/loginservice.dart';

import 'inicio.dart';
import 'proyectos/proyecto.dart';
import 'fletes/flete.dart';

class MenuLateral extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  MenuLateral({required this.selectedIndex, required this.onItemSelected});

  @override
  _MenuLateralState createState() => _MenuLateralState();
}

class _MenuLateralState extends State<MenuLateral> {
  String? rolName;
  bool? administrador;
  Map<String, List<String>>? pantallasPorRol;

  @override
  void initState() {
    super.initState();
    obtenerRoleDescripcion();
  }

  Future<void> obtenerRoleDescripcion() async {
    pantallasPorRol = await agruparPantallasPorRol();

    // Inicializa SharedPreferences
    final SharedPreferences pref = await SharedPreferences.getInstance();

    // Intenta obtener el valor almacenado bajo la clave 'roleDescripcion'
    rolName = pref.getString('roleDescripcion');
    // print("Rol del usuario: $rolName");

    String? esAdminString = pref.getString('EsAdmin');
    // Convierte la cadena a un valor booleano, asegurándote de que no sea null
    if (esAdminString != null) {
      administrador = esAdminString.toLowerCase() == 'true';
    } else {
      administrador = false; // Valor por defecto
    }
    // print("Es administrador: $administrador");

    // print("Pantallas por rol: $pantallasPorRol");

    setState(() {}); // Actualiza el estado para que se reconstruya el menú
  }

  Future<Map<String, List<String>>> agruparPantallasPorRol() async {
    Future<List<PantallaViewModel>>? _pantallasFuture = LoginService.listarPantallasPorRol();

    // Espera a que se completen los datos del Future
    List<PantallaViewModel>? pantallas = await _pantallasFuture;

    // Verifica si la lista de pantallas no es nula
    if (pantallas == null || pantallas.isEmpty) {
      // print("La lista de pantallas está vacía o es nula.");
      return {}; // Retorna un mapa vacío si la lista es nula o vacía
    }

    // Crear un mapa para agrupar las pantallas por role_Descripcion
    Map<String, List<String>> pantallasPorRol = {};

    // Recorrer cada pantalla
    for (var pantalla in pantallas) {
      // print("Procesando pantalla: ${pantalla.pantDescripcion} con rol: ${pantalla.roleDescripcion}");
      // Validar que pant_Descripcion y role_Descripcion no sean nulos
      if (pantalla.pantDescripcion != null && pantalla.roleDescripcion != null) {
        String roleDescripcionKey = pantalla.roleDescripcion!;

        if (!pantallasPorRol.containsKey(roleDescripcionKey)) {
          pantallasPorRol[roleDescripcionKey] = [];
        }

        pantallasPorRol[roleDescripcionKey]!.add(pantalla.pantDescripcion!);
      }
    }

    // print("Mapa de pantallas agrupadas por rol: $pantallasPorRol");
    return pantallasPorRol;
  }

  @override
  Widget build(BuildContext context) {
    // Si el estado no ha sido inicializado completamente
    if (pantallasPorRol == null || rolName == null) {
      return Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFF0C6),
                ),
              );
    }

    List<Widget> menuItems = [];

    // El ítem de Inicio siempre se muestra
    menuItems.add(_crearItem(context, 0));

    for (int index = 1; index < 6; index++) {
      String text = _normalizeString(_getMenuItemText(index));
      // print("Comparando ítem del menú: $text");

      // Si el usuario es administrador, muestra todas las opciones
      if (administrador == true) {
        // print("Usuario es administrador, añadiendo todas las opciones.");
        menuItems.add(_crearItem(context, index));
      }
      // Si el usuario no es administrador, muestra solo las opciones permitidas
      else if (_isPantallaPermitida(text)) {
        // print("Pantalla permitida encontrada: $text");
        menuItems.add(_crearItem(context, index));
      } else {
        // print("Pantalla no permitida: $text");
      }
    }

    return Drawer(
      child: Container(
        color: Colors.black,
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/logo-sigesproc.png',
                    height: 135,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                children: menuItems,
              ),
            ),
            Spacer(),
            _crearCerrarSesionItem(context),
            SizedBox(height: 20), // Espacio inferior para que no quede pegado al borde
          ],
        ),
      ),
    );
  }

  String _normalizeString(String input) {
    // Normaliza la cadena eliminando espacios y convirtiendo todo a minúsculas
    return input.replaceAll(RegExp(r'\s+'), '').toLowerCase();
  }

  bool _isPantallaPermitida(String normalizedText) {
  // Revisa si la pantalla está permitida según el rol actual
  if (pantallasPorRol != null && pantallasPorRol![rolName!] != null) {
    List<String> pantallas = pantallasPorRol![rolName!]!;

    for (String pantalla in pantallas) {
      String normalizedPantalla = _normalizeString(pantalla);

      // Aquí es donde hacemos la comparación con cada pantalla
      // Dividimos el texto normalizado por comas en caso de que haya varias pantallas concatenadas
      List<String> pantallasSeparadas = normalizedPantalla.split(',');

      for (String pantallaIndividual in pantallasSeparadas) {
        // print("Comparando pantalla del rol: $pantallaIndividual con el texto normalizado: $normalizedText");
        if (pantallaIndividual == normalizedText) {
          return true;
        }
      }
    }
  }
  return false;
}

  String _getMenuItemText(int index) {
    switch (index) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Proyectos';
      case 2:
        return 'Fletes';
      case 3:
        return 'Cotizaciones';
      case 4:
        return 'Bienes Raíces';
      case 5:
        return 'Viáticos';
      default:
        return 'Error';
    }
  }

  Widget _crearItem(BuildContext context, int index) {
    IconData icon;
    String text = _getMenuItemText(index);

    switch (index) {
      case 0:
        icon = Icons.home;
        break;
      case 1:
        icon = Icons.construction;
        break;
      case 2:
        icon = Icons.local_shipping;
        break;
      case 3:
        icon = Icons.request_quote;
        break;
      case 4:
        icon = Icons.business;
        break;
      case 5:
        icon = Icons.attach_money;
        break;
      default:
        icon = Icons.error;
    }

    bool selected = index == widget.selectedIndex;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: selected ? Color(0xFFFFF0C6) : Colors.black,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: selected ? Colors.black : Color(0xFFFFF0C6)),
        title: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.black : Color(0xFFFFF0C6),
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          widget.onItemSelected(index);
          Navigator.pop(context);
          _navigateToScreen(context, index);
        },
      ),
    );
  }

  Widget _crearCerrarSesionItem(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.exit_to_app, color: Color(0xFFFFF0C6)),
      title: Text(
        'Cerrar sesión',
        style: TextStyle(
          color: Color(0xFFFFF0C6),
        ),
      ),
      onTap: () async {
        var prefs = PreferenciasUsuario();
        String token = prefs.token;

        await NotificationServices.eliminarTokenUsuario(39, token);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      },
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Inicio()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Proyecto()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Flete()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Cotizacion()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProcesoVenta()),
        );
        break;
      case 5:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Viatico()), // Redirección a Viáticos
        );
        break;
      default:
        break;
    }
  }
}
