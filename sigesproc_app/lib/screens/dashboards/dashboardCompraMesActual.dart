import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart'; // Para manejar nombres de meses
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';

class DashboardCompraMesActual extends StatefulWidget {
  @override
  _DashboardCompraMesActualState createState() => _DashboardCompraMesActualState();
}

class _DashboardCompraMesActualState extends State<DashboardCompraMesActual> {
  late Future<List<DashboardViewModel>> _dashboardDataMesActual;

  @override
  void initState() {
    super.initState();
    _dashboardDataMesActual = DashboardService.listarTotalesComprasMensuales();
  }

  // Función para obtener el nombre del mes
  String obtenerNombreMes(int mes) {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat.MMMM('es'); // Nombres de meses en español
    final DateTime fecha = DateTime(now.year, mes); // Crear una fecha con el mes proporcionado
    return formatter.format(fecha).toString(); // Devolver el nombre del mes
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DashboardViewModel>>(
      future: _dashboardDataMesActual,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar datos'),
          );
        } else if (snapshot.hasData) {
          // Filtramos los datos para mostrar sólo el mes actual
          final mesActual = DateTime.now().month;
          final comprasMesActual = snapshot.data!.where((item) => item.mes == mesActual).toList();

          // Calcular total de compras del mes y número de compras
          double totalCompraMes = comprasMesActual.fold(0, (sum, item) => sum + (item.totalCompraMes ?? 0));
          int numeroComprasMes = comprasMesActual.fold(0, (sum, item) => sum + (item.numeroCompras ?? 0));

          return Card(
            color: const Color(0xFF1F1F1F),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // "Compras Mes de [Mes]" en una sola línea
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(text: 'Compras Mes de '),
                        TextSpan(
                          text: obtenerNombreMes(mesActual),
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icono de compra
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(FontAwesomeIcons.shoppingCart, color: Colors.greenAccent),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total de compras del mes con espacio entre "L" y el número
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'L ',
                                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: totalCompraMes.toStringAsFixed(2),
                                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          // Número de compras
                          Text(
                            'Compras: $numeroComprasMes',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                      Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: Text('No hay datos disponibles'),
          );
        }
      },
    );
  }
}
