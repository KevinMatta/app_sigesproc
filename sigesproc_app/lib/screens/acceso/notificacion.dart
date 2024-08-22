import 'package:flutter/material.dart';
import 'package:sigesproc_app/services/acceso/notificacionservice.dart';

class NotificacionesScreen extends StatefulWidget {
  @override
  _NotificacionesScreenState createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications = await NotificationServices.BuscarNotificacion(5);
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

  Future<void> _marcarComoLeida(int napuId) async {
    try {
      await NotificationServices.LeerNotificacion(napuId);
      _loadNotifications(); 
    } catch (e) {
      print('Error al marcar la notificación como leída: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,  
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Notificaciones',
          style: TextStyle(color: Color(0xFFFFF0C6)),
        ),
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

                    return GestureDetector(
                      onTap: () async {
                        if (!isLeida) {
                          await _marcarComoLeida(notification.napuId);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isLeida ? Colors.black  :  Color(0xFF1C1C1E), 
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
                    );
                  },
                ),
    );
  }
}
