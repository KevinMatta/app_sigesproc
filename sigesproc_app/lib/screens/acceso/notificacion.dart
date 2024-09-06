import 'package:flutter/material.dart';
import 'package:sigesproc_app/preferences/pref_usuarios.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';

class NotificacionesScreen extends StatefulWidget {
  @override
  _NotificacionesScreenState createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = false;
  late int usua_Id;

  @override
  void initState() {
    var prefs = PreferenciasUsuario();
    usua_Id = int.tryParse(prefs.userId) ?? 0;
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await NotificationServices.BuscarNotificacion(usua_Id);
      setState(() {
        _notifications = notifications;
      });
    } catch (e) {
      print('Error al cargar notificaciones: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showOverlayMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.black), 
        ),
        backgroundColor: Color(0xFFFFF0C6), 
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _marcarComoLeida(int napuId) async {
    try {
      await NotificationServices.LeerNotificacion(napuId);
      _loadNotifications(); 
    } catch (e) {
      print('Error al marcar la notificación como leída: $e');
    }
  }

  Future<void> _eliminarNotificacion(int napuId) async {
    try {
      var prefs = PreferenciasUsuario();
      final success = await NotificationServices.EliminarNotificacion(napuId);
      if (success) {
        _showOverlayMessage('Eliminada con Éxito.');
        _loadNotifications(); 
        String title = "Notificación Eliminada";
        String body = "Se ha eliminado una notificación con Id: $napuId";
        // await NotificationServices.EnviarNotificacionAAdministradores(title, body);
      } else {
        _showOverlayMessage('Error al eliminar la notificación.');
      }
    } catch (e) {
      print('Error al eliminar la notificación: $e');
    }
  }

  void _showConfirmationDialog(int napuId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Color(0xFF171717), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            'Confirmación',
            style: TextStyle(
              color: Color(0xFFFFF0C6),
              fontSize: 20,
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar esta notificación?',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop(); 
                _eliminarNotificacion(napuId); 
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFFFF0C6), 
                textStyle: TextStyle(fontSize: 14),
                padding: EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              icon: Icon(Icons.delete, color: Colors.black),
              label: Text('Eliminar', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, 
                textStyle: TextStyle(fontSize: 14),
                padding: EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              icon: Icon(Icons.close, color: Color(0xFFFFF0C6)),
              label: Text('Cancelar', style: TextStyle(color: Color(0xFFFFF0C6))),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,  
      appBar: AppBar(
        backgroundColor: Colors.black,
        leadingWidth: 100, // Aumentar el espacio de la palabra "Regresar"
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Row(
            children: [
              SizedBox(width: 8),
              Icon(Icons.arrow_back, color: Color(0xFFFFF0C6)),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Regresar',
                  style: TextStyle(color: Color(0xFFFFF0C6), fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
          title: Text('Notificaciones', style: TextStyle(color: Color(0xFFFFF0C6))),
          centerTitle: true, // Centrar el título
          iconTheme: IconThemeData(color: Color(0xFFFFF0C6)),
      
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(child: Text('No hay notificaciones', style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final isAlerta = notification.notificacionOalerta == "Alerta";
                    final isLeida = notification.leida == "Leida"; 

                    return Dismissible(
                      key: Key(notification.napuId.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.endToStart) {
                          _showConfirmationDialog(notification.napuId);
                        }
                        return false; 
                      },
                      child: GestureDetector(
                        onTap: () async {
                          if (!isLeida) {
                            await _marcarComoLeida(notification.napuId);
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isLeida ? Colors.black : Color(0xFF1C1C1E), 
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 4,
                              color: isAlerta ? Colors.red : Colors.green,
                            ),
                            title: Text(
                              notification.notificacionOalerta ?? 'Notificación',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              notification.descripcion ?? 'Sin descripción',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            trailing: isLeida 
                                ? Icon(Icons.check_circle_outline, color: Colors.grey) 
                                : Icon(Icons.notifications_active, color: Color(0xFFFFF0C6)), 
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
