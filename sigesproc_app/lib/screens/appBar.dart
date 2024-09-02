import 'package:flutter/material.dart';
import 'package:sigesproc_app/screens/acceso/notificacion.dart';
import 'package:sigesproc_app/screens/acceso/perfil.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int unreadCount;

  CustomAppBar({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
              if (unreadCount > 0)
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
                      '$unreadCount',
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
                        // _loadNotifications();
// Aquí puedes recargar las notificaciones si es necesario
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
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
