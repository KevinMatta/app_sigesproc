import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart'; // Para manejar nombres de meses y formato de números
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';
import 'package:sigesproc_app/services/generales/monedaglobalservice.dart';

class DashboardCompraMesActual extends StatefulWidget {
  @override
  _DashboardCompraMesActualState createState() =>
      _DashboardCompraMesActualState();
}

class _DashboardCompraMesActualState extends State<DashboardCompraMesActual> {
  late Future<List<ComprasMesViewModel>> _dashboardDataMesActual;
  String _abreviaturaMoneda = "L"; // Valor predeterminado

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Función asincrónica para cargar los datos
  Future<void> _loadData() async {
    _dashboardDataMesActual = DashboardService.listarTotalesComprasMensuales();
    _abreviaturaMoneda =
        (await MonedaGlobalService.obtenerAbreviaturaMoneda())!;
    setState(() {}); // Refresca el widget para reflejar los nuevos datos
  }

  // Función para formatear los números con comas y punto decimal
  String formatNumber(double value) {
    // Para asegurarse de que las comas estén en miles y el punto sea decimal
    final NumberFormat formatter = NumberFormat('#,##0.00',
        'en_US'); // Formato correcto para comas en miles y punto en decimales
    return formatter.format(value);
  }

  // Función para obtener el nombre del mes
  String obtenerNombreMes(int mes) {
    final DateTime now = DateTime.now();
    final DateFormat formatter =
        DateFormat.MMMM('es'); // Nombres de los meses en español
    final DateTime fecha =
        DateTime(now.year, mes); // Crear una fecha con el mes dado
    String mesFormateado = formatter
        .format(fecha)
        .toLowerCase(); // Convertir el nombre del mes a minúsculas
    return mesFormateado[0].toUpperCase() +
        mesFormateado.substring(1); // Capitalizar la primera letra
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ComprasMesViewModel>>(
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
          // Filtrar los datos para mostrar solo el mes actual
          final mesActual = DateTime.now().month;
          final comprasMesActual =
              snapshot.data!.where((item) => item.mes == mesActual).toList();

          // Calcular el total gastado y el número de compras del mes
          double totalCompraMes = comprasMesActual.fold(
              0, (sum, item) => sum + (item.totalCompraMes ?? 0));
          int numeroComprasMes = comprasMesActual.fold(
              0, (sum, item) => sum + (item.numeroCompras ?? 0));

          return Column(
            children: [
              // Tarjeta para la información del mes con ícono de calendario
              Card(
                color: const Color(0xFF1F1F1F),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0), // Reducción de padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.calendar,
                          color: Colors.yellowAccent,
                          size: 16), // Ícono más pequeño
                      SizedBox(width: 8),
                      Text(
                        obtenerNombreMes(mesActual),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              // Eliminación de espacio innecesario
              SizedBox(height: 2), // Tamaño reducido al mínimo
              // Fila para el total gastado y total de compras
              Row(
                children: [
                  // Tarjeta para el total gastado
                  Expanded(
                    child: Card(
                      color: const Color(0xFF1F1F1F),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical:
                                8.0), // Ajuste de padding para reducir espacios
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(FontAwesomeIcons.moneyBillWave,
                                    color: Colors.greenAccent,
                                    size: 16), // Ícono más pequeño
                                SizedBox(width: 8),
                                Text(
                                  'Total Gastado',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            // Total gastado formateado con comas en miles y punto en decimales
                            Text(
                              '$_abreviaturaMoneda ${formatNumber(totalCompraMes)}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.bold), // Tamaño ajustado
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4), // Espacio reducido entre las dos tarjetas
                  // Tarjeta para el total de compras
                  Expanded(
                    child: Card(
                      color: const Color(0xFF1F1F1F),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical:
                                8.0), // Ajuste de padding para reducir espacios
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(FontAwesomeIcons.shoppingCart,
                                    color: Colors.blueAccent,
                                    size: 16), // Ícono más pequeño
                                SizedBox(width: 8),
                                Text(
                                  'Total Compras',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            // Número de compras
                            Text(
                              '$numeroComprasMes Compras',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.bold), // Tamaño ajustado
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
