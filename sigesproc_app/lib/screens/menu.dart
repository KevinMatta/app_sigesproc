import 'package:flutter/material.dart';
import 'package:sigesproc_app/auth/login.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/screens/bienesraices/procesoventa.dart';
import 'package:sigesproc_app/screens/insumos/cotizaciones.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';
import 'inicio.dart';
import 'proyectos/proyecto.dart';
import 'fletes/flete.dart';

class MenuLateral extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  MenuLateral({required this.selectedIndex, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
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
                children: List.generate(6, (index) => _crearItem(context, index)),
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

  Widget _crearItem(BuildContext context, int index) {
    IconData icon;
    String text;
    switch (index) {
      case 0:
        icon = Icons.home;
        text = 'Inicio';
        break;
      case 1:
        icon = Icons.construction;
        text = 'Proyectos';
        break;
      case 2:
        icon = Icons.local_shipping;
        text = 'Fletes';
        break;
      case 3:
        icon = Icons.request_quote;
        text = 'Cotizaciones';
        break;
      case 4:
        icon = Icons.business;
        text = 'Bienes Raíces';
        break;
      case 5:
        icon = Icons.attach_money;
        text = 'Viáticos';
        break;
      default:
        icon = Icons.error;
        text = 'Error';
    }
    bool selected = index == selectedIndex;
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
          onItemSelected(index);
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
      default:
        break;
    }
  }
}
