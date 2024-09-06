import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sigesproc_app/models/dashboard/dashboardviewmodel.dart';
import 'package:sigesproc_app/services/dashboard/dashboardservice.dart';
import 'package:sigesproc_app/services/generales/monedaglobalservice.dart';
import 'package:intl/intl.dart'; // Para manejar el formato de números

class DashboardViaticosMesActual extends StatefulWidget {
  @override
  _DashboardViaticosMesActualState createState() =>
      _DashboardViaticosMesActualState();
}

class _DashboardViaticosMesActualState
    extends State<DashboardViaticosMesActual> {
  late Future<List<DashboardViewModel>> _dashboardDataViaticosMesActual;
  String _abreviaturaMoneda = "L"; // Valor predeterminado de moneda

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Función asincrónica para cargar la abreviatura de moneda
  Future<void> _loadData() async {
    _dashboardDataViaticosMesActual =
        DashboardService.listarPrestamosViaticosMes();
    _abreviaturaMoneda = (await MonedaGlobalService.obtenerAbreviaturaMoneda())!;
    setState(() {}); // Refresca el widget para reflejar la nueva abreviatura
  }

  // Función para formatear los números con comas y punto decimal
  String formatNumber(double value) {
    final NumberFormat formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(value);
  }

  // Función para obtener el nombre del mes
  String obtenerNombreMes(int mes) {
    List<String> meses = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return meses[mes - 1]; // Ajuste para que coincida con el índice del mes
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DashboardViewModel>>(
      future: _dashboardDataViaticosMesActual,
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
          final viaticosMesActual =
              snapshot.data!.where((item) => item.mes == mesActual).toList();

          // Calcular total gastado, monto estimado y cantidad de viáticos
          double totalGastadoMes = viaticosMesActual.fold(
              0, (sum, item) => sum + (item.totalGastado ?? 0));
          double montoEstimadoMes = viaticosMesActual.fold(
              0, (sum, item) => sum + (item.montoEstimado ?? 0));
          int cantidadViaticosMes = viaticosMesActual.fold(
              0, (sum, item) => sum + (item.cantidadViaticos ?? 0));

          return Card(
            color: const Color(0xFF1F1F1F),
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // "Viáticos Mes de [Mes]" en una sola línea
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                          color: Color(0xFFFFF0C6),
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(text: 'Viáticos Mes de '),
                        TextSpan(
                          text: obtenerNombreMes(mesActual),
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icono de viáticos
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(FontAwesomeIcons.moneyBill,
                            color: Colors.blueAccent),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Total gastado del mes formateado con la abreviatura de moneda
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Gastado: $_abreviaturaMoneda ',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: formatNumber(totalGastadoMes),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          // Monto estimado del mes formateado con la abreviatura de moneda
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Estimado: $_abreviaturaMoneda ',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                ),
                                TextSpan(
                                  text: formatNumber(montoEstimadoMes),
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 4),
                          // Cantidad de viáticos
                          Text(
                            'Viáticos: $cantidadViaticosMes',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14),
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
